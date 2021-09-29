//
//  LoginVC.swift
//  ChatFile
//
//  Created by 2008007NB01 on 2021/8/12.
//

import UIKit
import FirebaseAuth
import JGProgressHUD


class LoginVC: UIViewController {

    @IBOutlet weak var txtFieldEmail: UITextField!
    @IBOutlet weak var txtFieldPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        authenticateUser()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyBoard))
        self.view.addGestureRecognizer(tap)
    }
    
    // MARK: - 認證使用者是否登入，沒登入present 登入頁面
    func authenticateUser() {
        if Auth.auth().currentUser?.uid != nil {
            let vc = ConversationVC()
            self.navigationController?.pushViewController(vc, animated: true)
            print("DEBUG: User 已登入")
        } else {
            print("DEBUG: User 未登入")
        }
    }

    
    
    @IBAction func action_login(_ sender: Any) {
        let vc = ConversationVC()
        guard let email = txtFieldEmail.text else { return }
        guard let password = txtFieldPassword.text else { return }
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Loading"
        hud.show(in: self.view)
        AuthManager.shared.logUserIn(withEmail:email,password:password) { (result, error) in
            if error != nil {
                AlertUtil.showMessage(message: "登入失敗\(String(describing: error?.localizedDescription))")
                hud.dismiss()
                //self.showError("email格式錯誤，密碼超過6個字，如還沒申請帳號請去下方申請！")

                return
            } 
            self.navigationController?.pushViewController(vc, animated: true)
            hud.dismiss()
            
        }
    }
    
    @IBAction func action_goToRegister(_ sender: Any) {
        let vc = RegisterVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
    @objc func dismissKeyBoard() {
        self.view.endEditing(true)
    }
    
}
