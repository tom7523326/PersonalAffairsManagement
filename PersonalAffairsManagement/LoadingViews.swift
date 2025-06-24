//
//  LoadingViews.swift
//  PersonalAffairsManagement
//
//  Created by 汤寿麟 on 2025/6/23.
//

import SwiftUI

// MARK: - 加载状态视图
// struct LoadingView: View { ... } // 删除整个LoadingView实现

// MARK: - 自定义加载动画
struct LoadingSpinner: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 4)
                .frame(width: 50, height: 50)
                .foregroundColor(Color(.systemGray5))
            
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(lineWidth: 4)
                .frame(width: 50, height: 50)
                .foregroundColor(.blue)
                .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                .animation(
                    Animation.linear(duration: 1)
                        .repeatForever(autoreverses: false),
                    value: isAnimating
                )
        }
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - 空状态视图
// struct EmptyStateView: View { ... } // 删除整个EmptyStateView实现

// MARK: - 错误状态视图
struct ErrorStateView: View {
    let title: String
    let message: String
    let retryAction: (() -> Void)?
    
    init(title: String = "出错了", message: String, retryAction: (() -> Void)? = nil) {
        self.title = title
        self.message = message
        self.retryAction = retryAction
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(message)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            if let retryAction = retryAction {
                Button(action: retryAction) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("重试")
                    }
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

// MARK: - 刷新指示器
struct RefreshIndicator: View {
    let isRefreshing: Bool
    
    var body: some View {
        HStack {
            if isRefreshing {
                ProgressView()
                    .scaleEffect(0.8)
                Text("刷新中...")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - 加载更多指示器
struct LoadMoreIndicator: View {
    let isLoading: Bool
    let hasMore: Bool
    
    var body: some View {
        HStack {
            if isLoading {
                ProgressView()
                    .scaleEffect(0.8)
                Text("加载更多...")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else if !hasMore {
                Text("没有更多数据了")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
    }
}

// MARK: - 骨架屏加载
struct SkeletonView: View {
    @State private var isAnimating = false
    
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [Color(.systemGray6), Color(.systemGray5), Color(.systemGray6)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .mask(Rectangle())
            .overlay(
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.clear, Color.white.opacity(0.3), Color.clear]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .offset(x: isAnimating ? 400 : -400)
            )
            .onAppear {
                withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    isAnimating = true
                }
            }
    }
}

// MARK: - 任务骨架屏
struct TaskSkeletonView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                SkeletonView()
                    .frame(width: 200, height: 16)
                Spacer()
                SkeletonView()
                    .frame(width: 60, height: 16)
            }
            
            SkeletonView()
                .frame(height: 12)
            
            HStack {
                SkeletonView()
                    .frame(width: 80, height: 20)
                Spacer()
                SkeletonView()
                    .frame(width: 100, height: 20)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

// MARK: - 财务记录骨架屏
struct FinancialRecordSkeletonView: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                SkeletonView()
                    .frame(width: 150, height: 16)
                SkeletonView()
                    .frame(width: 100, height: 12)
            }
            
            Spacer()
            
            SkeletonView()
                .frame(width: 80, height: 20)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

// MARK: - 加载状态修饰符
struct LoadingStateModifier: ViewModifier {
    let isLoading: Bool
    let loadingMessage: String
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .disabled(isLoading)
                .opacity(isLoading ? 0.6 : 1.0)
            
            if isLoading {
                LoadingView(message: loadingMessage)
            }
        }
    }
}

extension View {
    func loadingState(_ isLoading: Bool, message: String = "加载中...") -> some View {
        modifier(LoadingStateModifier(isLoading: isLoading, loadingMessage: message))
    }
} 