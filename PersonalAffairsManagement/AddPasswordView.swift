//
//  AddPasswordView.swift
//  PersonalAffairsManagement
//
//  Created by 汤寿麟 on 2025/6/23.
//

import SwiftUI
import SwiftData

struct AddPasswordView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var username = ""
    @State private var password = ""
    @State private var website = ""
    @State private var notes = ""
    @State private var category: PasswordCategory = .other
    @State private var isPasswordVisible = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("基本信息") {
                    TextField("标题", text: $title)
                    TextField("用户名", text: $username)
                    
                    HStack {
                        if isPasswordVisible {
                            TextField("密码", text: $password)
                        } else {
                            SecureField("密码", text: $password)
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
                        password = generateRandomPassword()
                    }
                    .foregroundColor(.blue)
                }
            }
            .navigationTitle("添加密码")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        savePassword()
                    }
                    .disabled(title.isEmpty || username.isEmpty || password.isEmpty)
                }
            }
            .alert("提示", isPresented: $showingAlert) {
                Button("确定") {
                    if alertMessage.contains("成功") {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func savePassword() {
        guard !title.isEmpty && !username.isEmpty && !password.isEmpty else {
            alertMessage = "请填写必填字段"
            showingAlert = true
            return
        }
        
        let newPassword = PasswordEntry(
            title: title,
            username: username,
            password: password,
            website: website.isEmpty ? nil : website,
            notes: notes.isEmpty ? nil : notes,
            category: category
        )
        
        modelContext.insert(newPassword)
        
        do {
            try modelContext.save()
            alertMessage = "密码保存成功！"
            showingAlert = true
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
    AddPasswordView()
        .modelContainer(for: [PasswordEntry.self], inMemory: true)
} 