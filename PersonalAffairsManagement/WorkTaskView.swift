//
//  WorkTaskView.swift
//  PersonalAffairsManagement
//
//  Created by 汤寿麟 on 2025/6/23.
//

import SwiftUI
import SwiftData

struct WorkTaskView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WorkTask.createdAt, order: .reverse) private var tasks: [WorkTask]
    @State private var showingAddTaskView = false
    @State private var searchText = ""
    
    let filter: TaskFilter
    
    init(filter: TaskFilter) {
        self.filter = filter
    }

    var body: some View {
        NavigationStack {
            Group {
                if tasks.isEmpty {
                    emptyStateView()
                } else {
                    List {
                        ForEach(filteredTasks) { task in
                            TaskRowView(task: task)
                        }
                        .onDelete(perform: deleteTasks)
                        .onMove(perform: moveTasks)
                    }
                    .listStyle(InsetGroupedListStyle())
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "搜索任务")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddTaskView = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddTaskView) {
                // Pass the current project to the AddTaskView if one is selected
                if case .project(let project) = filter {
                    AddTaskView(project: project)
                } else {
                    AddTaskView()
                }
            }
        }
    }
    
    @ViewBuilder
    private func emptyStateView() -> some View {
        ContentUnavailableView(
            "没有任务",
            systemImage: "checklist",
            description: Text(emptyStateDescription)
        )
    }

    private var emptyStateDescription: String {
        switch filter {
        case .inbox:
            return "所有新任务都会出现在这里。"
        case .today:
            return "你今天没有需要完成的任务。"
        case .upcoming:
            return "近期没有即将到期的任务。"
        case .all:
            return "你还没有创建任何任务。"
        case .project(let project):
            return "项目 \"\(project.name)\" 中还没有任务。"
        }
    }

    var filteredTasks: [WorkTask] {
        var filtered = tasks
        switch filter {
        case .inbox:
            filtered = filtered.filter { $0.status == .pending && $0.project == nil }
        case .today:
            let calendar = Calendar.current
            let today = Date()
            filtered = filtered.filter { task in
                guard let dueDate = task.dueDate else { return false }
                return calendar.isDate(dueDate, inSameDayAs: today) && task.status != .completed
            }
        case .upcoming:
            let calendar = Calendar.current
            let now = Date()
            let nextWeek = calendar.date(byAdding: .day, value: 7, to: now) ?? now
            filtered = filtered.filter { task in
                guard let dueDate = task.dueDate else { return false }
                return dueDate > now && dueDate <= nextWeek && task.status != .completed
            }
        case .all:
            break
        case .project(let project):
            filtered = filtered.filter { $0.project?.id == project.id }
        }
        if !searchText.isEmpty {
            filtered = filtered.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
        return filtered
    }

    private func deleteTasks(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(tasks[index])
            }
        }
    }
    
    private func moveTasks(from source: IndexSet, to destination: Int) {
        // Note: In a real app, you might want to add an "order" property to tasks
        // and update it when tasks are moved. For now, we'll just allow the move
        // but the order will be maintained by the createdAt date.
        // This is a simplified implementation.
    }

    private var navigationTitle: String {
        switch filter {
        case .all:
            return "All Tasks"
        case .today:
            return "Today"
        case .upcoming:
            return "Upcoming"
        case .inbox:
            return "Inbox"
        case .project(let project):
            return project.name
        }
    }
}

struct TaskRowView: View {
    @Environment(\.modelContext) private var modelContext
    let task: WorkTask
    @State private var showingEditTask = false
    @State private var isCompleted = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                // Checkbox
                Button(action: toggleTaskStatus) {
                    Image(systemName: task.status == .completed ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundColor(task.status == .completed ? .green : .gray)
                        .animation(.easeInOut(duration: 0.2), value: task.status)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Task content
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .font(.body)
                        .fontWeight(.medium)
                        .strikethrough(task.status == .completed)
                        .foregroundColor(task.status == .completed ? .secondary : .primary)
                        .animation(.easeInOut(duration: 0.2), value: task.status)
                    
                    if !task.taskDescription.isEmpty {
                        Text(task.taskDescription)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    // Task metadata
                    HStack(spacing: 12) {
                        if let dueDate = task.dueDate {
                            Label(dueDate.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                                .font(.caption2)
                                .foregroundColor(isOverdue(dueDate) ? .red : .secondary)
                        }
                        
                        if task.reminderDate != nil {
                            Label("", systemImage: "bell.fill")
                                .font(.caption2)
                                .foregroundColor(.orange)
                        }
                        
                        if task.repeatRule != nil {
                            Label("", systemImage: "repeat")
                                .font(.caption2)
                                .foregroundColor(.blue)
                        }
                        
                        Spacer()
                    }
                }
                
                Spacer()
                
                // Priority badge
                PriorityBadge(priority: task.priority)
            }
            
            // Display subtasks if any
            if let subtasks = task.subtasks, !subtasks.isEmpty {
                VStack(spacing: 4) {
                    ForEach(subtasks) { subtask in
                        HStack {
                            Image(systemName: subtask.status == .completed ? "checkmark.circle.fill" : "circle")
                                .font(.caption)
                                .foregroundColor(subtask.status == .completed ? .green : .gray)
                                .onTapGesture {
                                    toggleSubtaskStatus(subtask)
                                }
                            
                            Text(subtask.title)
                                .font(.caption)
                                .strikethrough(subtask.status == .completed)
                                .foregroundColor(subtask.status == .completed ? .secondary : .primary)
                            
                            Spacer()
                        }
                        .padding(.leading, 20)
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
        .sheet(isPresented: $showingEditTask) {
            EditTaskView(task: task)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button("Edit") {
                showingEditTask = true
            }
            .tint(.blue)
            
            Button("Delete", role: .destructive) {
                deleteTask()
            }
        }
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            Button(task.status == .completed ? "Uncomplete" : "Complete") {
                toggleTaskStatus()
            }
            .tint(task.status == .completed ? .orange : .green)
        }
    }
    
    private func toggleTaskStatus() {
        withAnimation(.easeInOut(duration: 0.2)) {
            if task.status == .completed {
                task.status = .pending
                task.completedAt = nil
            } else {
                task.status = .completed
                task.completedAt = Date()
            }
        }
    }
    
    private func toggleSubtaskStatus(_ subtask: WorkTask) {
        withAnimation(.easeInOut(duration: 0.2)) {
            if subtask.status == .completed {
                subtask.status = .pending
                subtask.completedAt = nil
            } else {
                subtask.status = .completed
                subtask.completedAt = Date()
            }
        }
    }
    
    private func deleteTask() {
        withAnimation {
            modelContext.delete(task)
        }
    }
    
    private func isOverdue(_ date: Date) -> Bool {
        return date < Date() && task.status != .completed
    }
}

struct PriorityBadge: View {
    let priority: TaskPriority
    
    var body: some View {
        Text(priority.rawValue)
            .font(.caption2)
            .fontWeight(.semibold)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(priority.color.opacity(0.15))
            .foregroundColor(priority.color)
            .cornerRadius(4)
    }
}

#Preview {
    // We need to provide a filter for the preview
    WorkTaskView(filter: .all)
        .modelContainer(for: [WorkTask.self, Project.self], inMemory: true)
} 