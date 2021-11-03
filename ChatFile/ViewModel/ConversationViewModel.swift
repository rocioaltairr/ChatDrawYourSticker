//
//  ConversationViewModel.swift
//  ChatFile
//
//  Created by 2008007NB01 on 2021/11/1.
//

import Foundation
import FirebaseAuth

struct ConversationCellViewModel {
    let imageData : Data
    let strName : String
    let strMessage : String
    let strTime : String
    let sentDate: Date
    let chatToUser: User
}

class ConversationViewModel {
    var conversations = [Conversation]()
    let apiService:ConversationManager // 一創建ConversationViewModel 就會創見ConversationManager
    
    init(apiService:ConversationManager = ConversationManager.shared) {
        self.apiService = apiService
    }
    var reloadTableViewClosure: (()->())?
    
    private var cellViewModels:[ConversationCellViewModel] = [ConversationCellViewModel]() {
        didSet {
            self.cellViewModels = self.cellViewModels.unique { $0.strMessage }
            self.cellViewModels = self.cellViewModels.sorted(by: {$0.sentDate > $1.sentDate})// 排序最早的在前面
            self.reloadTableViewClosure?()
        }
    }
    
    var numberOfCells: Int {
        return cellViewModels.count
    }
    
    func getCellViewModel (at indexPath:IndexPath) -> ConversationCellViewModel {
        return cellViewModels[indexPath.row]
    }
    
    func getCellUser (at indexPath:IndexPath) -> User {
        return cellViewModels[indexPath.row].chatToUser
    }

    func fetchAllConversation() {
        ConversationManager.shared.fetchConversations {[weak self] con in
            guard let self = self else { return }
            if con.count == 0 {
                ///LodingActivityIndicatorUtil.shared.hideLoader()
                return
            }
            self.conversations = con
            
            self.conversations = self.conversations.unique{$0.message.messageId}
            self.cellViewModels.removeAll()
            for i in 0..<self.conversations.count {
                self.createCellViewModel(con:self.conversations[i]) { cellVM in
                    self.cellViewModels.append(cellVM)
                }
            }
            
            // self.reloadTableViewClosure?()
        }
    }
    
    func createCellViewModel(con:Conversation,completion: @escaping(ConversationCellViewModel) -> Void) {
       
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let strDate = dateFormatter.string(from: con.message.timestamp.dateValue())
        if let imageData = UserDefaults.standard.data(forKey: "otherUserImage\(con.user.uid)") {
            completion(ConversationCellViewModel(imageData:imageData ,strName: con.user.username, strMessage: con.message.text ?? "", strTime: strDate, sentDate: con.message.timestamp.dateValue(), chatToUser: con.user))
        } else {
            MessageManager.shared.fetchImage(withFileName: con.imgUrl) { data in
                if let img = data {
                    UserDefaultUtil.save(key: "otherUserImage\(con.user.uid)", saveObj: img)
                    completion(ConversationCellViewModel(imageData:img ,strName: con.user.username, strMessage: con.message.text ?? "", strTime: strDate, sentDate: con.message.timestamp.dateValue(), chatToUser: con.user))
                }
            }
        }
    }
}
