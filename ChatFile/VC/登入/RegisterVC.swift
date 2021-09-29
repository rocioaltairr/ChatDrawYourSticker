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

class RegisterVC: UIViewController {
    
    
    @IBOutlet weak var txtFieldFullName: UITextField!
    @IBOutlet weak var txtFieldUserName: UITextField!
    @IBOutlet weak var txtFieldEmail: UITextField!
    @IBOutlet weak var txtFieldPassword: UITextField!
    @IBOutlet weak var profileImage: UIImageView!
    
    
    let imagePickerVC = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePickerVC.sourceType = .photoLibrary
        imagePickerVC.delegate = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyBoard))
        self.view.addGestureRecognizer(tap)
    }

    // MARK: - 註冊會員
    @IBAction func action_register(_ sender: Any) {
        
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
        guard let fullname = txtFieldFullName.text else {
            showError("未填表完成")
            return
        }
        guard let username = txtFieldUserName.text?.lowercased() else {
            showError("未填表完成")
            return
        }
        guard let profileImage = profileImage else {
            showError("未加入圖片")
            return
        }
        guard let imageData = profileImage.image?.jpegData(compressionQuality: 0.1) else {
            // profileImage.jpegData(compressionQuality: 0.5) else {
            showError("圖片轉擋成JPEG失敗")
            return
        }
        
        let filename = NSUUID().uuidString
        
        // 上傳照片
        let ref = Storage.storage().reference(withPath: "/profile_images/\(filename)")
        ref.putData(imageData, metadata: nil) { (meta, error) in
            print("DEBUG: 上傳User 大頭照到firebase storage 失敗: \(String(describing: error?.localizedDescription))")
            AlertUtil.showMessage(message: "上傳大頭照到失敗 \(String(describing: error?.localizedDescription))")
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
                            "fullname":fullname,
                            "imageUrl":"\(profileImageUrl)",
                            "uid":uid,
                            "username":username] as [String:Any]
                
                // Create database
                Firestore.firestore().collection("users").document(uid).setData(data) { error in
                    if error != nil {
                        print("DEBUG: 上傳User資料失敗: \(String(describing: error?.localizedDescription))")
                        return
                    } else {
                        print("DEBUG: 上傳User資料成功")
                        self.navigationController?.popViewController(animated: true)
                    }
//                    AlertUtil.showMessage(vc: self, message: "註冊成功") { alert in
//                        self.navigationController?.popViewController(animated: true)
//                    }
                    
                }
            }
        }
        self.dismiss(animated: true, completion: nil)
        
        
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
    }
    
    
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


