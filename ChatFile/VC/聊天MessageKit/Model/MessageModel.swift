//
//  MessageModel.swift
//  ChatFile
//
//  Created by 2008007NB01 on 2021/10/19.
//

import Foundation
import MessageKit
import Firebase
import FirebaseCore
import FirebaseStorage
import FirebaseDatabase
import FirebaseFirestore

struct SenderNew:SenderType {
    var senderId:String
    var displayName:String
    
}
struct MessageNew:MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
    
}
     
struct MessageFirebase {
    let text: String?
    /// 文字
    var toID: String?
    /// 發給誰
    var fromID: String?
    /// 誰發的
    var timestamp: Timestamp
    var user: User?
    var isRead: Bool?
    var messageId: String?
    let isFromCurrentUser: Bool
    var mssageImageUrl:String?
    
    init(dictionary: [String: Any]) {
        self.text = dictionary["text"] as? String ?? ""
        self.toID = dictionary["toID"] as? String ?? ""
        self.fromID = dictionary["fromID"] as? String ?? ""
        self.timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: Date())
        self.isFromCurrentUser = fromID == Auth.auth().currentUser?.uid
        self.isRead = dictionary["isRead"] as? Bool ?? false
        self.messageId = dictionary["messageId"] as? String ?? ""
        self.mssageImageUrl = dictionary["mssageImageUrl"] as? String ?? ""
    }

}


struct MediaNew:MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
}
