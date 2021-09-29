//
//  UserManager.swift
//  ChatGame
//
//  Created by 2008007NB01 on 2021/2/4.
//

import Firebase
import FirebaseFirestore
import FirebaseAuth

struct UserManager {
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
        COLLECTION_MESSAGES.document(currentUid).collection(user.uid).order(by: "timestamp").addSnapshotListener { (snapshot, error) in             snapshot?.documents.forEach({ (document) in
            let newMessages = document.data()
            messages.append(Message(dictionary: newMessages))
        })
        completion(messages)
        // 這邊更新已讀 : 代表我看對對骯訊息 so 去改 對方/我的/訊息 database
//        COLLECTION_MESSAGES.document(user.uid).collection(currentUid).order(by: "timestamp").getDocuments { (snapshot, error) in
//            snapshot?.documents.forEach({ (document) in
//                let newMessages = Message(dictionary: document.data())
//                if newMessages.isRead == false {
//                    document.reference.updateData([
//                        "isRead": true
//                    ])
//                }
//            })
//        }
        }
    }
    
    // MARK: - 抓取聊天訊息
    static func fetchMessage2(forUser user:User, completion: @escaping([Message],_ type:String,_ messageId:String) -> Void) {
            var messages = [Message]()
            var dataType = ""
            var documentId = ""
            guard let currentUid = Auth.auth().currentUser?.uid else { return }
        COLLECTION_MESSAGES.document(currentUid).collection(user.uid).order(by: "timestamp").addSnapshotListener { (snapshot, error) in
                snapshot?.documentChanges.forEach({ (change) in
                    if change.type == .added {
                        var changedMessages = Message(dictionary: change.document.data())
                        dataType = "added"
                        changedMessages.messageId = change.document.documentID
                        documentId = change.document.documentID
                        messages.append(changedMessages)
                    } else if change.type == .modified {
                        var changedMessages = Message(dictionary: change.document.data())
                        changedMessages.messageId = change.document.documentID
                        documentId = change.document.documentID
                        if changedMessages.isRead == true {
                            messages.removeLast()
                            messages.append(changedMessages)
                        }
                        dataType = "modified"
                        print("Modified message: \(change.document.data())")
                    }
                })
            
                completion(messages, dataType, documentId)
            
                // 這邊更新已讀 : 代表我看對對骯訊息 so 去改 對方/我的/訊息 database
                COLLECTION_MESSAGES.document(user.uid).collection(currentUid).order(by: "timestamp").getDocuments { (snapshot, error) in
                    snapshot?.documents.forEach({ (document) in
                        let newMessages = Message(dictionary: document.data())
                        if newMessages.isRead == false {
                            document.reference.updateData([
                                "isRead": true
                            ])
                        }
                    })
                }
            }
        }
    
    
    // MARK: - 抓取新聊天訊息(未讀的)
    static func fetchNewMessage(completion: @escaping([Conversation]) -> Void) {
        var conversations = [Conversation]()
        guard let currentUid = Auth.auth().currentUser?.uid else { return } // 只拿取某個user的 message
        let query = COLLECTION_MESSAGES.document(currentUid).collection("recent-messages").order(by: "timestamp")
        
        query.addSnapshotListener { (snapshot, error) in // 每次database有增加東西就觸發
            // 抓取使用者全部的聊天紀錄並用時間先後做排序
            snapshot?.documentChanges.forEach({ change in
                let newMessages = change.document.data()
                let message = Message(dictionary: newMessages)
                
                // 抓取新聊天記錄中對方的姓名和對話
                self.fetchUser(whitUid: newMessages["fromID"] as! String) { user in
                    let conversation = Conversation(user: user, message: message,imgUrl:user.profileImageUrl)
                    if conversation.user.uid != currentUid { // 只能顯示他人訊息
                        conversations.append(conversation)
                    }
                    completion(conversations)
                }
            })
        }
    }
    
    // MARK: - 上傳聊天訊息
    static func uploadMessage(_ message: String, to user: User, completion: ((Error?) -> Void)?) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let data = ["text": message,
                    "fromID":currentUid,
                    "toID":user.uid,
                    "timestamp": Timestamp(date: Date()),
                    "isRead":false,
                    "messageId":""] as [String:Any]
        COLLECTION_MESSAGES.document(currentUid).collection(user.uid).addDocument(data: data) { _ in
            COLLECTION_MESSAGES.document(user.uid).collection(currentUid).addDocument(data: data,completion: completion)
            
            COLLECTION_MESSAGES.document(currentUid).collection("recent-messages").document(user.uid).setData(data)
            
            COLLECTION_MESSAGES.document(user.uid).collection("recent-messages").document(currentUid).setData(data)
            
            // .setData will overwrite .addDocument will not
        }
    }
    
    typealias UploadPictureCompletion = (Result<String, Error>) -> Void
    
    // MARK: - 上傳照片訊息
    static func uploadMessagePhoto(with data: Data,fileName: String, completion: @escaping UploadPictureCompletion) {
        
        Storage.storage().reference().child("message_images/\(fileName)").putData(data,metadata: nil) { (metadate, error) in
            print("Failed to upload data to firebase for picture.")
            return
        }
        Storage.storage().reference().child("images/\(fileName)").downloadURL { (url, error) in
            guard let url = url else {
                print("Failed to get download url")
                return
            }
            let strUrl = url.absoluteString
            print("download url returned: \(strUrl)")
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
                guard let url = url else {
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


