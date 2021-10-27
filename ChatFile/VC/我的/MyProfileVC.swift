//
//  MyProfileVC.swift
//  ChatFile
//
//  Created by 2008007NB01 on 2021/9/26.
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
    @IBOutlet weak var lbFullName: UILabel!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var imgBackground: UIImageView!
    @IBOutlet weak var btnLogOut: StyleButton!
    
    var currentUser:User?
    
    var imagePickerUser = UIImagePickerController()
    var imagePickerBackground = UIImagePickerController()
    var imageType: ProfileImageType = .userProfile
    
    var userType: UserType = .currentUser
    var otherUser: User? // 對方
    
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
            fetchOtherUserData()
        }
    }
    

    // MARK: - 取得對方資料
    func fetchOtherUserData() {
        UserManager.fetchUser(whitUid: otherUser?.uid ?? "") { user in
            self.currentUser = user
            self.lbFullName.text = user.username
            self.lbName.text = "HI~各位"
        
            if UserDefaults.standard.data(forKey: "otherUserImage\(user.uid)") == nil { // 如果沒有還沒存入UserDefult，就去firebase抓圖
                let refUser = Storage.storage().reference().child("\(user.profileImageUrl)")
                refUser.getData(maxSize: 1 * 1024 * 1024) { data, error in //取得使用者大頭貼照
                    if error != nil { print("DEBUG: 取得 Storage 使用者背景照 圖片失敗") }
                    if let imgData = data {
                        self.vwProfileImg.image = UIImage(data: imgData)
                        UserDefaultUtil.save(key: "otherUserImage\(user.uid)", saveObj: imgData)
                    }
                }
            } else {
                self.vwProfileImg.image = UIImage(data: UserDefaults.standard.data(forKey: "otherUserImage\(user.uid)")!)
            }

            if  UserDefaults.standard.data(forKey: "BackgroundImage\(user.profileImageUrl)") == nil {
                let ref = Storage.storage().reference().child("BackgroundImage\(user.profileImageUrl)")
                ref.getData(maxSize: 1 * 1024 * 1024) { data, error in //取得使用者背景照
                    if error != nil { print("DEBUG: 取得 Storage 使用者背景照 圖片失敗 \(error?.localizedDescription ?? "")")}
                    if let imgData = data {
                        self.imgBackground.image = UIImage(data: imgData)
                        UserDefaultUtil.save(key: "BackgroundImage\(user.profileImageUrl)", saveObj: imgData)
                    }
                }
            } else {
                self.vwProfileImg.image = UIImage(data: UserDefaults.standard.data(forKey: "BackgroundImage\(user.profileImageUrl)")!)
            }
        }
        
    }

    // MARK: - 取得使用者資料
    func fetchUserData() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        UserManager.fetchUser(whitUid: uid) { user in
            self.currentUser = user
            self.lbFullName.text = user.username
            self.lbName.text = "HI~各位"
        
            if UserDefaults.standard.data(forKey: "currentUserImage") == nil { // 如果沒有還沒存入UserDefult，就去firebase抓圖
                let refUser = Storage.storage().reference().child("\(user.profileImageUrl)")
                refUser.getData(maxSize: 1 * 1024 * 1024) { data, error in //取得使用者大頭貼照
                    if error != nil { print("DEBUG: 取得 Storage 使用者背景照 圖片失敗") }
                    if let imgData = data {
                        self.vwProfileImg.image = UIImage(data: imgData)
                        UserDefaultUtil.save(key: "currentUserImage", saveObj: imgData)
                    }
                }
            } else {
                self.vwProfileImg.image = UIImage(data: UserDefaultUtil.loadData(key: "currentUserImage"))
            }

            if  UserDefaults.standard.data(forKey: "currentUserBackgroundImage") == nil {
                let ref = Storage.storage().reference().child("BackgroundImage\(user.profileImageUrl)")
                ref.getData(maxSize: 1 * 1024 * 1024) { data, error in //取得使用者背景照
                    if error != nil { print("DEBUG: 取得 Storage 使用者背景照 圖片失敗 \(error?.localizedDescription ?? "")")}
                    if let imgData = data {
                        self.imgBackground.image = UIImage(data: imgData)
                        UserDefaultUtil.save(key: "currentUserBackgroundImage", saveObj: imgData)
                    }
                }
            } else {
                self.imgBackground.image = UIImage(data: UserDefaultUtil.loadData(key: "currentUserBackgroundImage"))
            }
        }
    }
    
    // MARK: - 選擇照片
    func selectImgAlert() {
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
            imageType = .userProfile
            self.selectImgAlert()
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
        // Local variable inserted by Swift 4.2 migrator.
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
                UserDefaultUtil.save(key: "currentUserBackgroundImage", saveObj: selectedImage.jpegData(compressionQuality: 0.1)!)
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

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}
