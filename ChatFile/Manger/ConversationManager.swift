//
//  ConversationManager.swift
//  ChatFile
//
//  Created by 白白 on 2021/10/29.
//

import FirebaseAuth

class ConversationManager {
    static let shared = ConversationManager()
    
    // MARK: - 抓取全部Coversation資料
    func fetchConversations(completion: @escaping([Conversation]) -> Void) {
        var conversations = [Conversation]()
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
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
                UserManager.shared.fetchUser(whitUid: whith) { user in
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
}
