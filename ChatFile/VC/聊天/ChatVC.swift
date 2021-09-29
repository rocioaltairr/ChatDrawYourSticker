

import UIKit
import MessageKit
import InputBarAccessoryView
import FirebaseStorage
import JGProgressHUD
import FirebaseAuth
 
 

struct Messages: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}

struct Sender: SenderType {
    //var photoURL: String?
    var senderId: String
    var displayName: String
}

struct Media: MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
}

class ChatVC: MessagesViewController{

    
    @IBOutlet weak var lbHeaderTitle: UILabel!
    
    //private var user: User
    private var messages = [Message]()
    var fromCurrentUser = false
    let hud = JGProgressHUD(style: .dark)
    
    var isOnChatCVC:Bool = true
    private var profileImage: UIImage?
    
    var nsCache = NSCache<NSString, UIImage>()
    var currentUser : User?
    var otherUser : User?
    
    
    
    ////////////
    public var isNewConversation = false
    var senderOtherUser :Sender?
    var senderCurrentUser :Sender?
    var imgSender:UIImage?
    var imgOther:UIImage?
  //  private let user: User?
   // var messages = [Message]()
    var messagesType = [MessageType]()
    
    
    
    private lazy var customInputView: CustomInputAccessoryView = {
        let iv = CustomInputAccessoryView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 50))
        iv.delegate = self
        return iv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUsersData()
        fetchMessages()
        self.navigationController?.isNavigationBarHidden = false
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.contentInset.top = 60
        messageInputBar.delegate = self as InputBarAccessoryViewDelegate
        setUpHeader()
        
    }
    
    override var inputAccessoryView: UIView? {
        get { return customInputView}
    }
    
//    func fetchMessages() {
//        messages.append(Msg(sender: senderCurrentUser!,
//                            messageId: "1",
//                            sentDate: Date().addingTimeInterval(-86400),
//                            kind: .text("Hello")))
//        messages.append(Msg(sender: senderCurrentUser!,
//                            messageId: "2",
//                            sentDate: Date().addingTimeInterval(-6400),
//                            kind: .text("Hello2")))
//        messages.append(Msg(sender: senderOtherUser!,
//                            messageId: "2",
//                            sentDate: Date().addingTimeInterval(-600),
//                            kind: .text("Hello2")))
//    }
    
    func fetchMessages() {
        UserManager.fetchMessage(forUser: otherUser!) { msg in
            self.messages = msg
            self.messagesCollectionView.reloadData()
            self.messagesCollectionView.scrollToItem(at: [0, self.messages.count - 1],
                                             at: .bottom, animated: true) // 有鍵盤時在最下面
            print(self.messages)
            
        }
        
//        UserManager.fetchMessage(forUser: currentUser!) { [self] (messages, type, messageId)  in
//            self.messages = messages
//
//            for (index,message) in messages.enumerated() {
//                if message.messageId == messageId { // 更新已讀UI
//                    indexReload = index
//                }
//            }
//
//            if type == "modified" {
//                let indexPathReload = IndexPath(item: indexReload, section: 0)
//                self.collectionView.reloadItems(at: [indexPathReload])
//            } else {
//                self.collectionView.reloadData()
//                self.collectionView.scrollToItem(at: [0, self.messages.count - 1],
//                                                 at: .bottom, animated: true) // 有鍵盤時在最下面
//
//            }
//        }
    }
    
    func fetchUsersData() {

        if let other = otherUser {
            senderOtherUser = Sender(senderId: other.uid, displayName: other.username)
            lbHeaderTitle.text = other.username
        }
        if let user = currentUser {

            senderCurrentUser = Sender(senderId: user.uid, displayName: user.username)
           
        }
    }

    @objc func action_back(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }

    func setUpHeader() {
        
        let viewWidth = self.view.bounds.size.width
        let vwTop = UIView(frame: CGRect(x: 0, y:-UIScreen.SAFE_AREA_TOP, width: viewWidth, height: UIScreen.SAFE_AREA_TOP + 20))
        let headerView = UIView(frame: CGRect(x: 0, y:20, width: viewWidth, height: 70))
        let descLabel = UILabel(frame: CGRect(x: 0, y:30, width: viewWidth , height: 20))
        let backBtn = UIButton(frame: CGRect(x: 18, y: 30, width: 20 , height: 20))
        backBtn.setImage(UIImage(named: "back"), for: .normal)
        backBtn.addTarget(self, action: #selector(action_back(_:)), for: .touchUpInside)

        vwTop.backgroundColor = .green
        descLabel.text = otherUser?.username
        descLabel.textAlignment = .center
        headerView.backgroundColor = .green
        headerView.addSubview(descLabel)
        headerView.addSubview(backBtn)
        
        
        self.view.addSubview(headerView)
        self.view.addSubview(vwTop)
    }
    

    
}

extension ChatVC: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of:" ",with:"").isEmpty else {
            return
        }
        
        print("Sending: \(text)")
        let msg :[String:Any] =
            [
                "text":text,
                "toID":"\(otherUser?.uid ?? "")",
                "fromID":"\(currentUser?.uid ?? "")",
                "timestamp":Date().addingTimeInterval(-10)
                
            ]

        
        messages.append(Message(dictionary: msg))
        messagesType.append(Messages(sender: senderOtherUser!,
                            messageId: "2",
                            sentDate: Date().addingTimeInterval(-10),
                            kind: .text(text)))
        // Send Message
        if isNewConversation {
            // create conversation in database
        } else {
            // append to existing conversation data
        }
    }
    
}

extension ChatVC: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {

    func currentSender() -> SenderType {
        return senderCurrentUser!
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        
        return messages.count
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messagesType[indexPath.section]
    }
    
    // user image 聊天人圖像
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let sender = message.sender
        
        if sender.senderId == senderCurrentUser?.senderId {
            // 顯示使用者照片
           // avatarView.image = imgSender
            avatarView.image = self.nsCache.object(forKey: "currentUserImage")
            
        } else {
            // 顯示對方照片
            avatarView.image = self.nsCache.object(forKey: "otherUserImage")
            
        }
    }

}

extension ChatVC: CustomInputAccessoryViewDelegate {
    func inputView(_ inputView: CustomInputAccessoryView, wantsToSend message: String) {
        // upload
        UserManager.uploadMessage(message, to:otherUser!) { error in
            if error != nil {
                print("DEBUG: Failed to upload message with error. \(error?.localizedDescription)")
                return
            } else {
               // self.fetchMessages()
                
            }
        }
        inputView.clearSendMessage()
    }
    
    func presentActionSheet() {
        /*
        let actionSheet =  UIAlertController(title: "Attach Media", message: "What would you like to attach?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Photo", style: .default, handler: { [weak self] _ in
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = true
            self?.present(picker, animated: true, completion: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.allowsEditing = true
            self?.present(picker, animated: true, completion: nil)
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Video", style: .default, handler: { [weak self] _ in
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Audio", style: .default, handler: { [weak self] _ in
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        present(actionSheet, animated: true, completion: nil)
 */
    }

}
    

