//
//  AuthManager.swift
//  ChatGame
//
//  Created by 白白 on 2021/2/3.
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
}

struct AuthManager {
    static let shared = AuthManager()
    
    // MARK: - 登入
    func logUserIn(withEmail email:String, password:String,completion: AuthDataResultCallback?) {
        Auth.auth().signIn(withEmail: email, password: password, completion: completion)
    }
    
    // MARK: - 創造User
    func createUser(credentails: RegistrationCredentials, completion: @escaping ((Error?)->Void)) {
        guard let imageData = credentails.profileImage.jpegData(compressionQuality: 0.5) else { return }
        
        let filename = "\(NSUUID().uuidString)"
        // 上傳照片
        let ref = Storage.storage().reference(withPath: "profile_images/\(filename)")
        ref.putData(imageData, metadata: nil) { (meta, error) in
            if error != nil {
                return
            }
            
            ref.downloadURL { (url, error) in
                guard let profileImageUrl = url?.absoluteString else { return }
                // 創造user 需要存在database的image路徑
                Auth.auth().createUser(withEmail: credentails.email, password: credentails.password) { (result, error) in
                    
                    guard let uid = result?.user.uid else { return }
                    
                    let data = ["email":credentails.email,
                                "fullname":credentails.fullname,
                                "imageUrl":profileImageUrl,
                                "uid":uid,
                                "username":credentails.username] as [String:Any]
                    Firestore.firestore().collection("users").document(uid).setData(data, completion: completion)
                }
            }
        }
    }
    
    // MARK: - 登出
    func logUserOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("DEBUG: Error signing out..")
        }
    }
}

