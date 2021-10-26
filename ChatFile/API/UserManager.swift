//
//  UserManager.swift
//  ChatGame
//
//  Created by 2008007NB01 on 2021/2/4.
//

import Firebase
import FirebaseFirestore
import FirebaseAuth
//db.collection("songs").order(by: "rate").limit(to: 2).getDocuments { (querySnapshot, error) in
//   if let querySnapshot = querySnapshot {
//      for document in querySnapshot.documents {
//         print(document.data())
//      }
//   }
//}
class UserManager {
    //static let shared = UserManager()
    // 最最最最最新
    static func fetchNewMessage(forUser user:User, completion: @escaping([MessageFirebase]) -> Void) {
        var messages = [MessageFirebase]()
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        COLLECTION_MESSAGES.document(currentUid).collection(user.uid).order(by: "timestamp").addSnapshotListener { (snapshot, error) in
            messages.removeAll()
            snapshot?.documents.forEach({ (change) in
                let newMessages = change.data()
                messages.append(MessageFirebase(dictionary: newMessages))
            })
            completion(messages)
            
        }
    }
    
    // MARK: - 抓取全部Coversation資料
    static func fetchConversations(completion: @escaping([Conversation]) -> Void) {
        var conversations = [Conversation]()
        guard let currentUid = Auth.auth().currentUser?.uid else { return } // 只拿取某個user的 message
        // 抓取使用者全部的聊天紀錄並用時間先後做排序
        let query = COLLECTION_MESSAGES.document(currentUid).collection("recent-messages").order(by: "timestamp")
        
        query.addSnapshotListener { (snapshot, error) in // 每次database有增加東西就觸發
            if snapshot?.documents.count == 0 {
                completion(conversations)
            }
            conversations.removeAll()
            snapshot?.documentChanges.forEach({ change in
                let newMessages = change.document.data()
                let message = MessageFirebase(dictionary: newMessages)
                
                var whith:String = ""
                if message.isFromCurrentUser == true {
                    whith = newMessages["toID"] as! String
                } else {
                    whith =  newMessages["fromID"] as! String
                }
                // 抓取新聊天記錄中對方的姓名和對話
                self.fetchUser(whitUid: whith) { user in
                    let conversation = Conversation(user: user, message: message,imgUrl:user.profileImageUrl)
                    conversations.append(conversation)
                    if conversation.user.uid != currentUid { // 只能顯示他人訊息
                        //conversations.insert(conversation, at: 0) // 最早的要在上面
                        
                    }
                    completion(conversations)
                }
                
            })
        }
    }
    /*
    // MARK: - 抓取更動的Coversation資料
    static func fetchNewConversations(completion: @escaping([Conversation]) -> Void) {
        var conversations = [Conversation]()
        guard let currentUid = Auth.auth().currentUser?.uid else { return } // 只拿取某個user的 message
        // 抓取使用者全部的聊天紀錄並用時間先後做排序
        let query = COLLECTION_MESSAGES.document(currentUid).collection("recent-messages").order(by: "timestamp")
        
        query.getDocuments{ (snapshot, error) in // 每次database有增加東西就觸發
            conversations.removeAll()
            snapshot?.documents.forEach({ document in
                let newMessages = document.data()
                let message = MessageFirebase(dictionary: newMessages)
                
                var whith:String = ""
                if message.isFromCurrentUser == true {
                    whith = newMessages["toID"] as! String
                } else {
                    whith =  newMessages["fromID"] as! String
                }
                // 抓取新聊天記錄中對方的姓名和對話
                self.fetchUser(whitUid: whith) { user in
                    let conversation = Conversation(user: user, message: message,imgUrl:user.profileImageUrl)
                    conversations.append(conversation)
                    if conversation.user.uid != currentUid { // 只能顯示他人訊息
                        //conversations.insert(conversation, at: 0) // 最早的要在上面
                        
                    }
                    
                    completion(conversations)
                }
                
            })
        }
    }*/
    
    // MARK: - 抓取自己使用者
    static func fetchUsers(completion: @escaping([User]) -> Void) {
        COLLECTION_USERS.getDocuments { (snapshot, error) in
            var users = [User]()
            snapshot?.documents.forEach({ (document) in
                let dictionary = document.data()
                let user = User(dictionary: dictionary)
                users.append(user)
                //print("DEBUG: Username is \(user.username)")
                //print("DEBUG: Fullname is \(user.fullname)")
                completion(users)
            })
        }
    }
    
