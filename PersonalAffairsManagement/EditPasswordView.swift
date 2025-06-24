//
//  EditPasswordView.swift
//  PersonalAffairsManagement
//
//  Created by 汤寿麟 on 2025/6/23.
//

import SwiftUI
import SwiftData

struct EditPasswordView: View {
    let password: PasswordEntry
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String
    @State private var username: String
    @State private var passwordText: String
    @State private var website: String
    @State private var notes: String
    @State private var category: PasswordCategory
    @State private var isPasswordVisible = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    init(password: PasswordEntry) {
        self.password = password
        self._title = State(initialValue: password.title)
        self._username = State(initialValue: password.username)
        self._passwordText = State(initialValue: password.password)
        self._website = State(initialValue: password.website ?? "")
        self._notes = State(initialValue: password.notes ?? "")
        self._category = State(initialValue: password.category)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("基本信息") {
                    TextField("标题", text: $title)
                    TextField("用户名", text: $username)
                    
                    HStack {
                        if isPasswordVisible {
                            TextField("密码", text: $passwordText)
                        } else {
                            SecureField("密码", text: $passwordText)
                        }
                        
                        Button(action: { isPasswordVisible.toggle() }) {
                            Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                Section("详细信息") {
                    TextField("网站地址 (可选)", text: $website)
                    
                    Picker("分类", selection: $category) {
                        ForEach(PasswordCategory.allCases, id: \.self) { category in
                            HStack {
                                Image(systemName: category.icon)
                                    .foregroundColor(category.color)
                                Text(category.rawValue)
                            }
                            .tag(category)
                        }
                    }
                }
                
                Section("备注") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
                
                Section {
                    Button("生成随机密码") {
                        passwordText = generateRandomPassword()
                    }
                    .foregroundColor(.blue)
                }
            }
            .navigationTitle("编辑密码")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveChanges()
                    }
                    .disabled(title.isEmpty || username.isEmpty || passwordText.isEmpty)
                }
            }
            .alert("提示", isPresented: $showingAlert) {
                Button("确定") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func saveChanges() {
        guard !title.isEmpty && !username.isEmpty && !passwordText.isEmpty else {
            alertMessage = "请填写必填字段"
            showingAlert = true
            return
        }
        
        password.title = title
        password.username = username
        password.password = passwordText
        password.website = website.isEmpty ? nil : website
        password.notes = notes.isEmpty ? nil : notes
        password.category = category
        password.updatedAt = Date()
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            alertMessage = "保存失败: \(error.localizedDescription)"
            showingAlert = true
        }
    }
    
    private func generateRandomPassword() -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let numbers = "0123456789"
        let symbols = "!@#$%^&*()_+-=[]{}|;:,.<>?"
        
        let allCharacters = letters + numbers + symbols
        let passwordLength = 12
        
        var password = ""
        
        // 确保至少包含一个大写字母、一个小写字母、一个数字和一个符号
        password += String(letters.randomElement() ?? "a")
        password += String(letters.uppercased().randomElement() ?? "A")
        password += String(numbers.randomElement() ?? "0")
        password += String(symbols.randomElement() ?? "!")
        
        // 填充剩余长度
        for _ in 4..<passwordLength {
            password += String(allCharacters.randomElement() ?? "a")
        }
        
        // 打乱密码字符顺序
        return String(password.shuffled())
    }
}

#Preview {
    let password = PasswordEntry(
        title: "示例密码",
        username: "user@example.com",
        password: "password123",
        website: "https://example.com",
        notes: "这是一个示例密码",
        category: .email
    )
    
    EditPasswordView(password: password)
        .modelContainer(for: [PasswordEntry.self], inMemory: true)
} 