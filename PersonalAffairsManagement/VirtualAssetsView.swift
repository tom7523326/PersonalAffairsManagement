//
//  VirtualAssetsView.swift
//  PersonalAffairsManagement
//
//  Created by 汤寿麟 on 2025/6/23.
//

import SwiftUI
import SwiftData

struct VirtualAssetsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \VirtualAsset.updatedAt, order: .reverse) private var assets: [VirtualAsset]
    @State private var searchText = ""
    @State private var selectedType: AssetType? = nil
    @State private var showingAddAsset = false
    @State private var showingAssetDetail: VirtualAsset? = nil
    @State private var showingExpiredOnly = false
    
    var filteredAssets: [VirtualAsset] {
        var filtered = assets
        
        if !searchText.isEmpty {
            filtered = filtered.filter { asset in
                asset.name.localizedCaseInsensitiveContains(searchText) ||
                (asset.assetDescription?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        if let type = selectedType {
            filtered = filtered.filter { $0.assetType == type }
        }
        
        if showingExpiredOnly {
            filtered = filtered.filter { asset in
                if let expiryDate = asset.expiryDate {
                    return expiryDate < Date()
                }
                return false
            }
        }
        
        return filtered
    }
    
    var totalValue: Double {
        filteredAssets.reduce(0) { $0 + $1.value }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Search and filter bar
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("搜索资产...", text: $searchText)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterChip(title: "全部", isSelected: selectedType == nil) {
                                selectedType = nil
                            }
                            
                            ForEach(AssetType.allCases, id: \.self) { type in
                                FilterChip(title: type.rawValue, isSelected: selectedType == type) {
                                    selectedType = selectedType == type ? nil : type
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    HStack {
                        Toggle("仅显示过期", isOn: $showingExpiredOnly)
                            .font(.caption)
                        
                        Spacer()
                        
                        Text("总价值: ¥\(String(format: "%.2f", totalValue))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                }
                .padding(.horizontal)
                
                // Assets list
                List {
                    ForEach(filteredAssets) { asset in
                        AssetRowView(asset: asset) {
                            showingAssetDetail = asset
                        }
                    }
                    .onDelete(perform: deleteAssets)
                }
                .listStyle(InsetGroupedListStyle())
            }
            .navigationTitle("虚拟资产")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddAsset = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddAsset) {
                AddAssetView()
            }
            .sheet(item: $showingAssetDetail) { asset in
                AssetDetailView(asset: asset)
            }
        }
    }
    
    private func deleteAssets(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(filteredAssets[index])
        }
    }
}

struct AssetRowView: View {
    let asset: VirtualAsset
    let onTap: () -> Void
    
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
        HStack {
            Image(systemName: asset.assetType.icon)
                .foregroundColor(asset.assetType.color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(asset.name)
                        .font(.headline)
                    
                    if isExpired {
                        Text("已过期")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.red)
                            .cornerRadius(4)
                    } else if let days = daysUntilExpiry, days <= 7 {
                        Text("\(days)天后过期")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange)
                            .cornerRadius(4)
                    }
                }
                
                Text(asset.assetType.rawValue)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if let description = asset.assetDescription {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("¥\(String(format: "%.2f", asset.value))")
                    .font(.headline)
                    .foregroundColor(asset.assetType.color)
                
                if let expiryDate = asset.expiryDate {
                    Text(formatDate(expiryDate))
                        .font(.caption)
                        .foregroundColor(isExpired ? .red : .secondary)
                }
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    VirtualAssetsView()
        .modelContainer(for: [VirtualAsset.self], inMemory: true)
} 