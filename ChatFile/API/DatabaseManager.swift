//
//  DatabaseManager.swift
//  ChatGame
//
//  Created by 2008007NB01 on 2021/3/15.
//

import Firebase
import FirebaseFirestore
import FirebaseAuth

struct DatabaseManager {
    
    
    /// 新訊息target useremail
    public func createNewConversation(to user: User, message: String, completion: ((Error?) -> Void)?) {
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
    
    /// 
    public func getAllConversations(with id: String, completion: @escaping (Result<String, Error>) -> Void) {
        
    }
    
    /// 發送訊息
    public func getAllMessagesForConversation(with id: String, completion: @escaping (Result<String, Error>) -> Void) {
        
    }
    
    /// 發送訊息
//    func sendMessage(to conversation: String, message:Message, completion: @escaping (Bool) -> Void) {
//        
//    }
}