    static func fetchUser(whitUid uid: String, completion: @escaping(User) -> Void) {
        COLLECTION_USERS.document(uid).getDocument{ (snapshot, error) in
            guard let dic = snapshot?.data() else { return }
            let user = User(dictionary: dic)
            completion(user)
        }
    }
    
    // MARK: - 抓取其他使用者
    static func fetchOtherUsers(completion: @escaping([User]) -> Void) {
        
        COLLECTION_USERS.getDocuments { (snapshot, error) in
            var users = [User]()
            snapshot?.documents.forEach({ (document) in
                let dictionary = document.data()
                let user = User(dictionary: dictionary)
                if user.uid != Auth.auth().currentUser?.uid {
                    users.append(user)
                }
                //print("DEBUG: Username is \(user.username)")
                //print("DEBUG: Fullname is \(user.fullname)")
                completion(users)
            })
        }
    }
    
    // MARK: - 抓取聊天訊息
    static func fetchMessage(forUser user:User, completion: @escaping([Message]) -> Void) {
        var messages = [Message]()
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        COLLECTION_MESSAGES.document(currentUid).collection(user.uid).order(by: "timestamp").addSnapshotListener { (snapshot, error) in
            snapshot?.documents.forEach({ (document) in
            let newMessages = document.data()
            messages.append(Message(dictionary: newMessages))
        })
            completion(messages)
            
        }
    }
    // MARK: - 上傳聊天訊息
    static func uploadMessage(_ message: String, to user: User,fileName:String, completion: ((Error?) -> Void)?) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let idMSG = "messageId\(NSUUID().uuidString)"
        let data = ["text": message,
                    "fromID":currentUid,
                    "toID":user.uid,
                    "timestamp": Timestamp(date: Date()),
                    "isRead":false,
                    "messageId":idMSG,
                    "mssageImageUrl":fileName] as [String:Any]
        COLLECTION_MESSAGES.document(currentUid).collection(user.uid).addDocument(data: data) { _ in
            COLLECTION_MESSAGES.document(user.uid).collection(currentUid).addDocument(data: data,completion: completion)
            
            COLLECTION_MESSAGES.document(currentUid).collection("recent-messages").document(user.uid).setData(data)
            
            COLLECTION_MESSAGES.document(user.uid).collection("recent-messages").document(currentUid).setData(data)
            
            // .setData will overwrite .addDocument will not
        }
    }
    
    typealias UploadPictureCompletion = (Result<String, Error>) -> Void
    
    // MARK: - 上傳照片訊息
    static func uploadMessagePhoto(with data: Data,fileName: String, completion: ((Error?) -> Void)?) {
        // 上傳照片
        let ref = Storage.storage().reference(withPath: "message_images/\(fileName)")
        ref.putData(data, metadata: nil) { (meta, error) in
            if error != nil {
                print("DEBUG: 上傳User 大頭照到firebase storage 失敗: \(String(describing: error?.localizedDescription))")
                AlertUtil.showMessage(message: "上傳大頭照到失敗 \(String(describing: error?.localizedDescription))")
            }
            
            return
        }
    }
    
    public enum StorageErrors: Error {
        case failedToUpload
        case failedGetDownloadUrl
    }
    
    // MARK: - 更新使用者資料
    static func updateUser(whitUid uid: String,update: String,updateData: String, completion: @escaping(User) -> Void) {
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

class StorageManager {
    static let shared = StorageManager()
    
    private let storage = Storage.storage().reference()
    
    public typealias UploadPictureCompletion = (Result<String, Error>)
    
    public func uploadProfilePicture(with data: Data, fileName: String, completion: UploadPictureCompletion ) {
        storage.child("images/\(fileName)").putData(data, metadata: nil,completion: { (meta, error) in
            guard error == nil else {
                //faild
                //StorageErrors.failedToUpload
                print("Failed to upload data to firebase picture.")
                return
            }
            
            self.storage.child("images/\(fileName)").downloadURL { url, error in
                guard url != nil else {
                    print("faild to get download url")
                    
                    return
                }
            }
        })
    }
    
    public enum StorageErrors: Error {
        case failedToUpload
    }
}


