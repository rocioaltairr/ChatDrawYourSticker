//
//  LoginVC.swift
//  ChatFile
//
//  Created by 白白 on 2021/8/12.
//

import UIKit
import FirebaseAuth


class LoginVC: UIViewController {

    @IBOutlet weak var txtFieldEmail: UITextField!
    @IBOutlet weak var lbTxtFieldUp: UILabel!
    @IBOutlet weak var vwTxtFieldUp: UIView!
    @IBOutlet weak var lbEmail: UILabel!
    @IBOutlet weak var vwTestField: StyleView!
    @IBOutlet weak var btnEnter: StyleButton!
    @IBOutlet weak var btnRight: StyleButton!
    
    let validation = ValidationService()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.txtFieldEmail.delegate = self
        self.setupUI()
        self.fetchCurrentUser()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyBoard))
        self.view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        txtFieldEmail.text = ""// 清空
    }
    
    // MARK: - UI初始化
    func setupUI() {
        vwTxtFieldUp.isHidden = true
    }
    
    func fetchCurrentUser() {
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
                }
            }
            self.authenticateUser()
        }
    }
    
    // MARK: - 認證使用者是否登入，沒登入present 登入頁面
    func authenticateUser() {
        if Auth.auth().currentUser?.uid != nil {
            LodingActivityIndicatorUtil.shared.showLoader(view: self.view)
            let vc = ConversationVC()
            self.navigationController?.pushViewController(vc, animated: true)
            print("DEBUG: User 已登入過，直接登入")
        } else {
            LodingActivityIndicatorUtil.shared.hideLoader()
            print("DEBUG: User 未登入過，須做登入")
        }
    }

    // MARK: - 下一步
    @IBAction func action_login(_ sender: UIButton) {
        LodingActivityIndicatorUtil.shared.showLoader(view: self.view)
        do {
            _ = try validation.validateEamil(txtFieldEmail.text)
            let vc = LoginEnterPassVC()
            if let email = txtFieldEmail.text {
                vc.strEmail = email
            }
            
            self.navigationController?.pushViewController(vc, animated: true)
        } catch {
            AlertUtil.showMessage(vc: self, message: "\(error.localizedDescription)") { alert in
                LodingActivityIndicatorUtil.shared.hideLoader()
            }
        }
    }
    
    // MARK: - 註冊帳號
    @IBAction func action_goToRegister(_ sender: Any) {
        let vc = RegisterVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func dismissKeyBoard() {
        self.view.endEditing(true)
    }
}

// MARK: - UITextFieldDelegate
extension LoginVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        vwTestField.BorderColor = .systemBlue
        lbTxtFieldUp.textColor = .systemBlue
        vwTxtFieldUp.isHidden = false
        lbEmail.isHidden = true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        vwTestField.BorderColor = #colorLiteral(red: 0.9009289145, green: 0.8999640942, blue: 0.9166941047, alpha: 1)
        lbTxtFieldUp.textColor = #colorLiteral(red: 0.9009289145, green: 0.8999640942, blue: 0.9166941047, alpha: 1)
        
    }
}
