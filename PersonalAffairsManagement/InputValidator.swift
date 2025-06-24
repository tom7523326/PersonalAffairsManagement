//
//  InputValidator.swift
//  PersonalAffairsManagement
//
//  Created by 汤寿麟 on 2025/6/23.
//

import Foundation

// MARK: - 输入验证器
struct InputValidator {
    
    // MARK: - 邮箱验证
    static func validateEmail(_ email: String) -> ValidationResult {
        if email.isEmpty {
            return .failure("邮箱不能为空")
        }
        
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        
        if !emailPredicate.evaluate(with: email) {
            return .failure("请输入有效的邮箱地址")
        }
        
        return .success
    }
    
    // MARK: - 密码验证
    static func validatePassword(_ password: String) -> ValidationResult {
        if password.isEmpty {
            return .failure("密码不能为空")
        }
        
        if password.count < 6 {
            return .failure("密码至少需要6个字符")
        }
        
        if password.count > 50 {
            return .failure("密码不能超过50个字符")
        }
        
        return .success
    }
    
    // MARK: - 确认密码验证
    static func validateConfirmPassword(_ password: String, confirmPassword: String) -> ValidationResult {
        if confirmPassword.isEmpty {
            return .failure("请确认密码")
        }
        
        if password != confirmPassword {
            return .failure("两次输入的密码不一致")
        }
        
        return .success
    }
    
    // MARK: - 标题验证
    static func validateTitle(_ title: String, fieldName: String = "标题") -> ValidationResult {
        if title.isEmpty {
            return .failure("\(fieldName)不能为空")
        }
        
        if title.count > 100 {
            return .failure("\(fieldName)不能超过100个字符")
        }
        
        return .success
    }
    
    // MARK: - 金额验证
    static func validateAmount(_ amount: String, fieldName: String = "金额") -> ValidationResult {
        if amount.isEmpty {
            return .failure("\(fieldName)不能为空")
        }
        
        guard let doubleValue = Double(amount) else {
            return .failure("请输入有效的\(fieldName)")
        }
        
        if doubleValue < 0 {
            return .failure("\(fieldName)不能为负数")
        }
        
        if doubleValue > 999999999 {
            return .failure("\(fieldName)不能超过999,999,999")
        }
        
        return .success
    }
    
    // MARK: - 用户名验证
    static func validateUsername(_ username: String) -> ValidationResult {
        if username.isEmpty {
            return .failure("用户名不能为空")
        }
        
        if username.count < 2 {
            return .failure("用户名至少需要2个字符")
        }
        
        if username.count > 50 {
            return .failure("用户名不能超过50个字符")
        }
        
        // 检查是否包含特殊字符
        let allowedCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "._-"))
        if !username.unicodeScalars.allSatisfy({ allowedCharacters.contains($0) }) {
            return .failure("用户名只能包含字母、数字、点、下划线和连字符")
        }
        
        return .success
    }
    
    // MARK: - 网站URL验证
    static func validateWebsite(_ website: String) -> ValidationResult {
        if website.isEmpty {
            return .success // 网站是可选的
        }
        
        guard let url = URL(string: website) else {
            return .failure("请输入有效的网站地址")
        }
        
        if let scheme = url.scheme, !scheme.isEmpty && (scheme == "http" || scheme == "https") {
            return .success
        } else {
            return .failure("网站地址必须以 http:// 或 https:// 开头")
        }
    }
    
    // MARK: - 描述验证
    static func validateDescription(_ description: String, fieldName: String = "描述") -> ValidationResult {
        if description.count > 1000 {
            return .failure("\(fieldName)不能超过1000个字符")
        }
        
        return .success
    }
    
    // MARK: - 日期验证
    static func validateDate(_ date: Date, isPastAllowed: Bool = true, fieldName: String = "日期") -> ValidationResult {
        let now = Date()
        
        if !isPastAllowed && date < now {
            return .failure("\(fieldName)不能是过去的日期")
        }
        
        // 检查日期是否太远（比如100年后）
        let calendar = Calendar.current
        if let futureDate = calendar.date(byAdding: .year, value: 100, to: now),
           date > futureDate {
            return .failure("\(fieldName)不能超过100年")
        }
        
        return .success
    }
    
    // MARK: - 批量验证
    static func validateMultiple(_ validations: [ValidationResult]) -> ValidationResult {
        for validation in validations {
            if case .failure(let message) = validation {
                return .failure(message)
            }
        }
        return .success
    }
}

// MARK: - 验证结果
enum ValidationResult {
    case success
    case failure(String)
    
    var isValid: Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }
    
    var errorMessage: String? {
        switch self {
        case .success:
            return nil
        case .failure(let message):
            return message
        }
    }
}

// MARK: - 表单验证器
class FormValidator: ObservableObject {
    @Published var errors: [String: String] = [:]
    
    func validateField(_ field: String, validation: ValidationResult) {
        if case .failure(let message) = validation {
            errors[field] = message
        } else {
            errors.removeValue(forKey: field)
        }
    }
    
    func validateForm(_ validations: [String: ValidationResult]) -> Bool {
        errors.removeAll()
        
        for (field, validation) in validations {
            validateField(field, validation: validation)
        }
        
        return errors.isEmpty
    }
    
    func clearErrors() {
        errors.removeAll()
    }
    
    func hasErrors() -> Bool {
        return !errors.isEmpty
    }
    
    func getError(for field: String) -> String? {
        return errors[field]
    }
} 