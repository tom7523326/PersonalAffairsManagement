//
//  EditAssetView.swift
//  PersonalAffairsManagement
//
//  Created by 汤寿麟 on 2025/6/23.
//

import SwiftUI
import SwiftData

struct EditAssetView: View {
    let asset: VirtualAsset
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String
    @State private var assetType: AssetType
    @State private var value: String
    @State private var currency: String
    @State private var expiryDate: Date
    @State private var hasExpiryDate: Bool
    @State private var assetDescription: String
    @State private var barcode: String
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    init(asset: VirtualAsset) {
        self.asset = asset
        self._name = State(initialValue: asset.name)
        self._assetType = State(initialValue: asset.assetType)
        self._value = State(initialValue: String(format: "%.2f", asset.value))
        self._currency = State(initialValue: asset.currency)
        self._expiryDate = State(initialValue: asset.expiryDate ?? Date().addingTimeInterval(30 * 24 * 60 * 60))
        self._hasExpiryDate = State(initialValue: asset.expiryDate != nil)
        self._assetDescription = State(initialValue: asset.assetDescription ?? "")
        self._barcode = State(initialValue: asset.barcode ?? "")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("基本信息") {
                    TextField("资产名称", text: $name)
                    
                    Picker("资产类型", selection: $assetType) {
                        ForEach(AssetType.allCases, id: \.self) { type in
                            HStack {
                                Image(systemName: type.icon)
                                    .foregroundColor(type.color)
                                Text(type.rawValue)
                            }
                            .tag(type)
                        }
                    }
                    
                    HStack {
                        TextField("价值", text: $value)
                            .keyboardType(.decimalPad)
                        
                        Picker("货币", selection: $currency) {
                            Text("CNY").tag("CNY")
                            Text("USD").tag("USD")
                            Text("EUR").tag("EUR")
                            Text("JPY").tag("JPY")
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                }
                
                Section("有效期") {
                    Toggle("设置过期时间", isOn: $hasExpiryDate)
                    
                    if hasExpiryDate {
                        DatePicker("过期日期", selection: $expiryDate, displayedComponents: .date)
                    }
                }
                
                Section("详细信息") {
                    TextField("描述 (可选)", text: $assetDescription)
                    TextField("条形码/编号 (可选)", text: $barcode)
                }
            }
            .navigationTitle("编辑资产")
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
                    .disabled(name.isEmpty || value.isEmpty)
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
        guard !name.isEmpty && !value.isEmpty else {
            alertMessage = "请填写必填字段"
            showingAlert = true
            return
        }
        
        guard let doubleValue = Double(value) else {
            alertMessage = "请输入有效的价值"
            showingAlert = true
            return
        }
        
        asset.name = name
        asset.assetType = assetType
        asset.value = doubleValue
        asset.currency = currency
        asset.expiryDate = hasExpiryDate ? expiryDate : nil
        asset.assetDescription = assetDescription.isEmpty ? nil : assetDescription
        asset.barcode = barcode.isEmpty ? nil : barcode
        asset.updatedAt = Date()
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            alertMessage = "保存失败: \(error.localizedDescription)"
            showingAlert = true
        }
    }
}

#Preview {
    let asset = VirtualAsset(
        name: "星巴克礼品卡",
        assetType: .giftCard,
        value: 100.0,
        currency: "CNY",
        expiryDate: Date().addingTimeInterval(30 * 24 * 60 * 60),
        assetDescription: "星巴克咖啡礼品卡",
        barcode: "123456789012"
    )
    
    EditAssetView(asset: asset)
        .modelContainer(for: [VirtualAsset.self], inMemory: true)
} 