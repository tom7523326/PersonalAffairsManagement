//
//  AuthenticationView.swift
//  PersonalAffairsManagement
//
//  Created by 汤寿麟 on 2025/6/23.
//

import SwiftUI

struct AuthenticationView: View {
    @StateObject private var cloudService = CloudService.shared
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isSignUp = false
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showError = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Logo和标题
                VStack(spacing: 20) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    
                    Text("个人事务管理")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(isSignUp ? "创建您的账户" : "欢迎回来")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                
                // 表单
                VStack(spacing: 20) {
                    // 邮箱输入
                    VStack(alignment: .leading, spacing: 8) {
                        Text("邮箱")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("请输入邮箱", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                    
                    // 密码输入
                    VStack(alignment: .leading, spacing: 8) {
                        Text("密码")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        SecureField("请输入密码", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    // 确认密码（仅注册时显示）
                    if isSignUp {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("确认密码")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            SecureField("请再次输入密码", text: $confirmPassword)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                }
                
                // 错误信息
                if showError {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // 登录/注册按钮
                Button(action: performAuthentication) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        }
                        
                        Text(isSignUp ? "注册" : "登录")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isFormValid ? Color.blue : Color.gray)
                    .cornerRadius(10)
                }
                .disabled(!isFormValid || isLoading)
                
                // 切换登录/注册
                Button(action: {
                    withAnimation {
                        isSignUp.toggle()
                        clearForm()
                    }
                }) {
                    Text(isSignUp ? "已有账户？点击登录" : "没有账户？点击注册")
                        .foregroundColor(.blue)
                        .font(.subheadline)
                }
                
                Spacer()
                
                // 隐私政策
                VStack(spacing: 10) {
                    Text("使用即表示同意我们的")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 5) {
                        Button("服务条款") {
                            // 打开服务条款
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                        
                        Text("和")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Button("隐私政策") {
                            // 打开隐私政策
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                }
            }
            .padding(.horizontal, 30)
            .padding(.top, 50)
            .navigationBarHidden(true)
            .alert("认证失败", isPresented: $showError, actions: {
                Button("好的") { }
            }, message: {
                Text(errorMessage)
            })
        }
    }
    
    // MARK: - 计算属性
    private var isFormValid: Bool {
        if isSignUp {
            return !email.isEmpty && 
                   !password.isEmpty && 
                   !confirmPassword.isEmpty && 
                   password == confirmPassword &&
                   password.count >= 6 &&
                   isValidEmail(email)
        } else {
            return !email.isEmpty && !password.isEmpty
        }
    }
    
    // MARK: - 方法
    private func performAuthentication() {
        isLoading = true
        Task {
            do {
                if isSignUp {
                    try await cloudService.signUp(email: email, password: password)
                } else {
                    try await cloudService.signIn(email: email, password: password)
                }
                // 登录/注册成功后不需要在这里做任何事，视图会自动切换
            } catch {
                print("[AuthenticationView] An error occurred: \(error.localizedDescription)")
                self.errorMessage = error.localizedDescription
                self.showError = true
            }
            
            await MainActor.run {
                isLoading = false
            }
        }
    }
    
    private func clearForm() {
        email = ""
        password = ""
        confirmPassword = ""
        errorMessage = ""
        showError = false
        isLoading = false
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}

#Preview {
    AuthenticationView()
} 