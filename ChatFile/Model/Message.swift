//
//  Message.swift
//  ChatGame
//
//  Created by 2008007NB01 on 2021/2/8.
//

import Firebase


struct Message {
    let text: String?
    /// 文字
    var toID: String?
    /// 發給誰
    var fromID: String?
    /// 誰發的
    var timestamp: Timestamp!
    var user: User?
    var isRead: Bool?
    var messageId: String?
    let isFromCurrentUser: Bool
    
    init(dictionary: [String: Any]) {
        self.text = dictionary["text"] as? String ?? ""
        self.toID = dictionary["toID"] as? String ?? ""
        self.fromID = dictionary["fromID"] as? String ?? ""
        self.timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: Date())
        self.isFromCurrentUser = fromID == Auth.auth().currentUser?.uid
        self.isRead = dictionary["isRead"] as? Bool ?? false
        self.messageId = dictionary["messageId"] as? String ?? ""
    }// Message 是 Struct ，可以直接用屬性監聽，因為任何變動都會觸發didset
    // didSet 及被新實體取代
    // Struct 是本地端，指向實體，所以適合Model中的資料物件，比較好debug也比較不會有不預期的問題
    
    // 如果希望資料物件是單純的資料而已，也就是所有的變更偵測、通知發送與值的同步等具遠端性的功能全部交給別的物件去做的話，那麼把它寫成 struct 是可以幫助你將職責劃分清楚的，而這也會讓偵錯更方便
    // 然而，如果希望它能夠不受限於本地，自己就有以上這些功能的話，那麼把它寫成 class 也是合理的做法。

    
    /*
     let kitty = Cat()
     kitty.number = 12
     let mewo = kitty
     mewo.number = 14
     print(kitty.number) // 14
     */
    

}

struct Conversation {
    let user: User
    let message: Message
    let imgUrl: String
}
