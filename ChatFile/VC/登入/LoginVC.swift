//
//  LoginVC.swift
//  ChatFile
//
//  Created by 2008007NB01 on 2021/8/12.
//

import UIKit
import FirebaseAuth


class LoginVC: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var txtFieldEmail: UITextField!
    @IBOutlet weak var txtFieldPassword: UITextField!
    
    @IBOutlet weak var lbTxtFieldUp: UILabel!
    @IBOutlet weak var vwTxtFieldUp: UIView!
    @IBOutlet weak var lbEmail: UILabel!
    @IBOutlet weak var vwTestField: StyleView!
    
    @IBOutlet weak var vwBack: UIView!
    @IBOutlet weak var lbPassword: UILabel!
    @IBOutlet weak var btnEnter: StyleButton!
    var isEnteringEmail :Bool = false
    @IBOutlet weak var btnRight: StyleButton!
    var isEnteringPass: Bool = false
    
    var strEmail:String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        txtFieldEmail.delegate = self
        txtFieldPassword.delegate = self
        
        vwTxtFieldUp.isHidden = true
        authenticateUser()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyBoard))
        self.view.addGestureRecognizer(tap)
        

        if isEnteringPass == true {
            vwTxtFieldUp.isHidden = true
            vwTestField.BorderColor = #colorLiteral(red: 0.9009289145, green: 0.8999640942, blue: 0.9166941047, alpha: 1)
            lbTxtFieldUp.textColor = #colorLiteral(red: 0.9009289145, green: 0.8999640942, blue: 0.9166941047, alpha: 1)
            lbTxtFieldUp.text = "輸入您的密碼"
            lbEmail.isHidden = true
            btnEnter.setTitle("下一步", for: .normal)
            txtFieldEmail.isHidden = true
            btnRight.setTitle("忘記密碼？", for: .normal)
        } else {
            vwBack.isHidden = true
        }
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if isEnteringPass == false {
            vwTestField.BorderColor = .systemBlue
            lbTxtFieldUp.textColor = .systemBlue
            vwTxtFieldUp.isHidden = false
            lbEmail.isHidden = true
        } else  {
            vwTestField.BorderColor = .systemBlue
            lbPassword.isHidden = true
            vwTxtFieldUp.isHidden = false
            lbTxtFieldUp.textColor = .systemBlue
        }
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        vwTestField.BorderColor = #colorLiteral(red: 0.9009289145, green: 0.8999640942, blue: 0.9166941047, alpha: 1)
        lbTxtFieldUp.textColor = #colorLiteral(red: 0.9009289145, green: 0.8999640942, blue: 0.9166941047, alpha: 1)
        
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
    
    @IBAction func action_login(_ sender: UIButton) {
        if isEnteringPass == false { // 填入email時
            let vc = LoginVC()
            vc.strEmail = txtFieldEmail.text ?? ""
            vc.isEnteringPass = true
            self.navigationController?.pushViewController(vc, animated: true)
//            btnEnter.setTitle("下一步", for: .normal)
//            vwTestField.isHidden = true
            
        } else {//     填入passworld時
            let vc = ConversationVC()
            let email = strEmail
            //guard let email = txtFieldEmail.text else { return }
            guard let password = txtFieldPassword.text else { return }
            
            LoadingUtil.showWithTitle(title: "請稍候..")
            AuthManager.shared.logUserIn(withEmail:email,password:password) { (result, error) in
                if error != nil {
                    AlertUtil.showMessage(message: "登入失敗\(error?.localizedDescription ?? "")")
                    LoadingUtil.hideView()
                    //self.showError("email格式錯誤，密碼超過6個字，如還沒申請帳號請去下方申請！")

                    return
                }
                self.navigationController?.pushViewController(vc, animated: true)
                LoadingUtil.hideView()
                
            }
        }

    }
    
    @IBAction func action_goToRegister(_ sender: Any) {
        if isEnteringPass == true { // 忘記密碼
            
        } else { // 註冊帳號
            let vc = RegisterVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }

    }
    
    
    @IBAction func action_back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func dismissKeyBoard() {
        self.view.endEditing(true)
    }
    
}
