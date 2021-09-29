//
//  LoginViewModel.swift
//  ChatWithMe
//
//  Created by 2008007NB01 on 2021/1/29.
//

import Foundation

protocol AuthenticationProtocol {
    var formIsValid: Bool { get }
}

struct LoginViewModel {
    var email: String?
    var password: String?
    
    var formIsValid: Bool {
        return email?.isEmpty == false
            && password?.isEmpty == false
        // if email and password is not empty return true
    }
}
