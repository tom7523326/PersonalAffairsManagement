//
//  AddAssetView.swift
//  PersonalAffairsManagement
//
//  Created by 汤寿麟 on 2025/6/23.
//

import SwiftUI
import SwiftData

struct AddAssetView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var assetType: AssetType = .giftCard
    @State private var value = ""
    @State private var currency = "CNY"
    @State private var expiryDate: Date = Date().addingTimeInterval(30 * 24 * 60 * 60) // 30 days from now
    @State private var hasExpiryDate = true
    @State private var assetDescription = ""
    @State private var barcode = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
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
                
                Section {
                    Button("快速添加") {
                        addQuickAsset()
                    }
                    .foregroundColor(.blue)
                }
            }
            .navigationTitle("添加虚拟资产")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveAsset()
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
    
    private func saveAsset() {
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
        
        let newAsset = VirtualAsset(
            name: name,
            assetType: assetType,
            value: doubleValue,
            currency: currency,
            expiryDate: hasExpiryDate ? expiryDate : nil,
            assetDescription: assetDescription.isEmpty ? nil : assetDescription,
            barcode: barcode.isEmpty ? nil : barcode
        )
        
        modelContext.insert(newAsset)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            alertMessage = "保存失败: \(error.localizedDescription)"
            showingAlert = true
        }
    }
    
    private func addQuickAsset() {
        let quickAssets = [
            ("星巴克礼品卡", AssetType.giftCard, "100"),
            ("京东优惠券", AssetType.coupon, "50"),
            ("美团代金券", AssetType.voucher, "20"),
            ("超市会员卡", AssetType.membership, "0"),
            ("积分卡", AssetType.loyalty, "0")
        ]
        
        let randomAsset = quickAssets.randomElement()!
        name = randomAsset.0
        assetType = randomAsset.1
        value = randomAsset.2
        assetDescription = "快速添加的\(randomAsset.0)"
    }
}

#Preview {
    AddAssetView()
        .modelContainer(for: [VirtualAsset.self], inMemory: true)
} 