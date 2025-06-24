import SwiftUI
import SwiftData

struct AddProjectView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var selectedColorHex: String = "808080" // Default to gray
    
    // 状态管理
    @StateObject private var formValidator = FormValidator()
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isSuccess = false
    @State private var isSaving = false
    
    let colors: [String] = [
        "FF3B30", "FF9500", "FFCC00", "34C759", "00C7BE", "30B0C7",
        "32ADE6", "007AFF", "5856D6", "AF52DE", "FF2D55", "A2845E",
        "8E8E93"
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("项目信息")) {
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("项目名称", text: $name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        if let error = formValidator.getError(for: "name") {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                }
                
                Section(header: Text("项目颜色")) {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 12) {
                        ForEach(colors, id: \.self) { colorHex in
                            Button(action: {
                                selectedColorHex = colorHex
                            }) {
                                ColorCircle(colorHex: colorHex, isSelected: selectedColorHex == colorHex)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("添加项目")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveProject()
                    }
                    .disabled(isSaving || !isFormValid)
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
    
    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func saveProject() {
        // 验证输入
        let validations = [
            "name": InputValidator.validateTitle(name.trimmingCharacters(in: .whitespacesAndNewlines), fieldName: "项目名称")
        ]
        
        guard formValidator.validateForm(validations) else {
            return
        }
        
        isSaving = true
        
        Task {
            do {
                let newProject = Project(
                    name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                    colorHex: selectedColorHex
                )
                
                modelContext.insert(newProject)
                try modelContext.save()
                
                await MainActor.run {
                    isSaving = false
                    alertMessage = "项目保存成功！"
                    isSuccess = true
                    showingAlert = true
                }
            } catch {
                await MainActor.run {
                    isSaving = false
                    ErrorHandler.shared.handle(AppError.dataError("保存项目失败: \(error.localizedDescription)"))
                }
            }
        }
    }
}

struct ColorCircle: View {
    let colorHex: String
    let isSelected: Bool

    var body: some View {
        Circle()
            .fill(Color(hex: colorHex) ?? .gray)
            .frame(width: 40, height: 40)
            .overlay(
                Circle()
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 3)
            )
    }
}

#Preview {
    AddProjectView()
        .modelContainer(for: [Project.self], inMemory: true)
} 