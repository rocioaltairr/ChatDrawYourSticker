//
//  RegisterVC.swift
//  ChatFile
//
//  Created by 2008007NB01 on 2021/9/26.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseAuth
import FirebaseFirestore

class RegisterVC: UIViewController, UITextFieldDelegate
{
    
    var nsCache = NSCache<NSString, ImageCache>()
    
    @IBOutlet weak var vwTxtFieldUp1_WD: NSLayoutConstraint!
    @IBOutlet weak var vwTestField1: StyleView!
    @IBOutlet weak var vwTestField2: StyleView!
    
    @IBOutlet weak var txtFieldFullName: UITextField!
    @IBOutlet weak var txtFieldUserName: UITextField!
    @IBOutlet weak var txtFieldEmail: UITextField!
    @IBOutlet weak var txtFieldPassword: UITextField!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var btnImage: UIButton!
    
    @IBOutlet weak var vwTxtFieldUp1: UIView!
    @IBOutlet weak var vwTxtFieldUp2: UIView!
    @IBOutlet weak var lbTxtFieldUp1: UILabel!
    @IBOutlet weak var lbTxtFieldUp2: UILabel!
    @IBOutlet weak var btnEnter: UIButton!
    
    @IBOutlet weak var lbEmail: UILabel!
    @IBOutlet weak var lbPassword: UILabel!
    @IBOutlet weak var lbFullName: UILabel!
    @IBOutlet weak var lbName: UILabel!
    let imagePickerVC = UIImagePickerController()
    
    var isStepTwo = false
    
    
    var imgUser : UIImage?
    
    var strUserFullName:String?
    var strUserNickName:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImage.contentMode = .scaleAspectFill
        profileImage.layer.masksToBounds = false
        profileImage.layer.cornerRadius = profileImage.frame.height/2
        profileImage.clipsToBounds = true
        
        imagePickerVC.sourceType = .photoLibrary
        imagePickerVC.delegate = self
        
