//
//  AddBudgetView.swift
//  PersonalAffairsManagement
//
//  Created by 汤寿麟 on 2025/6/23.
//
import SwiftUI
import SwiftData

struct AddBudgetView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var amount: Double = 0.0
    @State private var period: BudgetPeriod = .monthly
    @State private var category: FinancialCategory = .food
    @State private var startDate = Date()
    
    // 添加状态管理
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isSuccess = false

    var body: some View {
        NavigationStack {
            Form {
                Section("预算信息") {
                    TextField("预算名称", text: $name)
                    
                    TextField("金额", value: $amount, format: .currency(code: "CNY"))
                        .keyboardType(.decimalPad)
                    
                    Picker("预算周期", selection: $period) {
                        ForEach(BudgetPeriod.allCases, id: \.self) { period in
                            Text(period.rawValue).tag(period)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section("分类") {
                    Picker("类别", selection: $category) {
                        ForEach(FinancialCategory.allCases, id: \.self) { category in
                            Text(category.description).tag(category)
                        }
                    }
                }
            }
            .navigationTitle("添加预算")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveBudget()
                    }
                    .disabled(name.isEmpty || amount <= 0)
                }
            }
            .alert(isSuccess ? "成功" : "提示", isPresented: $showingAlert) {
                Button("确定") {
                    if isSuccess {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func saveBudget() {
        guard !name.isEmpty else {
            alertMessage = "请输入预算名称"
            isSuccess = false
            showingAlert = true
            return
        }
        
        guard amount > 0 else {
            alertMessage = "请输入有效金额"
            isSuccess = false
            showingAlert = true
            return
        }
        
        let newBudget = Budget(
            name: name,
            amount: amount,
            period: period,
            category: category
        )
        newBudget.startDate = startDate
        newBudget.endDate = period.endDate(from: startDate)
        
        modelContext.insert(newBudget)
        
        do {
            try modelContext.save()
            alertMessage = "预算创建成功！"
            isSuccess = true
            showingAlert = true
        } catch {
            alertMessage = "保存失败: \(error.localizedDescription)"
            isSuccess = false
            showingAlert = true
        }
    }
}

#Preview {
    AddBudgetView()
        .modelContainer(for: Budget.self, inMemory: true)
} 