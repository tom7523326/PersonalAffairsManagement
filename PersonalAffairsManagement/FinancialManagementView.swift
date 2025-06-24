//
//  FinancialManagementView.swift
//  PersonalAffairsManagement
//
//  Created by 汤寿麟 on 2025/6/23.
//

import SwiftUI
import SwiftData

struct FinancialManagementView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var records: [FinancialRecord]
    @Query private var budgets: [Budget]
    
    @State private var showingAddRecord = false
    @State private var showingAddBudget = false
    @State private var selectedTab = 0
    
    var totalIncome: Double {
        records.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
    }
    
    var totalExpense: Double {
        records.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
    }
    
    var balance: Double {
        totalIncome - totalExpense
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // 财务概览卡片
                FinancialOverviewCard(
                    income: totalIncome,
                    expense: totalExpense,
                    balance: balance
                )
                .padding()
                
                // 标签页
                Picker("", selection: $selectedTab) {
                    Text("收支记录").tag(0)
                    Text("预算管理").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                if selectedTab == 0 {
                    FinancialRecordsView(records: records)
                } else {
                    BudgetManagementView(budgets: budgets)
                }
            }
            .navigationTitle("财务管理")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if selectedTab == 0 {
                            showingAddRecord = true
                        } else {
                            showingAddBudget = true
                        }
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddRecord) {
                AddFinancialRecordView()
            }
            .sheet(isPresented: $showingAddBudget) {
                AddBudgetView()
            }
        }
    }
}

struct FinancialOverviewCard: View {
    let income: Double
    let expense: Double
    let balance: Double
    
    var body: some View {
        VStack(spacing: 16) {
            Text("财务概览")
                .font(.headline)
                .foregroundColor(.secondary)
            
            HStack(spacing: 20) {
                VStack {
                    Text("收入")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("¥\(income, specifier: "%.2f")")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
                
                VStack {
                    Text("支出")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("¥\(expense, specifier: "%.2f")")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                }
                
                VStack {
                    Text("余额")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("¥\(balance, specifier: "%.2f")")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(balance >= 0 ? .primary : .red)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct FinancialRecordsView: View {
    @Environment(\.modelContext) private var modelContext
    let records: [FinancialRecord]
    @State private var selectedFilter: TransactionType? = nil
    
    var filteredRecords: [FinancialRecord] {
        if let filter = selectedFilter {
            return records.filter { $0.type == filter }
        }
        return records
    }
    
    var body: some View {
        VStack {
            // 过滤器
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    Button(action: { selectedFilter = nil }) {
                        Text("全部")
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(selectedFilter == nil ? Color.blue : Color.gray.opacity(0.2))
                            .foregroundColor(selectedFilter == nil ? .white : .primary)
                            .cornerRadius(16)
                    }
                    
                    ForEach(TransactionType.allCases, id: \.self) { type in
                        Button(action: { selectedFilter = type }) {
                            Text(type.rawValue)
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(selectedFilter == type ? Color.blue : Color.gray.opacity(0.2))
                                .foregroundColor(selectedFilter == type ? .white : .primary)
                                .cornerRadius(16)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 8)
            
            // 记录列表
            List {
                ForEach(filteredRecords) { record in
                    FinancialRecordRowView(record: record)
                }
                .onDelete(perform: deleteRecords)
            }
        }
    }
    
    private func deleteRecords(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(filteredRecords[index])
            }
        }
    }
}

struct FinancialRecordRowView: View {
    let record: FinancialRecord
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(record.title)
                    .font(.headline)
                Text(record.category.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("\(record.type == .income ? "+" : "-")¥\(record.amount, specifier: "%.2f")")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(record.type == .income ? .green : .red)
                
                Text(record.type.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color(record.type.color).opacity(0.2))
                    .foregroundColor(Color(record.type.color))
                    .cornerRadius(4)
            }
        }
        .padding(.vertical, 4)
    }
}

struct BudgetManagementView: View {
    @Environment(\.modelContext) private var modelContext
    let budgets: [Budget]
    
    var body: some View {
        List {
            ForEach(budgets) { budget in
                BudgetRowView(budget: budget)
            }
            .onDelete(perform: deleteBudgets)
        }
    }
    
    private func deleteBudgets(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(budgets[index])
            }
        }
    }
}

struct BudgetRowView: View {
    let budget: Budget
    
    var progress: Double {
        budget.amount > 0 ? budget.spent / budget.amount : 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(budget.name)
                    .font(.headline)
                
                Spacer()
                
                Text(budget.category.description)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.2))
                    .foregroundColor(.blue)
                    .cornerRadius(4)
            }
            
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: progress > 0.8 ? .red : .blue))
            
            HStack {
                Text(budget.period.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("¥\(budget.spent, specifier: "%.2f") / ¥\(budget.amount, specifier: "%.2f")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    FinancialManagementView()
        .modelContainer(for: [FinancialRecord.self, Budget.self], inMemory: true)
} 