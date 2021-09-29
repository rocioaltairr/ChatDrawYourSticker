//
//  RegistrationViewModel.swift
//  ChatWithMe
//
//  Created by 2008007NB01 on 2021/1/29.
//

import Foundation

struct RegistrationViewModel: AuthenticationProtocol {
    
    var email: String?
    var password: String?
    var fullname: String?
    var username: String?
    
    var formIsValid: Bool {
        return email?.isEmpty == false
            && password?.isEmpty == false
            && fullname?.isEmpty == false
            && username?.isEmpty == false
    }
}
