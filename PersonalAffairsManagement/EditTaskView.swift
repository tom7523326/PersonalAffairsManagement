//
//  EditTaskView.swift
//  PersonalAffairsManagement
//
//  Created by 汤寿麟 on 2025/6/23.
//

import SwiftUI
import SwiftData

struct EditTaskView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let task: WorkTask
    
    @State private var title: String
    @State private var taskDescription: String
    @State private var priority: TaskPriority
    @State private var status: TaskStatus
    @State private var dueDate: Date
    @State private var hasDueDate: Bool
    
    @State private var hasReminder: Bool
    @State private var reminderDate: Date
    @State private var hasRepeat: Bool
    @State private var repeatRule: RepeatRule
    @State private var repeatInterval: Int
    
    @Query private var projects: [Project]
    @State private var selectedProject: Project?
    
    @State private var showingAddSubtask = false
    
    init(task: WorkTask) {
        self.task = task
        self._title = State(initialValue: task.title)
        self._taskDescription = State(initialValue: task.taskDescription)
        self._priority = State(initialValue: task.priority)
        self._status = State(initialValue: task.status)
        self._dueDate = State(initialValue: task.dueDate ?? Date())
        self._hasDueDate = State(initialValue: task.dueDate != nil)
        self._selectedProject = State(initialValue: task.project)
        
        self._hasReminder = State(initialValue: task.reminderDate != nil)
        self._reminderDate = State(initialValue: task.reminderDate ?? Date())
        self._hasRepeat = State(initialValue: task.repeatRule != nil)
        self._repeatRule = State(initialValue: task.repeatRule ?? .daily)
        self._repeatInterval = State(initialValue: task.repeatInterval)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Task Info") {
                    TextField("Task Title", text: $title)
                    
                    TextField("Description", text: $taskDescription, axis: .vertical)
                        .lineLimit(3...6)
                    
                    Picker("Priority", selection: $priority) {
                        ForEach(TaskPriority.allCases, id: \.self) { p in
                            Text(p.rawValue).tag(p)
                        }
                    }
                    
                    Picker("Status", selection: $status) {
                        ForEach(TaskStatus.allCases, id: \.self) { s in
                            Text(s.rawValue).tag(s)
                        }
                    }
                    
                    if task.parentTask == nil {
                        Picker("List", selection: $selectedProject) {
                            Text("Inbox").tag(nil as Project?)
                            ForEach(projects) { p in
                                Text(p.name).tag(p as Project?)
                            }
                        }
                    }
                }
                
                Section("Due Date") {
                    Toggle("Set a due date", isOn: $hasDueDate)
                    
                    if hasDueDate {
                        DatePicker("Due Date", selection: $dueDate, displayedComponents: [.date])
                    }
                }
                
                Section("Reminder") {
                    Toggle("Set a reminder", isOn: $hasReminder)
                    
                    if hasReminder {
                        DatePicker("Reminder", selection: $reminderDate, displayedComponents: [.date, .hourAndMinute])
                    }
                }
                
                Section("Repeat") {
                    Toggle("Repeat task", isOn: $hasRepeat)
                    
                    if hasRepeat {
                        Picker("Repeat every", selection: $repeatInterval) {
                            ForEach(1...30, id: \.self) { interval in
                                Text("\(interval)").tag(interval)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(height: 100)
                        
                        Picker("Repeat rule", selection: $repeatRule) {
                            ForEach(RepeatRule.allCases, id: \.self) { rule in
                                Text(rule.rawValue).tag(rule)
                            }
                        }
                    }
                }
                
                Section {
                    if let subtasks = task.subtasks, !subtasks.isEmpty {
                        ForEach(subtasks) { subtask in
                            HStack {
                                Image(systemName: subtask.status == .completed ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(subtask.status == .completed ? .green : .gray)
                                    .onTapGesture {
                                        toggleSubtaskStatus(subtask)
                                    }
                                
                                VStack(alignment: .leading) {
                                    Text(subtask.title)
                                        .strikethrough(subtask.status == .completed)
                                    if !subtask.taskDescription.isEmpty {
                                        Text(subtask.taskDescription)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .lineLimit(1)
                                    }
                                }
                                
                                Spacer()
                                
                                PriorityBadge(priority: subtask.priority)
                            }
                        }
                        .onDelete(perform: deleteSubtasks)
                    }
                    
                    Button(action: { showingAddSubtask = true }) {
                        HStack {
                            Image(systemName: "plus.circle")
                            Text("Add Subtask")
                        }
                    }
                } header: {
                    Text("Subtasks")
                } footer: {
                    if let subtasks = task.subtasks, !subtasks.isEmpty {
                        let completedCount = subtasks.filter { $0.status == .completed }.count
                        Text("\(completedCount) of \(subtasks.count) completed")
                    }
                }

                Section("Task Stats") {
                    HStack {
                        Text("Created At")
                        Spacer()
                        Text(task.createdAt.formatted(date: .abbreviated, time: .shortened))
                            .foregroundColor(.secondary)
                    }
                    
                    if let completedAt = task.completedAt {
                        HStack {
                            Text("Completed At")
                            Spacer()
                            Text(completedAt.formatted(date: .abbreviated, time: .shortened))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(title.isEmpty)
                }
            }
            .sheet(isPresented: $showingAddSubtask) {
                AddTaskView(parentTask: task)
            }
        }
    }
    
    private func toggleSubtaskStatus(_ subtask: WorkTask) {
        if subtask.status == .completed {
            subtask.status = .pending
            subtask.completedAt = nil
        } else {
            subtask.status = .completed
            subtask.completedAt = Date()
        }
    }
    
    private func deleteSubtasks(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                if let subtasks = task.subtasks {
                    modelContext.delete(subtasks[index])
                }
            }
        }
    }
    
    private func saveChanges() {
        task.title = title
        task.taskDescription = taskDescription
        task.priority = priority
        task.status = status
        task.project = selectedProject
        task.dueDate = hasDueDate ? dueDate : nil
        
        task.reminderDate = hasReminder ? reminderDate : nil
        task.repeatRule = hasRepeat ? repeatRule : nil
        task.repeatInterval = repeatInterval
        
        if status == .completed && task.completedAt == nil {
            task.completedAt = Date()
        }
        
        if status != .completed {
            task.completedAt = nil
        }
        
        dismiss()
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: WorkTask.self, configurations: config)
    let task = WorkTask(title: "示例任务", taskDescription: "这是一个示例任务")
    
    return EditTaskView(task: task)
        .modelContainer(container)
} 