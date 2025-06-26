// PomodoroView.swift
// PersonalAffairsManagement
//
// Created by 汤寿麟 on 2025/7/1.

import SwiftUI
import SwiftData

struct PomodoroView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WorkTask.createdAt, order: .reverse) private var tasks: [WorkTask]
    
    @State private var selectedTask: WorkTask?
    @State private var isRunning = false
    @State private var timeRemaining: Int = 25 * 60 // 25 minutes in seconds
    @State private var timer: Timer? = nil
    @State private var showCompletion = false
    @State private var showTaskSelection = false
    @State private var customTaskName = ""
    @State private var isCustomTask = false
    
    private let pomodoroDuration = 25 * 60
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                // 任务选择区域
                taskSelectionSection
                
                // 任务信息显示
                taskInfoSection
                
                // 倒计时显示
                timerDisplaySection
                
                // 控制按钮
                controlButtonsSection
                
                Spacer()
            }
            .padding()
            .navigationTitle("番茄专注")
            .navigationBarTitleDisplayMode(.large)
            .alert("番茄完成！", isPresented: $showCompletion) {
                Button("确定", action: resetTimer)
            } message: {
                Text("恭喜你完成了一个番茄专注！")
            }
            .sheet(isPresented: $showTaskSelection) {
                taskSelectionSheet
            }
            .onDisappear {
                timer?.invalidate()
            }
        }
    }
    
    // MARK: - 任务选择区域
    private var taskSelectionSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("专注任务")
                    .font(.headline)
                    .foregroundColor(DesignSystem.Colors.text)
                Spacer()
                Button(action: { showTaskSelection = true }) {
                    Label("选择任务", systemImage: "plus.circle.fill")
                        .font(.subheadline)
                        .foregroundColor(DesignSystem.Colors.primary)
                }
            }
            
            if let task = selectedTask {
                // 显示选中的任务
                HStack {
                    Circle()
                        .fill(Color(hex: task.project?.colorHex ?? "") ?? DesignSystem.Colors.primary)
                        .frame(width: 12, height: 12)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(task.title)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(DesignSystem.Colors.text)
                        
                        if let project = task.project {
                            Text(project.name)
                                .font(.caption)
                                .foregroundColor(DesignSystem.Colors.secondaryText)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: { selectedTask = nil }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(DesignSystem.Colors.secondaryBackground)
                .cornerRadius(12)
            } else if isCustomTask && !customTaskName.isEmpty {
                // 显示自定义任务
                HStack {
                    Circle()
                        .fill(DesignSystem.Colors.primary)
                        .frame(width: 12, height: 12)
                    
                    Text(customTaskName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(DesignSystem.Colors.text)
                    
                    Spacer()
                    
                    Button(action: { 
                        selectedTask = nil
                        isCustomTask = false
                        customTaskName = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(DesignSystem.Colors.secondaryBackground)
                .cornerRadius(12)
            } else {
                // 显示默认提示
                HStack {
                    Image(systemName: "timer")
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                    Text("选择任务或直接开始专注")
                        .font(.subheadline)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                    Spacer()
                }
                .padding()
                .background(DesignSystem.Colors.secondaryBackground)
                .cornerRadius(12)
            }
        }
    }
    
    // MARK: - 任务信息显示
    private var taskInfoSection: some View {
        Group {
            if let task = selectedTask {
                VStack(spacing: 8) {
                    Text(task.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(DesignSystem.Colors.text)
                    
                    if !task.taskDescription.isEmpty {
                        Text(task.taskDescription)
                            .font(.body)
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                    }
                    
                    if let project = task.project {
                        HStack {
                            Circle()
                                .fill(Color(hex: project.colorHex ?? "") ?? DesignSystem.Colors.primary)
                                .frame(width: 8, height: 8)
                            Text(project.name)
                                .font(.caption)
                                .foregroundColor(DesignSystem.Colors.secondaryText)
                        }
                    }
                }
            } else if isCustomTask && !customTaskName.isEmpty {
                VStack(spacing: 8) {
                    Text(customTaskName)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(DesignSystem.Colors.text)
                    
                    Text("自定义专注任务")
                        .font(.caption)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }
            } else {
                VStack(spacing: 8) {
                    Text("自由专注")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(DesignSystem.Colors.text)
                    
                    Text("专注于当前最重要的事情")
                        .font(.body)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                        .multilineTextAlignment(.center)
                }
            }
        }
    }
    
    // MARK: - 倒计时显示
    private var timerDisplaySection: some View {
        VStack(spacing: 16) {
            Text(timeString)
                .font(.system(size: 72, weight: .bold, design: .monospaced))
                .foregroundColor(isRunning ? DesignSystem.Colors.primary : DesignSystem.Colors.text)
                .animation(.easeInOut(duration: 0.3), value: isRunning)
            
            // 进度条
            ProgressView(value: Double(pomodoroDuration - timeRemaining), total: Double(pomodoroDuration))
                .progressViewStyle(LinearProgressViewStyle(tint: DesignSystem.Colors.primary))
                .scaleEffect(x: 1, y: 2, anchor: .center)
        }
        .padding()
    }
    
    // MARK: - 控制按钮
    private var controlButtonsSection: some View {
        HStack(spacing: 24) {
            Button(action: startTimer) {
                Label(isRunning ? "继续" : "开始", systemImage: isRunning ? "play.fill" : "play.fill")
                    .font(.headline)
                    .frame(minWidth: 100)
            }
            .buttonStyle(.borderedProminent)
            .disabled(isRunning)
            
            Button(action: pauseTimer) {
                Label("暂停", systemImage: "pause.fill")
                    .font(.headline)
                    .frame(minWidth: 100)
            }
            .buttonStyle(.bordered)
            .disabled(!isRunning)
            
            Button(action: resetTimer) {
                Label("重置", systemImage: "arrow.counterclockwise")
                    .font(.headline)
                    .frame(minWidth: 100)
            }
            .buttonStyle(.bordered)
        }
    }
    
    // MARK: - 任务选择弹窗
    private var taskSelectionSheet: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 自定义任务输入
                VStack(alignment: .leading, spacing: 8) {
                    Text("自定义任务")
                        .font(.headline)
                        .foregroundColor(DesignSystem.Colors.text)
                    
                    HStack {
                        TextField("输入任务名称", text: $customTaskName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button("确定") {
                            if !customTaskName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                isCustomTask = true
                                selectedTask = nil
                                showTaskSelection = false
                            }
                        }
                        .disabled(customTaskName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding()
                .background(DesignSystem.Colors.secondaryBackground)
                .cornerRadius(12)
                
                // 现有任务列表
                VStack(alignment: .leading, spacing: 8) {
                    Text("选择现有任务")
                        .font(.headline)
                        .foregroundColor(DesignSystem.Colors.text)
                    
                    if tasks.isEmpty {
                        Text("暂无任务，请先创建任务")
                            .font(.subheadline)
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                            .padding()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 8) {
                                ForEach(tasks) { task in
                                    Button(action: {
                                        selectedTask = task
                                        isCustomTask = false
                                        customTaskName = ""
                                        showTaskSelection = false
                                    }) {
                                        HStack {
                                            Circle()
                                                .fill(Color(hex: task.project?.colorHex ?? "") ?? DesignSystem.Colors.primary)
                                                .frame(width: 12, height: 12)
                                            
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(task.title)
                                                    .font(.subheadline)
                                                    .fontWeight(.medium)
                                                    .foregroundColor(DesignSystem.Colors.text)
                                                
                                                if let project = task.project {
                                                    Text(project.name)
                                                        .font(.caption)
                                                        .foregroundColor(DesignSystem.Colors.secondaryText)
                                                }
                                            }
                                            
                                            Spacer()
                                            
                                            if task.status == .pending {
                                                Text("待处理")
                                                    .font(.caption)
                                                    .foregroundColor(DesignSystem.Colors.warning)
                                            }
                                        }
                                        .padding()
                                        .background(DesignSystem.Colors.secondaryBackground)
                                        .cornerRadius(8)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        .frame(maxHeight: 300)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("选择专注任务")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("取消") {
                        showTaskSelection = false
                    }
                }
            }
        }
    }
    
    // MARK: - 辅助方法
    private var timeString: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func startTimer() {
        guard !isRunning else { return }
        isRunning = true
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer?.invalidate()
                isRunning = false
                showCompletion = true
            }
        }
    }
    
    private func pauseTimer() {
        isRunning = false
        timer?.invalidate()
    }
    
    private func resetTimer() {
        isRunning = false
        timer?.invalidate()
        timeRemaining = pomodoroDuration
    }
}

#Preview {
    PomodoroView()
        .modelContainer(for: [WorkTask.self], inMemory: true)
} 