//
//  MyProfileVC.swift
//  ChatFile
//
//  Created by 白白 on 2021/9/26.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage

enum ProfileImageType {
    case userProfile
    case userBackground
}

enum UserType {
    case currentUser
    case otherUser
}

class MyProfileVC: UIViewController {
    @IBOutlet weak var vwProfileImg: UIImageView!
    @IBOutlet weak var lbEmail: UILabel!
    
    @IBOutlet weak var txtFieldStatus: UITextField!
    @IBOutlet weak var txtFieldName: UITextField!
    
    @IBOutlet weak var imgBackground: UIImageView!
    @IBOutlet weak var btnLogOut: StyleButton!
    @IBOutlet weak var btnEdit: UIButton!
    
    var currentUser:User?
    var imagePickerUser = UIImagePickerController()
    var imagePickerBackground = UIImagePickerController()
    var imageType: ProfileImageType = .userProfile
    
    var userType: UserType = .currentUser
    var otherUser: User? // 對方
    
    var closureClose:(()->())?
    
    var strName:String?
    var strStatus:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePickerUser.delegate = self
        imagePickerUser.title = "UserImage"
        imagePickerBackground.delegate = self
        imagePickerBackground.title = "BackgroundImage"
        vwProfileImg.contentMode = .scaleAspectFill
        vwProfileImg.layer.masksToBounds = false
        vwProfileImg.layer.cornerRadius = vwProfileImg.frame.height/2
        vwProfileImg.clipsToBounds = true
        
        if userType == .currentUser {
            fetchUserData()
        } else {
            btnLogOut.isHidden = true
            btnEdit.isHidden = true
            fetchOtherUserData()
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.closureClose?()
    }
    
