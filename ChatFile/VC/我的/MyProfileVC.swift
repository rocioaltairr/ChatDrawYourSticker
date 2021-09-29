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
import JGProgressHUD

class MyProfileVC: UIViewController {

    @IBOutlet weak var vwProfileImg: UIImageView!
    
    
    @IBOutlet weak var lbEmail: UILabel!
    @IBOutlet weak var lbFullName: UILabel!
    @IBOutlet weak var lbName: UILabel!
    
    var user:User?
    let hud = JGProgressHUD(style: .dark)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hud.textLabel.text = "Loading"
        hud.show(in: self.view)
        
        fetchUserID()

    }
    
    func fetchUserProfileImage() {
        //MARK: - 從Storage下載圖片
        let ref = Storage.storage().reference().child(user!.profileImageUrl)
       // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        ref.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if error != nil {
                print("DEBUG: 取得 Storage 圖片失敗")
            } else {
                let image = UIImage(data: data!)
                
                self.vwProfileImg.image = image
                //let imageData = image?.jpegData(compressionQuality: 32)
                self.hud.dismiss()
            }
            
        }
    }
    
    func fetchUserID() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        UserManager.fetchUser(whitUid: uid) { user in
            self.user = user
            self.lbFullName.text = user.fullname
            self.lbName.text = user.fullname
            self.lbEmail.text = user.email
            self.fetchUserProfileImage()
            
            //print("DEBUG: profile fetch user")
        }
    }


    @IBAction func action_bacl(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

}
