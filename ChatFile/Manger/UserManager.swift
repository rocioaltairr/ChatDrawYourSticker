//
//  UserManager.swift
//  ChatGame
//
//  Created by 白白 on 2021/2/4.
//

import Firebase
import FirebaseFirestore
import FirebaseAuth

typealias UploadPictureCompletion = (Result<String, Error>) -> Void

public enum StorageErrors: Error {
    case failedToUpload
    case failedGetDownloadUrl
}
class UserManager {
    static let shared = UserManager()
    
    // MARK: - 抓取自己使用者
    func fetchUser(whitUid uid: String, completion: @escaping(User) -> Void) {
        COLLECTION_USERS.document(uid).getDocument{ (snapshot, error) in
            guard let dic = snapshot?.data() else { return }
            let user = User(dictionary: dic)
            completion(user)
        }
    }
    
    // MARK: - 抓取其他使用者
    func fetchOtherUsers(completion: @escaping([User]) -> Void) {
        COLLECTION_USERS.getDocuments { (snapshot, error) in
            var users = [User]()
            snapshot?.documents.forEach({ (document) in
                let dictionary = document.data()
                let user = User(dictionary: dictionary)
                if user.uid != Auth.auth().currentUser?.uid {
                    users.append(user)
                }
                completion(users)
            })
        }
    }
    
    // MARK: - 更新使用者資料
    func updateUser(whitUid uid: String,update: String,updateData: String) {
        let updateReference = COLLECTION_USERS.document(uid)
        updateReference.getDocument { (document, err) in
            if let err = err {
                print(err.localizedDescription)
            }
            else {
                document?.reference.updateData([
                    "\(update)": updateData
                ])
                
            }
        }
    }
}


