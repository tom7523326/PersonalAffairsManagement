//
//  PasswordDetailView.swift
//  PersonalAffairsManagement
//
//  Created by 汤寿麟 on 2025/6/23.
//

import SwiftUI
import SwiftData

struct PasswordDetailView: View {
    let password: PasswordEntry
    @Environment(\.dismiss) private var dismiss
    @State private var isPasswordVisible = false
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    @State private var showingCopiedAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    PasswordHeaderView(password: password)
                    PasswordInfoSection(password: password, isPasswordVisible: $isPasswordVisible, onCopy: copyToClipboard)
                    
                    if let website = password.website {
                        WebsiteInfoSection(website: website)
                    }
                    
                    if let notes = password.notes, !notes.isEmpty {
                        NotesSection(notes: notes)
                    }
                    
                    MetadataSection(password: password)
                }
                .padding()
            }
            .navigationTitle("密码详情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("关闭") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { showingEditSheet = true }) {
                            Label("编辑", systemImage: "pencil")
                        }
                        
                        Button(action: { showingDeleteAlert = true }) {
                            Label("删除", systemImage: "trash")
                        }
                        .foregroundColor(.red)
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingEditSheet) {
                EditPasswordView(password: password)
            }
            .alert("删除密码", isPresented: $showingDeleteAlert) {
                Button("取消", role: .cancel) { }
                Button("删除", role: .destructive) {
                    deletePassword()
                }
            } message: {
                Text("确定要删除这个密码吗？此操作无法撤销。")
            }
            .alert("已复制", isPresented: $showingCopiedAlert) {
                Button("确定") { }
            } message: {
                Text("密码已复制到剪贴板")
            }
        }
    }
    
    private func copyToClipboard() {
        UIPasteboard.general.string = password.password
        showingCopiedAlert = true
    }
    
    private func deletePassword() {
        // This would need to be implemented with proper model context
        dismiss()
    }
}

struct PasswordHeaderView: View {
    let password: PasswordEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: password.category.icon)
                    .foregroundColor(password.category.color)
                    .font(.title2)
                
                Text(password.title)
                    .font(.title)
                    .fontWeight(.bold)
            }
            
            Text(password.category.rawValue)
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(password.category.color.opacity(0.2))
                .cornerRadius(8)
        }
    }
}

struct PasswordInfoSection: View {
    let password: PasswordEntry
    @Binding var isPasswordVisible: Bool
    let onCopy: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("密码信息")
                .font(.headline)
            
            InfoRow(title: "用户名", value: password.username, canCopy: true)
            
            HStack {
                Text("密码")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if isPasswordVisible {
                    Text(password.password)
                        .font(.subheadline)
                        .monospaced()
                } else {
                    Text(String(repeating: "•", count: min(password.password.count, 12)))
                        .font(.subheadline)
                        .monospaced()
                }
                
                Button(action: { isPasswordVisible.toggle() }) {
                    Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                        .foregroundColor(.blue)
                }
                
                Button(action: onCopy) {
                    Image(systemName: "doc.on.doc")
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
    }
}

struct WebsiteInfoSection: View {
    let website: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("网站信息")
                .font(.headline)
            
            InfoRow(title: "网站地址", value: website, canCopy: true, isLink: true)
        }
    }
}

struct NotesSection: View {
    let notes: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("备注")
                .font(.headline)
            
            Text(notes)
                .font(.body)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
        }
    }
}

struct MetadataSection: View {
    let password: PasswordEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("创建信息")
                .font(.headline)
            
            InfoRow(title: "创建时间", value: formatDate(password.createdAt))
            InfoRow(title: "更新时间", value: formatDate(password.updatedAt))
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
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
    
    PasswordDetailView(password: password)
} 