    // MARK: - 取得使用者資料
    func fetchUserData() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        UserManager.shared.fetchUser(whitUid: uid) { user in
            self.currentUser = user
            self.txtFieldName.text = user.username
            self.strName = user.username
            if let status = user.status {
                self.txtFieldStatus.text = status
                self.strStatus = status
            } else {
                self.strStatus = "HI~各位"
            }
            
            if UserDefaults.standard.data(forKey: "currentUserImage") == nil { // 如果沒有還沒存入UserDefult，就去firebase抓圖
                MessageManager.shared.fetchImage(withFileName: user.profileImageUrl) { data in
                    if let imgData = data {
                        self.vwProfileImg.image = UIImage(data: imgData)
                        UserDefaultUtil.save(key: "currentUserImage", saveObj: imgData)
                    }
                }
            } else {
                self.vwProfileImg.image = UIImage(data: UserDefaultUtil.loadData(key: "currentUserImage"))
            }
            
            if  UserDefaults.standard.data(forKey: "currentUserBGImage") == nil {
                MessageManager.shared.fetchImage(withFileName: "BackgroundImageprofile_images\(user.profileImageUrl)") { data in
                    if let imgData = data {
                        self.imgBackground.image = UIImage(data: imgData)
                        UserDefaultUtil.save(key: "currentUserBGImage", saveObj: imgData)
                    }
                }
            } else {
                self.imgBackground.image = UIImage(data: UserDefaultUtil.loadData(key: "currentUserBGImage"))
            }
        }
    }

    // MARK: - 取得對方資料
    func fetchOtherUserData() {
        UserManager.shared.fetchUser(whitUid: otherUser?.uid ?? "") { user in
            self.currentUser = user
            self.txtFieldName.text = user.username
            self.strName = user.username
            if let status = user.status {
                self.txtFieldStatus.text = status
                self.strStatus = status
            } else {
                self.strStatus = "HI~各位"
            }
        
            if UserDefaults.standard.data(forKey: "otherUserImage\(user.uid)") == nil { // 如果沒有還沒存入UserDefult，就去firebase抓圖
                MessageManager.shared.fetchImage(withFileName: "otherUserImage\(user.uid)") { data in
                    if let imgData = data {
                        self.vwProfileImg.image = UIImage(data: imgData)
                        UserDefaultUtil.save(key: "otherUserImage\(user.uid)", saveObj: imgData)
                    }
                }
            } else {
                self.vwProfileImg.image = UIImage(data: UserDefaults.standard.data(forKey: "otherUserImage\(user.uid)")!)
            }

            if  UserDefaults.standard.data(forKey: "BGImage\(user.profileImageUrl)") == nil {
                MessageManager.shared.fetchImage(withFileName: "BGImage\(user.profileImageUrl)") { data in
                    if let imgData = data {
                        self.imgBackground.image = UIImage(data: imgData)
                        UserDefaultUtil.save(key: "BGImage\(user.profileImageUrl)", saveObj: imgData)
                    }
                }
            } else {
                self.vwProfileImg.image = UIImage(data: UserDefaults.standard.data(forKey: "BGImage\(user.profileImageUrl)")!)
            }
        }
    }
    
    // MARK: - 選擇照片
    func selectImgAlert() {
        let alert = UIAlertController(title: "請選擇照片", message: "您想怎麼加入照片呢？", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { [weak self] _ in
            self?.txtFieldStatus.resignFirstResponder()
            self?.txtFieldName.resignFirstResponder()
            self?.view.frame.origin.y = 0
        }))
        alert.addAction(UIAlertAction(title: "拍照", style: .default, handler: { [weak self] _ in
            self?.presentCamera()
        }))
        alert.addAction(UIAlertAction(title: "選擇照片", style: .default, handler: { [weak self] _ in
            self?.presentPhotoPicker()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - 設定頭像圖片
    @IBAction func action_setUserImage(_ sender: Any) {
        if userType == .currentUser {
            imageType = .userProfile
            self.selectImgAlert()
        }
    }
    
    // MARK: - 設定背景圖片
    @IBAction func action_setBackgroundImage(_ sender: Any) {
        if userType == .currentUser {
            imageType = .userBackground
            if txtFieldName.isFirstResponder == false && txtFieldStatus.isFirstResponder == false {
                self.selectImgAlert()
            } else {
                txtFieldName.resignFirstResponder()
                txtFieldStatus.resignFirstResponder()
                self.view.frame.origin.y = 0
            }
        }
    }
    
    // MARK: - 關閉VC
    @IBAction func action_close(_ sender: Any) {
        if userType == .currentUser {
            let transition = CATransition()
            transition.duration = 0.3
            transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            transition.type = CATransitionType.reveal
            transition.subtype = CATransitionSubtype.fromBottom
            navigationController?.view.layer.add(transition, forKey: nil)
            _ = navigationController?.popViewController(animated: false)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - 儲存變更
    @IBAction func action_saveChanges(_ sender: Any) {
        if txtFieldName.text != strName {
            UserManager.shared.updateUser(whitUid: Auth.auth().currentUser!.uid, update: "username", updateData: txtFieldName.text!)
            AlertUtil.showMessage(message: "儲存成功～")
        } else if  txtFieldStatus.text != strStatus {
            UserManager.shared.updateUser(whitUid: Auth.auth().currentUser!.uid, update: "status", updateData: txtFieldStatus.text!)
            AlertUtil.showMessage(message: "儲存成功～")
        } else {
            AlertUtil.showMessage(message: "尚未做變更")
        }
    }
    
    // MARK: - 登出
    @IBAction func action_logout(_ sender: Any) {
        AlertUtil.strBtnCancel = "取消"
        AlertUtil.showMessage(message: "確認登出？") { alert in
            AuthManager.shared.logUserOut()
            self.navigationController?.popToRootViewController(animated: true)
        } cancelHandler: { alert in
            print("DEGUB: 取消登出")
        }
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            if view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardHeight
            }
        }
    }
    
    @objc func dismissKeyboard() {
        if view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
        view.endEditing(true)
    }
}


extension MyProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        if let selectedImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage
        {
            if imageType == .userProfile { // 上傳照片
                
                let ref = Storage.storage().reference(withPath: currentUser?.profileImageUrl ?? "")
                
                ref.putData(selectedImage.jpegData(compressionQuality: 0.1)!, metadata: nil) { (meta, error) in
                    if error != nil {
                        print("DEBUG: 上傳User 大頭照到firebase storage 失敗: \(String(describing: error?.localizedDescription))")
                    }
                    return
                }
                UserDefaultUtil.save(key: "currentUserImage", saveObj: selectedImage.jpegData(compressionQuality: 0.1)!)
                vwProfileImg.image = selectedImage
            } else { // 上傳背景照片
                let ref = Storage.storage().reference(withPath: "BackgroundImage\(currentUser?.profileImageUrl ?? "")")
                
                ref.putData(selectedImage.jpegData(compressionQuality: 0.1)!, metadata: nil) { (meta, error) in
                    if error != nil {
                        print("DEBUG: 上傳使用者背景照片到firebase storage 失敗: \(String(describing: error?.localizedDescription))")
                    }
                    return
                }
                UserDefaultUtil.save(key: "currentUserBGImage", saveObj: selectedImage.jpegData(compressionQuality: 0.1)!)
                imgBackground.image = selectedImage
            }
            
            dismiss(animated: true, completion: nil)
        }
        else
        {
            fatalError("error while selectig image \(info)")
        }
    }
}


fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}


fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}
