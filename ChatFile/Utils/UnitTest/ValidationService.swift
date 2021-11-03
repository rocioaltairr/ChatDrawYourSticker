//
//  ValidationService.swift
//  ChatFile
//
//  Created by 白白 on 2021/10/27.
//

import Foundation
import FirebaseAuth

struct ValidationService {
    
    func validateEamil(_ email: String?) throws -> String {
        guard let email = email else { throw ValidationError.invalidValue }
        if isEmailRuler(email: email) == false { throw ValidationError.invalidEmail }
        return email
    }
    
    func validatePassword(_ password: String?) throws -> String {
        guard let password = password else { throw ValidationError.invalidValue }
       // if isPasswordRuler(password: password) == false {throw ValidationError.invalidPassword }
        
        guard password.count < 12 else { throw ValidationError.passwordTooLong }
        guard password.count > 6 else { throw ValidationError.passwordTooShort }
        return password
    }
    
    func isEmailRuler(email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest:NSPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: email)
    }
    
    func isPasswordRuler(password:String) -> Bool {
        let passwordRule = "^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{6,8}$"
        let regexPassword = NSPredicate(format: "SELF MATCHES %@",passwordRule)
        if regexPassword.evaluate(with: password) == true { return true } else { return false }
    }
}

enum ValidationError: LocalizedError {
    case invalidValue
    case invalidEmail
    case invalidPassword
    case passwordTooLong
    case passwordTooShort
    
    var errorDescription: String? {
        switch self {
        case .invalidValue:
            return "格式不正確"
        case .invalidEmail:
            return "郵件格式不正確"
        case .invalidPassword:
            return "密碼格式不正確，應為6-12位字母和數字組合"
        case .passwordTooLong:
            return "密碼太長"
        case .passwordTooShort:
            return "密碼太短"
        }
    }
}
