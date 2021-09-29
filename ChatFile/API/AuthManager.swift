//
//  AuthManager.swift
//  ChatGame
//
//  Created by 2008007NB01 on 2021/2/3.
//

import Foundation
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore


struct RegistrationCredentials {
    let email: String
    let password: String
    let fullname: String
    let username: String
    let profileImage: UIImage
   // let profileImageUrl:String
}
// API file to manage datebase
struct AuthManager {
    static let shared = AuthManager() // make usure we use the same instance and not to create it multiple time.
    func logUserIn(withEmail email:String, password:String,completion: AuthDataResultCallback?) {
        Auth.auth().signIn(withEmail: email, password: password, completion: completion)

    }
    
    
    func createUser(credentails: RegistrationCredentials, completion: @escaping ((Error?)->Void)) {
        guard let imageData = credentails.profileImage.jpegData(compressionQuality: 0.5) else { return }
        
        let filename = NSUUID().uuidString
        
        // 上傳照片
        let ref = Storage.storage().reference(withPath: "/profile_images/\(filename)")
        ref.putData(imageData, metadata: nil) { (meta, error) in
            if error != nil {
                //print("DEBUG: Failed upload image to firebase storage \(errorMsg.localizedDescription)")
                return
            }
            
            ref.downloadURL { (url, error) in
                guard let profileImageUrl = url?.absoluteString else { return }
                // 創造user 需要存在database的image路徑
                Auth.auth().createUser(withEmail: credentails.email, password: credentails.password) { (result, error) in
                    if error != nil {
                      //  print("DEBUG: Failed to create with error: \(error.localizedDescription)")
                    }
                    
                    guard let uid = result?.user.uid else { return }
                    
                    let data = ["email":credentails.email,
                                "fullname":credentails.fullname,
                                "imageUrl":profileImageUrl,
                                "uid":uid,
                                "username":credentails.username] as [String:Any]
                    // Create database
                    Firestore.firestore().collection("users").document(uid).setData(data, completion: completion)
                }
            }
        }
    }
    
    func logUserOut() {
        do {
            try Auth.auth().signOut()
           // presentLoginScreen()
        } catch {
            print("DEBUG: Error signing out..")
        }
    }
    
    
//    func presentLoginScreen() {
//        DispatchQueue.main.async {
//            let vc = LoginVC()
//            let nav = UINavigationController(rootViewController: vc)
//            nav.modalPresentationStyle = .fullScreen
//            nav.present(nav, animated: true) {
//                print("presentLoginScreen()")
//            }
//        }
//    }
}

