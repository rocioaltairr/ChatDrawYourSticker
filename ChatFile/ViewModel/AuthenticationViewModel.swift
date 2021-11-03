//
//  AuthenticationViewModel.swift
//  ChatFile
//
//  Created by 2008007NB01 on 2021/11/1.
//

import Foundation

struct LoginUser {
    var userEmail : String
    var password : String
}

class AuthenticationViewModel: NSObject {
    var user:LoginUser!
    var userEmail: String {return user.userEmail}
    var password: String {return user.password}
    
    typealias authenticationLoginCallBack = (_ status:Bool, _ message:String) -> Void
    var loginCallback:authenticationLoginCallBack?
    
    // MARK: - 以User登入
    func authenticateUserWith(_ userEmail:String, andPassword password:String){
        if userEmail.count != 0 {
            if password.count != 0 {
                verifyUserWith(userEmail, andPassword: password)
            } else {
                self.loginCallback?(false,"password 是空的")
            }
        } else {
            self.loginCallback?(false,"Email 是空的")
        }
    }
    
    // MARK: - 驗證User帳密是否合法
    fileprivate func verifyUserWith(_ userEmail:String, andPassword password:String) {
        AuthManager.shared.logUserIn(withEmail:userEmail,password:password) { (result, error) in
            if error != nil {
                self.loginCallback?(false,error?.localizedDescription ?? "登入失敗")
                return
            }
            self.loginCallback?(true,"登入成功")
        }
    }
    
    func loginCompletionHandler(callBack: @escaping authenticationLoginCallBack) {
        self.loginCallback = callBack
    }
}