        vwTxtFieldUp1.isHidden = true
        vwTxtFieldUp2.isHidden = true
        if isStepTwo == false {
            vwTxtFieldUp1_WD.constant = 40
            
            txtFieldFullName.tag = 1
            txtFieldUserName.tag = 2
            txtFieldFullName.delegate = self
            txtFieldUserName.delegate = self
            
        } else {
            btnImage.isHidden = true
            if let img = imgUser {
                profileImage.image = img
            }
            
            vwTxtFieldUp1_WD.constant = 80
            lbName.isHidden = true
            lbFullName.isHidden = true
            
            txtFieldEmail.tag = 1
            txtFieldPassword.tag = 2
            txtFieldEmail.delegate = self
            txtFieldPassword.delegate = self
            
            txtFieldFullName.isHidden = true
            txtFieldUserName.isHidden = true
            btnEnter.setTitle("註冊", for: .normal)
            lbTxtFieldUp1.text = "電子郵件地址"
            lbTxtFieldUp2.text = "密碼"
            
        }
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyBoard))
        self.view.addGestureRecognizer(tap)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 1 {
            vwTestField1.BorderColor = .systemBlue
            vwTestField1.BorderWidth = 2
            lbTxtFieldUp1.textColor = .systemBlue
            vwTxtFieldUp1.isHidden = false
            
            if isStepTwo == false {
                lbFullName.isHidden = true
            } else  {
                lbEmail.isHidden = true
            }
        } else if textField.tag == 2 {
            vwTestField2.BorderColor = .systemBlue
            vwTestField2.BorderWidth = 2
            lbTxtFieldUp2.textColor = .systemBlue
            vwTxtFieldUp2.isHidden = false
            
            if isStepTwo == false {
                lbName.isHidden = true
            } else  {
                lbPassword.isHidden = true
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 1 {
            vwTestField1.BorderColor = #colorLiteral(red: 0.9009289145, green: 0.8999640942, blue: 0.9166941047, alpha: 1)
            vwTestField1.BorderWidth = 1
            lbTxtFieldUp1.textColor = #colorLiteral(red: 0.4886253476, green: 0.4981116056, blue: 0.5110453367, alpha: 1)
            
        } else if textField.tag == 2 {
            vwTestField2.BorderColor = #colorLiteral(red: 0.9009289145, green: 0.8999640942, blue: 0.9166941047, alpha: 1)
            vwTestField2.BorderWidth = 1
            lbTxtFieldUp2.textColor = #colorLiteral(red: 0.4886253476, green: 0.4981116056, blue: 0.5110453367, alpha: 1)
            
        }
    }
    
    

    // MARK: - 註冊會員
    @IBAction func action_register(_ sender: Any) {
        if isStepTwo == false {
            if txtFieldFullName.text == "" || txtFieldUserName.text == "" {
                showError("未填表完成")
                return
            }
            if imgUser == nil {
                showError("未加入圖片")
                return
            }
            let vc = RegisterVC()
            vc.strUserFullName = txtFieldFullName.text
            vc.strUserNickName = txtFieldUserName.text
            vc.isStepTwo = true
            vc.imgUser = imgUser
            self.navigationController?.pushViewController(vc, animated: true)
            
        } else {
            if txtFieldEmail.text == "" || txtFieldPassword.text == "" {
                showError("未填表完成")
                return
            }
            guard let email = txtFieldEmail.text else {
                showError("未填表完成")
                return
            }
            guard let password = txtFieldPassword.text else {
                showError("未填表完成")
                return
            }
            if txtFieldPassword.text?.count ?? 0 < 6 {
                showError("密碼需大於6個字")
                return
            }
//            guard let profileImage = profileImage else {
//                showError("未加入圖片")
//                return
//            }
            guard let imageData = imgUser else {
                showError("未加入圖片")
                return
            }
            guard let imageData = imgUser?.jpegData(compressionQuality: 0.1) else {
                // profileImage.jpegData(compressionQuality: 0.5) else {
                showError("圖片轉擋成JPEG失敗")
                return
            }

            
            let filename = NSUUID().uuidString
            
            // 上傳照片
            let ref = Storage.storage().reference(withPath: "/profile_images/\(filename)")
            ref.putData(imageData, metadata: nil) { (meta, error) in
                if error != nil {
                    print("DEBUG: 上傳User 大頭照到firebase storage 失敗: \(String(describing: error?.localizedDescription))")
                    AlertUtil.showMessage(message: "上傳大頭照到失敗 \(String(describing: error?.localizedDescription))")
                }
                
                return
            }
            
            
            ref.downloadURL { (url, error) in
                let profileImageUrl = ref.fullPath
                // 創造user 需要存在database的image路徑
                Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
                    if error != nil {
                        AlertUtil.showMessage(message: "註冊失敗 \(String(describing: error?.localizedDescription))")
                        print("DEBUG: 創建User失敗 : \(String(describing: error?.localizedDescription))")
                    }
                    
                    guard let uid = result?.user.uid else { return }
                    
                
                    let data = ["email":email,
                                "fullname":self.strUserFullName!,
                                "imageUrl":"\(profileImageUrl)",
                                "uid":uid,
                                "username":self.strUserNickName!] as [String:Any]
                    
                    // Create database
                    Firestore.firestore().collection("users").document(uid).setData(data) { error in
                        if error != nil {
                            print("DEBUG: 上傳User資料失敗: \(String(describing: error?.localizedDescription))")
                            return
                        } else {
                            print("DEBUG: 上傳User資料成功")
                            self.navigationController?.popViewController(animated: true)
                        }
                        
                    }
                }
            }
            self.navigationController?.popToRootViewController(animated: true)
            //self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func action_addPhoto(_ sender: Any) {
        let alert = UIAlertController(title: "請選擇照片", message: "您想怎麼加入照片呢？", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "拍照", style: .default, handler: { [weak self] _ in
            self?.presentCamera()
        }))
        alert.addAction(UIAlertAction(title: "選擇照片", style: .default, handler: { [weak self] _ in
            self?.presentPhotoPicker()
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func acyion_back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @objc func dismissKeyBoard() {
        self.view.endEditing(true)
    }
    
}


extension RegisterVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func presentCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        self.present(vc, animated: true, completion: nil)
        
    }
    
    func presentPhotoPicker() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        self.present(vc, animated: true, completion: nil)
    }
    /*
    @objc func presentPhotoActionSheet() {
        let alert = UIAlertController(title: "請選擇照片", message: "您想怎麼加入照片呢？", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "拍照", style: .default, handler: { [weak self] _ in
            self?.presentCamera()
        }))
        alert.addAction(UIAlertAction(title: "選擇照片", style: .default, handler: { [weak self] _ in
            self?.presentPhotoPicker()
        }))
        
        present(alert, animated: true, completion: nil)
    }*/
    
    
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        let img = info[.originalImage] as? UIImage
//        profileImage = img
//        btnPlus.setImage(img?.withRenderingMode(.alwaysOriginal), for: .normal)
//        btnPlus.layer.borderColor = UIColor.white.cgColor
//        btnPlus.layer.borderWidth = 3.0
//        btnPlus.layer.cornerRadius = 200 / 2
//        btnPlus.imageView?.contentMode = .scaleAspectFill
//        btnPlus.imageView?.clipsToBounds = true
//        dismiss(animated: true, completion: nil)
//    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        if let selectedImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage
        {
            profileImage.image = selectedImage
            imgUser = selectedImage
//
            
//            btnPlus.setImage(selectedImage.withRenderingMode(.alwaysOriginal), for: .normal)
//            btnPlus.layer.borderColor = UIColor.white.cgColor
//            btnPlus.layer.borderWidth = 3.0
//            btnPlus.layer.cornerRadius = 200 / 2
//            btnPlus.imageView?.contentMode = .scaleAspectFill
//            btnPlus.imageView?.clipsToBounds = true
//
            dismiss(animated: true, completion: nil)
        }
        else
        {
            fatalError("error while selectig image \(info)")
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}


