//
//  MessagesChatViewModel.swift
//  ChatFile
//
//  Created by 2008007NB01 on 2021/11/1.
//

import Foundation
import Firebase
import MessageKit

class MessagesChatViewModel {
    var reloadMessageCollectionViewClosure: (()->())?
    var reloadMessageCollectionViewClosureToTop: (()->())?
    var reloadStillNoChatClosure: (()->())?
    var firstDocumentSnapshot: DocumentSnapshot!
    var messagesFirebase: [MessageFirebase]?
    var otherUser: User? // 對方
    var dicMessages:[[Message]] = [[Message]]()
    var messages:[Message] = [Message]() {
        didSet {
            //self.reloadMessageCollectionViewClosure?()
        }
    }
          
//    var numberOfCells: Int {
//        return messages.count
//    }
    
    var numberOfSections: Int {
        return dicMessages.count
        //return messages.count
    }
    
    func getRowNum(section:Int) -> Int {
        return dicMessages[section].count
    }
    
    func getSectionDay(section:Int) -> String {
        return dicMessages[section][0].day
        //return "a"
    }

    
    func getCellViewModel (at indexPath:IndexPath) -> Message {
        return dicMessages[indexPath.section][indexPath.row]
        //return messages[indexPath.row]
    }
    
    func fetchMessage(chatToUser:User?) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        var returnMessage:[Message]  = []
        var query: Query?
        var isfetchingMore = false
        if messages.count == 0 {
            query = COLLECTION_MESSAGES.document(currentUid).collection(chatToUser!.uid).order(by: "timestamp").limit(toLast: 15)
            print("載入前15 messages")
            
        } else {
            query = COLLECTION_MESSAGES.document(currentUid).collection(chatToUser!.uid).order(by: "timestamp").end(beforeDocument: firstDocumentSnapshot).limit(toLast: 8)
            isfetchingMore = true
            print("載入下批 8 messages")
        }
        
        query?.addSnapshotListener { (snapshot, err) in
            if let err = err {
                print("\(err.localizedDescription)")
            } else if snapshot!.isEmpty {
                self.reloadStillNoChatClosure?()
                return
            } else {
                self.firstDocumentSnapshot = snapshot!.documents.first!
                let newMessages = snapshot!.documents.compactMap({MessageFirebase(dictionary: $0.data())})
                
                if self.messagesFirebase != nil {
                    self.messagesFirebase =  newMessages + self.messagesFirebase!
                } else {
                    self.messagesFirebase = newMessages
                }
                
                let myGroup = DispatchGroup()
                for newmessage in newMessages {
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
                    self.messages = returnMessage + self.messages
                    self.messages = self.messages.unique{$0.messageId}
                    self.messages = self.messages.sorted(by:{ $0.sentDate < $1.sentDate})
                    self.dicMessages = self.messages.group(by: {$0.getDay()})
                    if isfetchingMore == true {
                        self.reloadMessageCollectionViewClosureToTop?()
                    } else {
                        self.reloadMessageCollectionViewClosure?()
                    }
                }
            }
        }
    }
}

