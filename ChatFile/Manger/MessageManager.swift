//
//  MessageManager.swift
//  ChatFile
//
//  Created by 白白 on 2021/10/29.
//

//import Foundation
import Firebase
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import MessageKit

class MessageManager {
    
    static let shared = MessageManager()
    
    func fetchMessage(docSnapShot:DocumentSnapshot?,fecthcedMessages: [MessageFirebase]?,messages:[Message]?,chatToUser:User?, completion: @escaping([Message],DocumentSnapshot,[MessageFirebase]) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        var returnMessage:[Message]  = []
        var firstDocumentSnapshot = docSnapShot
        var messagesFirebase:[MessageFirebase]? = fecthcedMessages
        var query: Query?
        
        if messages?.count == 0 {
            query = COLLECTION_MESSAGES.document(currentUid).collection(chatToUser!.uid).order(by: "timestamp").limit(toLast: 15)
            print("載入前15 messages")
        } else {
            query = COLLECTION_MESSAGES.document(currentUid).collection(chatToUser!.uid).order(by: "timestamp").end(beforeDocument: docSnapShot!).limit(toLast: 8)
            print("載入下批 8 messages")
        }
        
        query?.addSnapshotListener { (snapshot, err) in
            if let err = err {
                print("\(err.localizedDescription)")
            } else if snapshot!.isEmpty {
                return
            } else {
                firstDocumentSnapshot = snapshot!.documents.first!
                
                let newMessages = snapshot!.documents.compactMap({MessageFirebase(dictionary: $0.data())})
                
                if messagesFirebase != nil {
                    messagesFirebase =  newMessages + messagesFirebase!
                } else {
                    messagesFirebase = newMessages
                }
                
                let myGroup = DispatchGroup()
                for newmessage in newMessages {
                    //self.messages.removeAll()
                    myGroup.enter()
                    if newmessage.mssageImageUrl == "" || newmessage.mssageImageUrl == nil { // 文字
                        returnMessage.append(Message(sender: SenderUser(senderId:(newmessage.fromID!),displayName:chatToUser?.username ?? ""),
                                                        messageId: (newmessage.messageId)!,
                                                        sentDate: (newmessage.timestamp.dateValue()),
                                                        kind: MessageKind.text((newmessage.text)!)))
                        myGroup.leave()
                    } else { // 照片
                        let ref = Storage.storage().reference(withPath: "message_images/\(newmessage.mssageImageUrl ?? "")")
                        ref.getData(maxSize: 1 * 1024 * 1024) { data, error in
                            if error != nil {
                                print("DEBUG: 取得 Storage 圖片失敗 \(error?.localizedDescription ?? "")")
                            } else {
                                if let imageData = data,let image = UIImage(data: imageData){
                                    let photoHeight = image.size.height
                                    let photoWidth = image.size.width
                                    returnMessage.append(Message(sender: SenderUser(senderId:(newmessage.fromID ?? ""),displayName:chatToUser?.username ?? ""),messageId: newmessage.messageId ?? "",sentDate: newmessage.timestamp.dateValue(),kind:MessageKind.photo(MediaNew(url:nil,image:image,placeholderImage:image,size:CGSize(width: 250, height: 250 * photoHeight / photoWidth)))))
                                }
                            }
                            myGroup.leave()
                        }
                    }
                }
                myGroup.notify(queue: .main) {
                    completion(returnMessage,firstDocumentSnapshot!,messagesFirebase!)
                }
            }
        }
    }
    

    
    // MARK: - 抓取聊天訊息
    func fetchNewMessage(forUser user:User, completion: @escaping([MessageFirebase]) -> Void) {
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
    
    // MARK: - 上傳聊天訊息
    func uploadMessage(_ message: String, to user: User,fileName:String, completion: ((Error?) -> Void)?) {
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
        }
    }
    
    // MARK: - 取得照片
    func fetchImage(withFileName fileName: String,completion: @escaping(Data?) -> Void) {
        var imageData:Data?
        let refUser = Storage.storage().reference().child(fileName)
        refUser.getData(maxSize: 1 * 1024 * 1024) { data, error in //取得使用者大頭貼照
            if error != nil { print("DEBUG: 從Storage取得圖片失敗") }
            if let imgData = data {
                imageData = imgData
            }
            completion(imageData)
        }
    }
    
    // MARK: - 上傳照片
    func uploadImage(with imageData:Data, fileName: String, compoletion: ((Error?) -> Void)? ) {
        let ref = Storage.storage().reference(withPath: "/profile_images/\(fileName)")
        ref.putData(imageData, metadata: nil) { (meta, error) in
            if error != nil {
                print("DEBUG: 上傳照片到 firebase storage 失敗: \(error?.localizedDescription ?? "")")
            }
            return
        }
    }
    
    // MARK: - 上傳照片訊息
    func uploadMessagePhoto(with data: Data,fileName: String, completion: ((Error?) -> Void)?) {
        // 上傳照片
        let ref = Storage.storage().reference(withPath: "message_images/\(fileName)")
        ref.putData(data, metadata: nil) { (meta, error) in
            if error != nil {
                print("DEBUG: 上傳User 大頭照到firebase storage 失敗: \(String(describing: error?.localizedDescription))")
                AlertUtil.showMessage(message: "上傳大頭照到失敗 \(String(describing: error?.localizedDescription))")
            } else {
                print("DEBUG: 上傳User 大頭照到firebase storage 成功")
                completion!(nil)
            }
            
            return
        }
    }
}

