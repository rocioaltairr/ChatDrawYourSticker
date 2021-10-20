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
    
    var nsCache = NSCache<NSString, ImageCache>()
    var user:User?
    let hud = JGProgressHUD(style: .dark)
    override func viewDidLoad() {
        super.viewDidLoad()
        vwProfileImg.contentMode = .scaleAspectFill
        vwProfileImg.layer.masksToBounds = false
        vwProfileImg.layer.cornerRadius = vwProfileImg.frame.height/2
        vwProfileImg.clipsToBounds = true
        
        //hud.textLabel.text = "Loading"
        //hud.show(in: self.view)
        if let cachedVersion = nsCache.object(forKey: "currentUserImage") {
            vwProfileImg.image = cachedVersion.image
        }
        fetchUserID()

    }

    
    func fetchUserID() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        UserManager.fetchUser(whitUid: uid) { user in
            self.user = user
            self.lbFullName.text = user.fullname
            self.lbName.text = user.fullname
            self.lbEmail.text = user.email
            
            //print("DEBUG: profile fetch user")
        }
    }


    @IBAction func action_bacl(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

}
