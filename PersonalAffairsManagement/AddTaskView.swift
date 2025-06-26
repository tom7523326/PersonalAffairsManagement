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
                
                // 调试信息
                print("[AddTaskView] 视图已加载")
                print("[AddTaskView] 可用项目数量: \(projects.count)")
                print("[AddTaskView] 传入的项目: \(project?.name ?? "无")")
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
        Section(header: Text("项目")) {
            if let project = project {
                // 如果直接传入了项目，显示项目信息
                HStack {
                    Circle()
                        .fill(Color(hex: project.colorHex) ?? .gray)
                        .frame(width: 20, height: 20)
                    Text(project.name)
                        .foregroundColor(.secondary)
                }
            } else {
                // 如果没有直接传入项目，显示项目选择器
                Picker("选择项目", selection: $selectedProject) {
                    Text("无项目").tag(nil as Project?)
                    ForEach(projects) { project in
                        HStack {
                            Circle()
                                .fill(Color(hex: project.colorHex) ?? .gray)
                                .frame(width: 12, height: 12)
                            Text(project.name)
                        }
                        .tag(project as Project?)
                    }
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func saveTask() {
        print("[AddTaskView] 开始保存任务")
        print("[AddTaskView] 标题: '\(title)'")
        print("[AddTaskView] 描述: '\(taskDescription)'")
        print("[AddTaskView] 优先级: \(priority)")
        print("[AddTaskView] 项目: \(project?.name ?? selectedProject?.name ?? "无")")
        
        // 验证输入
        let validations = [
            "title": InputValidator.validateTitle(title.trimmingCharacters(in: .whitespacesAndNewlines)),
            "description": InputValidator.validateDescription(taskDescription)
        ]
        
        print("[AddTaskView] 验证结果: \(validations)")
        
        guard formValidator.validateForm(validations) else {
            print("[AddTaskView] 验证失败，错误: \(formValidator.errors)")
            return
        }
        
        print("[AddTaskView] 验证通过，开始保存")
        isSaving = true
        
        Task {
            do {
                // 使用传入的project或用户选择的project
                let finalProject = project ?? selectedProject
                print("[AddTaskView] 最终项目: \(finalProject?.name ?? "无")")
                
                let newTask = WorkTask(
                    title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                    taskDescription: taskDescription.trimmingCharacters(in: .whitespacesAndNewlines),
                    priority: priority,
                    dueDate: hasDueDate ? dueDate : nil,
                    project: finalProject
                )
                newTask.reminderDate = hasReminder ? reminderDate : nil
                newTask.repeatRule = hasRepeat ? repeatRule : nil
                newTask.repeatInterval = hasRepeat ? repeatInterval : 1
                newTask.parentTask = parentTask
                newTask.status = .pending
                
                print("[AddTaskView] 任务对象创建成功: \(newTask.title)")
                print("[AddTaskView] 任务ID: \(newTask.id)")
                
                modelContext.insert(newTask)
                print("[AddTaskView] 任务已插入到ModelContext")
                
                try modelContext.save()
                print("[AddTaskView] ModelContext保存成功")
                
                await MainActor.run {
                    isSaving = false
                    alertMessage = "任务保存成功！"
                    isSuccess = true
                    showingAlert = true
                    print("[AddTaskView] 保存完成，显示成功提示")
                }
            } catch {
                print("[AddTaskView] 保存失败: \(error)")
                print("[AddTaskView] 错误详情: \(error.localizedDescription)")
                
                await MainActor.run {
                    isSaving = false
                    alertMessage = "保存失败: \(error.localizedDescription)"
                    showingAlert = true
                }
            }
        }
    }
}

#Preview {
    AddTaskView()
        .modelContainer(for: [WorkTask.self, Project.self], inMemory: true)
} 