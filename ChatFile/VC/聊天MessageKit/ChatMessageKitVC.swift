//
//  ChatMessageKitVC.swift
//  ChatFile
//
//  Created by 2008007NB01 on 2021/10/18.
//

import UIKit
import MessageKit
import Firebase
import JGProgressHUD
class ChatMessageKitVC: MessagesViewController, MessagesLayoutDelegate {
    
    private lazy var customInputView: CustomInputAccessoryView = { // 輸入框
        let iv = CustomInputAccessoryView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 50))
        iv.delegate = self
        return iv
    }()
    
    override var inputAccessoryView: UIView? {
        get { return customInputView }
    }
    
    var nsCache = NSCache<NSString, ImageCache>() // 存照片
    var otherUser: User? // 對方
    var currentUser : User?
    var profileImage: UIImage?
    var messages = [MessageNew]()
    var messagesFirebase: [MessageFirebase]?
    let hud = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpHeader()
        hud.show(in: self.view)
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self

        fetchMessages {
       //     self.messages = self.messages.sorted(by: {$0.sentDate < $1.sentDate}) // 排序最早的在前面
//            //self.hud.dismiss()
//            self.messagesCollectionView.reloadData()
//            self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: false)
            //DispatchQueue.main.async {}
        }
    }
    
    // MARK: - 從Firebase 取得Messages
    func fetchMessages(completion:@escaping() -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            print("This is run on a background queue")
            UserManager.fetchNewMessage(forUser: self.otherUser!) { [weak self] (msg)  in
                guard let self = self else { return }
                self.messagesFirebase = msg
                self.messages.removeAll()
                let myGroup = DispatchGroup()
                if let firebaseMessages = self.messagesFirebase {
                    for i in 0..<firebaseMessages.count {
                        myGroup.enter()
                        if firebaseMessages[i].mssageImageUrl == "" || firebaseMessages[i].mssageImageUrl == nil { // 文字
                            
                            self.messages.append(MessageNew(sender: SenderNew(senderId:(firebaseMessages[i].fromID!),displayName:self.otherUser?.username ?? ""),
                                                       messageId: (firebaseMessages[i].messageId)!,
                                                       sentDate: (firebaseMessages[i].timestamp.dateValue()) as! Date,
                                                       kind: MessageKind.text((firebaseMessages[i].text)!)))
                          print("Finished request \(i)")
                            myGroup.leave()
                        } else { // 照片
                            let ref = Storage.storage().reference(withPath: "message_images/\(firebaseMessages[i].mssageImageUrl ?? "")")
                            ref.getData(maxSize: 1 * 1024 * 1024) { data, error in
                                if error != nil {
                                    if let img = self.profileImage { // 取得 image url 再從storage 下載圖片
                                        self.messages.append(MessageNew(sender: SenderNew(senderId: (self.currentUser!.uid), displayName: (self.currentUser!.username)), messageId: "", sentDate: Date(), kind: MessageKind.photo(MediaNew(url:nil,
                                                                       image:img,
                                                                       placeholderImage:img,
                                                                       size:CGSize(width: 250, height: 150)))))
                                    }
                                    
                                    print("DEBUG: 取得 Storage 圖片失敗 \(error?.localizedDescription ?? "")")
                                } else {
                                    self.messages.append(MessageNew(sender: SenderNew(senderId:(firebaseMessages[i].fromID!),displayName:self.otherUser?.username ?? ""),
                                                               messageId: (firebaseMessages[i].messageId)!,
                                                                    sentDate: firebaseMessages[i].timestamp.dateValue(),
                                                               kind: MessageKind.photo(MediaNew(url:nil,
                                                                                                image:UIImage(data: data!),
                                                                                                placeholderImage:UIImage(data: data!)!,
                                                                                                size:CGSize(width: 250, height: 150)))))
                                        completion()
                                }
                                print("Finished request \(i)")
                                myGroup.leave()
                            }
                        }
                    }
                    myGroup.notify(queue: .main) {
                        print("Finished all requests.")
                        DispatchQueue.main.async {
                            
                            self.messages = self.messages.sorted(by: {$0.sentDate < $1.sentDate}) // 排序最早的在前面
                            self.messages = self.messages.sorted(by: {$0.sentDate < $1.sentDate}) // 排序最早的在前面
                            //self.hud.dismiss()
                            self.messagesCollectionView.reloadData()
                            self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: false)
                            self.hud.dismiss()
                        }
                    }
                }
            }
        }
    }
    

    
    func currentSender() -> SenderType {
        return SenderNew(senderId: currentUser?.uid ?? "", displayName: currentUser?.username ?? "")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.row]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return 1
    }
    
    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 10
    }

    func numberOfItems(inSection section: Int, in messagesCollectionView: MessagesCollectionView) -> Int {
        messages.count
    }

    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        return NSAttributedString(
                        string: MessageKitDateFormatter.shared.string(from: message.sentDate),
                        attributes: [
                            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10),
                            NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.1176470588, green: 0.4470588235, blue: 0.8, alpha: 1)])
    }
    
    func headerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return CGSize(width: view.frame.width, height: 60)
    }
    
    @objc func action_back(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
}

