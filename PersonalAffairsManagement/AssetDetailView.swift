//
//  AssetDetailView.swift
//  PersonalAffairsManagement
//
//  Created by 汤寿麟 on 2025/6/23.
//

import SwiftUI
import SwiftData

struct AssetDetailView: View {
    let asset: VirtualAsset
    @Environment(\.dismiss) private var dismiss
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    @State private var showingCopiedAlert = false
    
    var isExpired: Bool {
        if let expiryDate = asset.expiryDate {
            return expiryDate < Date()
        }
        return false
    }
    
    var daysUntilExpiry: Int? {
        guard let expiryDate = asset.expiryDate else { return nil }
        let calendar = Calendar.current
        return calendar.dateComponents([.day], from: Date(), to: expiryDate).day
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    AssetHeaderView(asset: asset, isExpired: isExpired, daysUntilExpiry: daysUntilExpiry)
                    AssetValueSection(asset: asset)
                    if let description = asset.assetDescription, !description.isEmpty {
                        AssetDescriptionSection(description: description)
                    }
                    if let barcode = asset.barcode, !barcode.isEmpty {
                        AssetBarcodeSection(barcode: barcode, onCopy: { copyToClipboard(barcode) })
                    }
                    if let expiryDate = asset.expiryDate {
                        AssetExpirySection(expiryDate: expiryDate, isExpired: isExpired)
                    }
                    AssetMetadataSection(asset: asset)
                }
                .padding()
            }
            .navigationTitle("资产详情")
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
                EditAssetView(asset: asset)
            }
            .alert("删除资产", isPresented: $showingDeleteAlert) {
                Button("取消", role: .cancel) { }
                Button("删除", role: .destructive) {
                    deleteAsset()
                }
            } message: {
                Text("确定要删除这个资产吗？此操作无法撤销。")
            }
            .alert("已复制", isPresented: $showingCopiedAlert) {
                Button("确定") { }
            } message: {
                Text("条形码已复制到剪贴板")
            }
        }
    }
    
    private func copyToClipboard(_ code: String) {
        UIPasteboard.general.string = code
        showingCopiedAlert = true
    }
    
    private func deleteAsset() {
        // This would need to be implemented with proper model context
        dismiss()
    }
}

struct AssetHeaderView: View {
    let asset: VirtualAsset
    let isExpired: Bool
    let daysUntilExpiry: Int?
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: asset.assetType.icon)
                    .foregroundColor(asset.assetType.color)
                    .font(.title2)
                Text(asset.name)
                    .font(.title)
                    .fontWeight(.bold)
            }
            HStack {
                Text(asset.assetType.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(asset.assetType.color.opacity(0.2))
                    .cornerRadius(8)
                if isExpired {
                    Text("已过期")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red)
                        .cornerRadius(8)
                } else if let days = daysUntilExpiry, days <= 7 {
                    Text("\(days)天后过期")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange)
                        .cornerRadius(8)
                }
            }
        }
    }
}

struct AssetValueSection: View {
    let asset: VirtualAsset
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("资产价值")
                .font(.headline)
            HStack {
                Text("价值")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(asset.currency) \(String(format: "%.2f", asset.value))")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(asset.assetType.color)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
    }
}

struct AssetDescriptionSection: View {
    let description: String
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("描述")
                .font(.headline)
            Text(description)
                .font(.body)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
        }
    }
}

struct AssetBarcodeSection: View {
    let barcode: String
    let onCopy: () -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("条形码/编号")
                .font(.headline)
            HStack {
                Text(barcode)
                    .font(.body)
                    .monospaced()
                Spacer()
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

struct AssetExpirySection: View {
    let expiryDate: Date
    let isExpired: Bool
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("有效期")
                .font(.headline)
            HStack {
                Text("过期日期")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text(formatDate(expiryDate))
                    .font(.subheadline)
                    .foregroundColor(isExpired ? .red : .primary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
    }
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct AssetMetadataSection: View {
    let asset: VirtualAsset
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("创建信息")
                .font(.headline)
            InfoRow(title: "创建时间", value: formatDate(asset.createdAt))
            InfoRow(title: "更新时间", value: formatDate(asset.updatedAt))
            InfoRow(title: "状态", value: asset.isActive ? "活跃" : "非活跃")
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
    let asset = VirtualAsset(
        name: "星巴克礼品卡",
        assetType: .giftCard,
        value: 100.0,
        currency: "CNY",
        expiryDate: Date().addingTimeInterval(30 * 24 * 60 * 60),
        assetDescription: "星巴克咖啡礼品卡",
        barcode: "123456789012"
    )
    AssetDetailView(asset: asset)
} 