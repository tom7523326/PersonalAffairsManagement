//
//  PasswordBoxView.swift
//  PersonalAffairsManagement
//
//  Created by 汤寿麟 on 2025/6/23.
//

import SwiftUI
import SwiftData

struct PasswordBoxView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PasswordEntry.title) private var passwords: [PasswordEntry]
    @State private var searchText = ""
    @State private var selectedCategory: PasswordCategory? = nil
    @State private var showingAddPassword = false
    @State private var showingPasswordDetail: PasswordEntry? = nil
    
    var filteredPasswords: [PasswordEntry] {
        if searchText.isEmpty {
            return passwords
        } else {
            return passwords.filter { $0.title.localizedCaseInsensitiveContains(searchText) || $0.username.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if passwords.isEmpty {
                    ContentUnavailableView("没有密码", systemImage: "lock.shield", description: Text("你可以在这里安全地保存你的密码。"))
                } else {
                    VStack {
                        // Search and filter bar
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.gray)
                                TextField("搜索密码...", text: $searchText)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    FilterChip(title: "全部", isSelected: selectedCategory == nil) {
                                        selectedCategory = nil
                                    }
                                    
                                    ForEach(PasswordCategory.allCases, id: \.self) { category in
                                        FilterChip(title: category.rawValue, isSelected: selectedCategory == category) {
                                            selectedCategory = selectedCategory == category ? nil : category
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Password list
                        List {
                            ForEach(filteredPasswords) { password in
                                PasswordRowView(password: password) {
                                    showingPasswordDetail = password
                                }
                            }
                            .onDelete(perform: deletePasswords)
                        }
                        .listStyle(InsetGroupedListStyle())
                    }
                }
            }
            .navigationTitle("密码箱")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "搜索密码或用户名")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddPassword = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddPassword) {
                AddPasswordView()
            }
            .sheet(item: $showingPasswordDetail) { password in
                PasswordDetailView(password: password)
            }
        }
    }
    
    private func deletePasswords(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(filteredPasswords[index])
        }
    }
}

struct PasswordRowView: View {
    let password: PasswordEntry
    let onTap: () -> Void
    @State private var isPasswordVisible = false
    
    var body: some View {
        HStack {
            Image(systemName: password.category.icon)
                .foregroundColor(password.category.color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(password.title)
                    .font(.headline)
                
                Text(password.username)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if let website = password.website {
                    Text(website)
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                if isPasswordVisible {
                    Text(password.password)
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text(String(repeating: "•", count: min(password.password.count, 8)))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Button(action: { isPasswordVisible.toggle() }) {
                    Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
    }
}

#Preview {
    PasswordBoxView()
        .modelContainer(for: [PasswordEntry.self], inMemory: true)
} 