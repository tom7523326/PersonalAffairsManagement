//
//  AddFinancialRecordView.swift
//  PersonalAffairsManagement
//
//  Created by 汤寿麟 on 2025/6/23.
//
import SwiftUI
import SwiftData

struct AddFinancialRecordView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String = ""
    @State private var amount: Double = 0.0
    @State private var type: TransactionType = .expense
    @State private var category: FinancialCategory = .food
    @State private var recordDescription: String = ""
    @State private var date = Date()
    
    // 添加状态管理
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isSuccess = false

    var body: some View {
        NavigationStack {
            Form {
                Section("基本信息") {
                    TextField("标题", text: $title)
                    
                    TextField("金额", value: $amount, format: .currency(code: "CNY"))
                        .keyboardType(.decimalPad)
                    
                    Picker("类型", selection: $type) {
                        ForEach(TransactionType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())

                    Picker("类别", selection: $category) {
                        ForEach(FinancialCategory.allCases, id: \.self) { category in
                            Text(category.description).tag(category)
                        }
                    }
                }
                
                Section("详细信息") {
                    TextEditor(text: $recordDescription)
                        .frame(height: 100)
                    DatePicker("日期", selection: $date, displayedComponents: [.date])
                }
            }
            .navigationTitle("添加财务记录")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveRecord()
                    }
                    .disabled(title.isEmpty || amount <= 0)
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
    
    private func saveRecord() {
        guard !title.isEmpty else {
            alertMessage = "请输入记录标题"
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
        
        let newRecord = FinancialRecord(
            title: title,
            amount: amount,
            type: type,
            category: category,
            recordDescription: recordDescription
        )
        newRecord.date = date
        modelContext.insert(newRecord)
        
        do {
            try modelContext.save()
            alertMessage = "财务记录保存成功！"
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
    AddFinancialRecordView()
        .modelContainer(for: FinancialRecord.self, inMemory: true)
} 