//extension ChatMessageKitVC: MessagesLayoutDelegate {
//
//}

extension ChatMessageKitVC: MessagesDisplayDelegate {
    // 1
    func backgroundColor(
      for message: MessageType,
      at indexPath: IndexPath,
      in messagesCollectionView: MessagesCollectionView
    ) -> UIColor {
        return isFromCurrentSender(message: message) ? .systemBlue : .lightGray
    }

    
//    func shouldDisplayHeader(
//      for message: MessageType,
//      at indexPath: IndexPath,
//      in messagesCollectionView: MessagesCollectionView
//    ) -> Bool {
//      return false
//    }
    
    // MARK: - 頭貼照
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        if messagesFirebase?[indexPath.row].isFromCurrentUser == true {
            
            if let cachedVersion = nsCache.object(forKey: "currentUserImage" as NSString) {
                avatarView.image = cachedVersion.image
            }
        } else {
            if let cachedVersion = nsCache.object(forKey: "otherUserImage\(otherUser!.uid)" as NSString) {
                avatarView.image = cachedVersion.image
                
            }
        }
        avatarView.frame = CGRect(x: avatarView.frame.origin.x, y: 0, width: 30.0, height: 30.0)
    }
    
    // 4
    func messageStyle(
      for message: MessageType,
      at indexPath: IndexPath,
      in messagesCollectionView: MessagesCollectionView
    ) -> MessageStyle {
      let corner: MessageStyle.TailCorner =
        isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
      return .bubbleTail(corner, .curved)
    }
}


extension ChatMessageKitVC:MessagesDataSource {
}

// MARK: - 選取圖片
extension ChatMessageKitVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        if let selectedImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage
        {
         
            DispatchQueue.global(qos: .userInitiated).async { // 好像沒用
                self.profileImage = selectedImage
                let mssageImageUrl = "messageImage\(NSUUID().uuidString)"
                self.messages.append(MessageNew(sender: SenderNew(senderId: self.currentUser!.uid, displayName: self.currentUser!.username), messageId: "", sentDate: Date(), kind: MessageKind.photo(MediaNew(url:nil,
                                               image:selectedImage,
                                               placeholderImage:selectedImage,
                                               size:CGSize(width: 250, height: 150)))))

                UserManager.uploadMessage("照片", to:self.otherUser!, fileName: mssageImageUrl) { error in
                    print("DEBUG:上傳照片失敗 \(error?.localizedDescription ?? "")")
                }
                // 上傳照片到Storage
                UserManager.uploadMessagePhoto(with: (self.self.profileImage?.jpegData(compressionQuality: 0.1))!, fileName: mssageImageUrl, completion: nil)

                DispatchQueue.main.async {
                    self.hud.show(in: self.view)
                }
            }
            
            dismiss(animated: true, completion: nil)
        }
        else
        {
            fatalError("error while selectig image \(info)")
        }
    }
    
    func presentCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        self.present(vc, animated: true, completion: nil)
        
    }
    
    func presentPhotoPicker() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        self.present(vc, animated: true, completion: nil)
    }
    
    // Helper function inserted by Swift 4.2 migrator.
    fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
        return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
    }

    // Helper function inserted by Swift 4.2 migrator.
    fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
        return input.rawValue
    }
}

// MARK: - 上傳InputAccessoryView
extension ChatMessageKitVC: CustomInputAccessoryViewDelegate {
    func inputView(_ inputView: CustomInputAccessoryView, wantsToSend message: String) {
        
        UserManager.uploadMessage(message, to:otherUser!, fileName: "") { error in
            if error != nil {
                return
            } else {
            }
        }
        inputView.clearSendMessage()
    }
    
    func presentActionSheet() {
        let actionSheet =  UIAlertController(title: "Attach Media", message: "What would you like to attach?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Photo", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            self.presentPhotoPicker()
        }))
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            self.presentCamera()
            
        }))

        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        present(actionSheet, animated: true, completion: nil)
    }
}

extension ChatMessageKitVC {
    // MARK: - 建立Header
    func setUpHeader() {
        let viewWidth = self.view.bounds.size.width
        let vwTop = UIView(frame: CGRect(x: 0, y:-UIScreen.SAFE_AREA_TOP, width: viewWidth, height: UIScreen.SAFE_AREA_TOP + 15))
        let vwHeader = UIView(frame: CGRect(x: 0, y:15, width: viewWidth, height: 60))
        let lbHeader = UILabel(frame: CGRect(x: 0, y:25, width: viewWidth , height: 20))
        let btnBack = UIButton(frame: CGRect(x: 18, y: 15, width: 40 , height: 40))
        btnBack.setImage(UIImage(named: "navBack"), for: .normal)
        btnBack.addTarget(self, action: #selector(action_back(_:)), for: .touchUpInside)
        
        vwTop.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8832397461)
        lbHeader.text = otherUser?.username
        lbHeader.textAlignment = .center
        lbHeader.textColor = .white
        vwHeader.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8832397461)
        vwHeader.addSubview(lbHeader)
        vwHeader.addSubview(btnBack)
        
        self.view.addSubview(vwHeader)
        self.view.addSubview(vwTop)
    }
}
