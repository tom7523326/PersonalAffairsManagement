//
//  AddTaskView.swift
//  PersonalAffairsManagement
//
//  Created by 汤寿麟 on 2025/6/23.
//

import SwiftUI
import SwiftData

struct AddTaskView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var taskDescription = ""
    @State private var priority = TaskPriority.medium
    @State private var dueDate: Date = Date()
    @State private var hasDueDate = false
    
    // Reminder and repeat states
    @State private var hasReminder = false
    @State private var reminderDate: Date = Date()
    @State private var hasRepeat = false
    @State private var repeatRule: RepeatRule = .daily
    @State private var repeatInterval: Int = 1
    
    // 状态管理
    @StateObject private var formValidator = FormValidator()
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isSuccess = false
    @State private var isSaving = false
    
    // Allow providing a project directly
    var project: Project?
    
    // Allow creating subtasks
    var parentTask: WorkTask?
    
    // Allow preset due date (for calendar view)
    var presetDueDate: Date?
    
    // For the project picker
    @Query private var projects: [Project]
    @State private var selectedProject: Project?
    
    var body: some View {
        NavigationStack {
            Form {
                basicInfoSection
                dueDateSection
                reminderSection
                repeatSection
                projectSection
            }
            .navigationTitle("添加任务")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveTask()
                    }
                    .disabled(isSaving || !isFormValid)
                }
            }
            .onAppear {
                if let presetDueDate = presetDueDate {
                    dueDate = presetDueDate
                    hasDueDate = true
                }
            }
            .alert("提示", isPresented: $showingAlert) {
                Button("确定") {
                    if isSuccess {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
            .loadingState(isSaving, message: "保存中...")
        }
    }
    
    private var basicInfoSection: some View {
        Section(header: Text("基本信息")) {
            VStack(alignment: .leading, spacing: 4) {
                TextField("任务标题", text: $title)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                if let error = formValidator.getError(for: "title") {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                TextField("任务描述", text: $taskDescription, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(3...6)
                
                if let error = formValidator.getError(for: "description") {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            
            Picker("优先级", selection: $priority) {
                ForEach(TaskPriority.allCases, id: \.self) { priority in
                    HStack {
                        Circle()
                            .fill(priority.color)
                            .frame(width: 12, height: 12)
                        Text(priority.rawValue)
                    }
                    .tag(priority)
                }
            }
        }
    }
    
    private var dueDateSection: some View {
        Section(header: Text("截止日期")) {
            Toggle("设置截止日期", isOn: $hasDueDate)
            
            if hasDueDate {
                DatePicker("截止日期", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
            }
        }
    }
    
    private var reminderSection: some View {
        Section(header: Text("提醒")) {
            Toggle("设置提醒", isOn: $hasReminder)
            
            if hasReminder {
                DatePicker("提醒时间", selection: $reminderDate, displayedComponents: [.date, .hourAndMinute])
            }
        }
    }
    
    private var repeatSection: some View {
        Section(header: Text("重复")) {
            Toggle("重复任务", isOn: $hasRepeat)
            
            if hasRepeat {
                Picker("重复规则", selection: $repeatRule) {
                    ForEach(RepeatRule.allCases, id: \.self) { rule in
                        Text(rule.rawValue).tag(rule)
                    }
                }
                
                Stepper("间隔: \(repeatInterval)", value: $repeatInterval, in: 1...30)
            }
        }
    }
    
    private var projectSection: some View {
        Group {
            if let project = project {
                Section("项目") {
                    HStack {
                        Circle()
                            .fill(Color(hex: project.colorHex) ?? .gray)
                            .frame(width: 20, height: 20)
                        Text(project.name)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func saveTask() {
        // 验证输入
        let validations = [
            "title": InputValidator.validateTitle(title.trimmingCharacters(in: .whitespacesAndNewlines)),
            "description": InputValidator.validateDescription(taskDescription)
        ]
        
        guard formValidator.validateForm(validations) else {
            return
        }
        
        isSaving = true
        
        Task {
            do {
                let newTask = WorkTask(
                    title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                    taskDescription: taskDescription.trimmingCharacters(in: .whitespacesAndNewlines),
                    priority: priority,
                    dueDate: hasDueDate ? dueDate : nil,
                    project: project
                )
                newTask.reminderDate = hasReminder ? reminderDate : nil
                newTask.repeatRule = hasRepeat ? repeatRule : nil
                newTask.repeatInterval = hasRepeat ? repeatInterval : 1
                newTask.parentTask = parentTask
                newTask.status = .pending
                
                modelContext.insert(newTask)
                try modelContext.save()
                
                await MainActor.run {
                    isSaving = false
                    alertMessage = "任务保存成功！"
                    isSuccess = true
                    showingAlert = true
                }
            } catch {
                await MainActor.run {
                    isSaving = false
                    ErrorHandler.shared.handle(AppError.dataError("保存任务失败: \(error.localizedDescription)"))
                }
            }
        }
    }
}

#Preview {
    AddTaskView()
        .modelContainer(for: [WorkTask.self, Project.self], inMemory: true)
} 