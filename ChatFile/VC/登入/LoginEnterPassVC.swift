//
//  LoginEnterPassVC.swift
//  ChatFile
//
//  Created by 2008007NB01 on 2021/11/2.
//

import UIKit
import FirebaseAuth

class LoginEnterPassVC: UIViewController {
    @IBOutlet weak var txtFieldPassword: UITextField!
    @IBOutlet weak var lbTxtFieldUp: UILabel!
    @IBOutlet weak var vwTxtFieldUp: UIView!
    @IBOutlet weak var lbPassword: UILabel!
    @IBOutlet weak var vwTestField: StyleView!
    @IBOutlet weak var btnEnter: StyleButton!
    
    var strEmail:String = ""
    let validation = ValidationService()
    var authenticationViewModel = AuthenticationViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LodingActivityIndicatorUtil.shared.hideLoader()
        txtFieldPassword.delegate = self
        lbTxtFieldUp.textColor = #colorLiteral(red: 0.9009289145, green: 0.8999640942, blue: 0.9166941047, alpha: 1)
        lbTxtFieldUp.text = "輸入密碼"
        btnEnter.setTitle("下一步", for: .normal)
        //btnRight.setTitle("忘記密碼？", for: .normal)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyBoard))
        self.view.addGestureRecognizer(tap)
    }
    
    // MARK: - 登入
    @IBAction func action_login(_ sender: UIButton) {
        LodingActivityIndicatorUtil.shared.showLoader(view: self.view)
        guard let password = txtFieldPassword.text else { return }
        authenticationViewModel.authenticateUserWith(strEmail, andPassword: password)
        authenticationViewModel.loginCompletionHandler { status, message in
            if status {
                self.saveCurrentUserAndGoHomePage()
            } else {
                AlertUtil.showMessage(vc: self, message: message) { alert in
                    LodingActivityIndicatorUtil.shared.hideLoader()
                }
            }
        }
    }
    
    func saveCurrentUserAndGoHomePage() {
        LodingActivityIndicatorUtil.shared.showLoader(view: self.view)
        guard let uid = Auth.auth().currentUser?.uid else { return }
        UserManager.shared.fetchUser(whitUid: uid) {[weak self] user in
            guard let self = self else { return }
            do {
                let encoder = JSONEncoder()
                let data = try encoder.encode(user)
                UserDefaultUtil.save(key: "currentUser", saveObj: data)
            } catch {
                print("DEBUG: Encode User 失敗")
            }
            MessageManager.shared.fetchImage(withFileName: user.profileImageUrl) { data in
                if let imageData = data {
                    UserDefaultUtil.save(key: "currentUserImage", saveObj: imageData)
                    let vc = ConversationVC()
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    // MARK: - 回上一頁
    @IBAction func action_back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func dismissKeyBoard() {
        self.view.endEditing(true)
    }
}

extension LoginEnterPassVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        vwTestField.BorderColor = .systemBlue
        lbTxtFieldUp.textColor = .systemBlue
        vwTxtFieldUp.isHidden = false
        lbPassword.isHidden = true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        vwTestField.BorderColor = #colorLiteral(red: 0.9009289145, green: 0.8999640942, blue: 0.9166941047, alpha: 1)
        lbTxtFieldUp.textColor = #colorLiteral(red: 0.9009289145, green: 0.8999640942, blue: 0.9166941047, alpha: 1)
    }
}
