//
//  ChatMessageKitVC.swift
//  ChatFile
//
//  Created by 2008007NB01 on 2021/10/18.
//

import UIKit
import AVFoundation
import AVKit
import MessageKit
import Firebase
import FirebaseCore
import FirebaseFirestore
import ALCameraViewController

import Photos
import YPImagePicker
class ChatMessageKitVC:MessagesViewController, MessagesLayoutDelegate {
    
    var customView = UIView(frame: CGRect(x: 0, y: UIScreen.HEIGHT-150, width: UIScreen.WIDTH, height: 150))
    
    lazy var selectedImageV : UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0,
                                                  y: 0,
                                                  width: UIScreen.main.bounds.width,
                                                  height: UIScreen.main.bounds.height * 0.45))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var customInputView: CustomInputAccessoryView = { // 輸入框
        let iv = CustomInputAccessoryView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height:55))
        iv.backgroundColor = .white
        iv.delegate = self
        
        return iv
    }()
    
    override var inputAccessoryView: UIView? {
        get { return customInputView }
    }
    
    let imagePickerViewController = PhotoLibraryViewController()
    var selectedItems = [YPMediaItem]()
    var otherUser: User? // 對方
    var currentUser : User?
    var profileImage: UIImage?
    
    var messages = [MessageNew]()
    var messagesFirebase: [MessageFirebase]?
    
    var firstDocumentSnapshot: DocumentSnapshot!
    var fetchingMore = false
    
//    func cellBottomLabelAlignment(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> LabelAlignment {
//        if message.sender.senderId == currentUser?.uid {
//            return (UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0))
//        } else {
//            return .right//UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
//        }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpHeader()
        // 初始Layout
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.contentInset.top = 40
        
        
        scrollsToLastItemOnKeyboardBeginsEditing = true // default false
        maintainPositionOnKeyboardFrameChanged = true // default false
        
        LodingActivityIndicatorUtil.shared.showLoader(view: self.view)
        
        loadMessages()
        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            let bottomLabelAlignment = LabelAlignment(textAlignment: .right, textInsets: .zero)
              layout.setMessageOutgoingMessageBottomLabelAlignment(bottomLabelAlignment)
            layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.attributedTextMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.emojiMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.photoMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.videoMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.locationMessageSizeCalculator.outgoingAvatarSize = .zero
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        customInputView.bottomConstraint?.constant = 55
        //customView.removeFromSuperview()
    }
    
    // MARK: - 滑動
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == messagesCollectionView {
            if messagesCollectionView.contentOffset.y < 50 { //上滑動
                UpLodingActivityIndicatorUtil.shared.showLoader(view: self.view)
                loadMessages()
                let oldContentSizeHeight = messagesCollectionView.contentSize.height
                messagesCollectionView.reloadData()
                let newContentSizeHeight = messagesCollectionView.contentSize.height
                messagesCollectionView.contentOffset = CGPoint(x:messagesCollectionView.contentOffset.x,y:newContentSizeHeight - oldContentSizeHeight)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    UpLodingActivityIndicatorUtil.shared.hideLoader()
                })
            }
        }
    }
    
    func loadMessages() {
        fetchingMore = true
        
        var loadMessagesFirst :Bool = false
        var query: Query!
        
        if messages.isEmpty {
            query = COLLECTION_MESSAGES.document(currentUser!.uid).collection(otherUser!.uid).order(by: "timestamp").limit(toLast: 15)
            loadMessagesFirst = true
            print("載入前10 messages")
        } else {
            query = COLLECTION_MESSAGES.document(currentUser!.uid).collection(otherUser!.uid).order(by: "timestamp").end(beforeDocument: firstDocumentSnapshot).limit(toLast: 8)
            loadMessagesFirst = false
            print("載入下批批 5 messages")
        }
        
        query.addSnapshotListener { (snapshot, err) in
            if let err = err {
                print("\(err.localizedDescription)")
            } else if snapshot!.isEmpty {
                LodingActivityIndicatorUtil.shared.hideLoader()
                self.fetchingMore = false
                return
            } else {
                self.firstDocumentSnapshot = snapshot!.documents.first
                
                let newMessages = snapshot!.documents.compactMap({MessageFirebase(dictionary: $0.data())})
                if self.messagesFirebase != nil {
                    self.messagesFirebase =  newMessages + self.messagesFirebase!
                } else {
                    self.messagesFirebase = newMessages
                }
                
                let myGroup = DispatchGroup()
                for newmessage in newMessages {
                    //self.messages.removeAll()
                    myGroup.enter()
                    if newmessage.mssageImageUrl == "" || newmessage.mssageImageUrl == nil { // 文字
                        self.messages.append(MessageNew(sender: SenderNew(senderId:(newmessage.fromID!),displayName:self.otherUser?.username ?? ""),
                                                        messageId: (newmessage.messageId)!,
                                                        sentDate: (newmessage.timestamp.dateValue()) as! Date,
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
                                    self.messages.append(MessageNew(sender: SenderNew(senderId:(newmessage.fromID ?? ""),
                                                                                      displayName:self.otherUser?.username ?? ""),
                                                                    messageId: newmessage.messageId ?? "",
                                                                    sentDate: newmessage.timestamp.dateValue(),
                                                                    kind:MessageKind.photo(MediaNew(url:nil,image:image,placeholderImage:image,size:CGSize(width: 250, height: 250 * photoHeight / photoWidth)))))
                                }
                            }
                            myGroup.leave()
                        }
                    }
                }
                myGroup.notify(queue: .main) {
                    //  print(".\messages載入完成")
                    if loadMessagesFirst == true {
                        self.messages =  self.messages.sorted(by:{ $0.sentDate < $1.sentDate})
                        self.messages = self.messages.unique{$0.messageId}
                        self.fetchingMore = false
                        DispatchQueue.main.async {
                            
                            self.messagesCollectionView.reloadData()
                            self.messagesCollectionView.scrollToLastItem() // 第一次進去滑到最下方
                            LodingActivityIndicatorUtil.shared.hideLoader()
                        }
                    } else {
                        self.messages =  self.messages.sorted(by:{ $0.sentDate < $1.sentDate})
                        self.messages = self.messages.unique{$0.messageId}
                        DispatchQueue.main.async {
                            self.messagesCollectionView.reloadData()
                            self.fetchingMore = false
                            LodingActivityIndicatorUtil.shared.hideLoader()
                            
                        }
                    }
                }
                /*
                 DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                 self.messagesCollectionView.reloadData()
                 self.fetchingMore = false
                 })*/
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
                NSAttributedString.Key.foregroundColor: UIColor.systemBlue])
    }
    
    func headerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return CGSize(width: view.frame.width, height: 75)
    }
    
    @objc func action_back(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func dismissKeyBoard() {
        customInputView.bottomConstraint?.constant = 55
        customInputView.messageInputTextView.resignFirstResponder()
        // customView.removeFromSuperview()
    }
}

extension ChatMessageKitVC: MessagesDisplayDelegate {
    
    // MARK: - Message background color
    func backgroundColor(for message: MessageType,at indexPath: IndexPath,in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .systemBlue : #colorLiteral(red: 0.9274844527, green: 0.9256587625, blue: 0.9554644227, alpha: 1)
    }
    
    /*
     func shouldDisplayHeader(
     for message: MessageType,
     at indexPath: IndexPath,
     in messagesCollectionView: MessagesCollectionView
     ) -> Bool {
     return false
     }*/
    
    // MARK: - 頭貼照
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        if message.sender.senderId == currentUser?.uid {
            avatarView.image = UIImage(data: UserDefaultUtil.loadData(key: "currentUserImage"))
        } else {
            avatarView.image = UIImage(data: UserDefaultUtil.loadData(key: "otherUserImage\(otherUser!.uid)"))
        }
    }
    
    // MARK: - Message style
    func messageStyle(for message: MessageType,at indexPath: IndexPath,in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner =
        isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }
    
    // MARK: - 顯示拍照Picker
    func showCameraPicker() {
        var config = YPImagePickerConfiguration()
        config.library.mediaType = .photo
        
        config.library.itemOverlayType = .grid
        config.shouldSaveNewPicturesToAlbum = false
        config.video.compression = AVAssetExportPresetPassthrough
        config.startOnScreen = .library
        config.screens = [.photo]
        config.wordings.libraryTitle = "Gallery"
        config.hidesStatusBar = false
        config.hidesBottomBar = false
        config.maxCameraZoomFactor = 2.0
        config.library.maxNumberOfItems = 5
        config.gallery.hidesRemoveButton = false
        config.library.preselectedItems = self.selectedItems
        
        let picker = YPImagePicker(configuration: config)
        picker.imagePickerDelegate = self
        picker.navigationBar.tintColor = .white
        picker.didFinishPicking { [weak picker] items, cancelled in
            
            if cancelled {
                print("Picker was canceled")
                picker?.dismiss(animated: true, completion: nil)
                return
            }
            _ = items.map { print("🧀 \($0)") }
            
            self.selectedItems = items
            if let firstItem = items.first {
                switch firstItem {
                case .photo(let photo):
                    self.selectedImageV.image = photo.image
                    DispatchQueue.global(qos: .userInitiated).async { // 好像沒用
                        self.profileImage = photo.image
                        let mssageImageUrl = "messageImage\(NSUUID().uuidString)"
                        let photoHeight = self.profileImage?.size.height
                        let photoWidth = self.profileImage?.size.width
                        self.messages.append(MessageNew(sender: SenderNew(senderId: self.currentUser!.uid, displayName: self.currentUser!.username), messageId: "", sentDate: Date(), kind: MessageKind.photo(MediaNew(url:nil,image:photo.image,placeholderImage:photo.image,size:CGSize(width: 250, height: 250 * photoHeight! / photoWidth! )))))
                        // 上傳message到
                        UserManager.uploadMessage("照片", to:self.otherUser!, fileName: mssageImageUrl) { error in
                            print("DEBUG:上傳照片失敗 \(error?.localizedDescription ?? "")")
                        }
                        // 上傳照片到Storage
                        UserManager.uploadMessagePhoto(with: (self.self.profileImage?.jpegData(compressionQuality: 0.1))!, fileName: mssageImageUrl, completion: nil)
                        
                        DispatchQueue.main.async {
                            LodingActivityIndicatorUtil.shared.hideLoader()
                            self.messagesCollectionView.scrollToLastItem() // 第一次進去滑到最下方
                        }
                    }
                    picker?.dismiss(animated: true, completion: nil)
                case .video(_):
                    print("")
                }
            }
        }
        present(picker, animated: true, completion: nil)
    }
    
    // MARK: - 顯示Library Picker
    func showLibraryPicker() {
        var config = YPImagePickerConfiguration()
        config.library.mediaType = .photo
        config.library.itemOverlayType = .grid
        config.shouldSaveNewPicturesToAlbum = false
        config.video.compression = AVAssetExportPresetPassthrough
        config.startOnScreen = .library
        config.screens = [.library]
        config.wordings.libraryTitle = "Gallery"
        config.hidesStatusBar = false
        config.hidesBottomBar = false
        config.maxCameraZoomFactor = 2.0
        config.library.maxNumberOfItems = 5
        config.gallery.hidesRemoveButton = false
        config.library.preselectedItems = self.selectedItems
        
        let picker = YPImagePicker(configuration: config)
        
        picker.imagePickerDelegate = self
        picker.navigationBar.tintColor = .white
        picker.didFinishPicking { [weak picker] items, cancelled in
            
            if cancelled {
                print("Picker was canceled")
                picker?.dismiss(animated: true, completion: nil)
                return
            }
            _ = items.map { print(" \($0)") }
            self.selectedItems = items
            
            for item in items {
                switch item {
                case .photo(let p):
                    print("🧀\(p.image.description)")
                    self.messages.append(MessageNew(sender: SenderNew(senderId: self.currentUser!.uid, displayName: self.currentUser!.username), messageId: "", sentDate: Date(), kind: MessageKind.photo(MediaNew(url:nil,image:p.image,placeholderImage:p.image,size:CGSize(width: 250, height: 150 )))))
                    let mssageImageUrl = "messageImage\(NSUUID().uuidString)"
                    UserManager.uploadMessage("照片", to:self.otherUser!, fileName: mssageImageUrl) { error in
                        print("DEBUG:上傳照片失敗 \(error?.localizedDescription ?? "")")
                    }
                    // 上傳照片到Storage
                    UserManager.uploadMessagePhoto(with: (p.image.jpegData(compressionQuality: 0.1))!, fileName: mssageImageUrl, completion: nil)
                    
                    DispatchQueue.main.async {
                        self.messages = self.messages.unique{$0.messageId }
                        self.messagesCollectionView.reloadData()
                        self.messagesCollectionView.scrollToLastItem() // 第一次進去滑到最下方
                    }
                    
                case .video(_):
                    print("")
                }
            }
            picker?.dismiss(animated: true, completion: nil)
        }
        present(picker, animated: true, completion: nil)
    }
}

extension ChatMessageKitVC:MessagesDataSource {
    
    
}

// MARK: - 上傳InputAccessoryView
extension ChatMessageKitVC: CustomInputAccessoryViewDelegate {
    func inputChanged() {
    }
    
    func presentCamera() {
        self.showCameraPicker()
        
    }
    
    func presentAdd(isSelected:Bool) {
        let vc = CanvasVC()
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
        /*
         if isKeyBoardShow == true {
         if isAddShow == false {
         customInputView.messageInputTextView.resignFirstResponder()
         inputAccessoryView?.heightConstraint?.constant = 250
         inputAccessoryView?.bottomConstraint?.constant = 250
         customInputView.bottomConstraint?.constant = 250
         isKeyBoardShow = false
         } else {
         print("")
         }
         
         } else {
         if isAddShow == false { // 第一次就點ADD 還沒開啟keyboard
         customView.backgroundColor = UIColor.black
         //                customView.layer.zPosition = CGFloat(MAXFLOAT)
         //                let windowCount = UIApplication.shared.windows.count
         //                UIApplication.shared.windows[windowCount-1].addSubview(customView)
         customInputView.messageInputTextView.resignFirstResponder()
         let btnAdd = UIButton()
         btnAdd.setTitle("畫貼圖", for: .normal)
         btnAdd.backgroundColor = .systemBlue
         btnAdd.addTarget(self, action: #selector(add(_ :)), for: .touchUpInside)
         customView.frame = CGRect(x: 0, y: 55, width: UIScreen.WIDTH, height: 200)
         customInputView.bottomConstraint?.constant = 250
         customInputView.addSubview(customView)
         customView.addSubview(btnAdd)
         btnAdd.centerX(inView: customView)
         btnAdd.centerY(inView: customView)
         btnAdd.setDimensions(height: 50, width: 120)
         isAddShow = true
         } else {
         customInputView.messageInputTextView.becomeFirstResponder()
         isKeyBoardShow = true
         isAddShow = false
         }
         }*/
    }
    
    @objc func add(_ sender:UIButton) {
        let vc = CanvasVC()
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func presentCameraInput() {
        self.showCameraPicker()
    }
    
    func presentAlbum() {
        self.showLibraryPicker()
    }
    
    // MARK: - 送出訊息
    func inputView(_ inputView: CustomInputAccessoryView, wantsToSend message: String) {
        var contentInset:UIEdgeInsets = self.messagesCollectionView.contentInset
        contentInset.bottom = 250
        messagesCollectionView.contentInset = contentInset
        //keyboardWillShow
        UserManager.uploadMessage(message, to:otherUser!, fileName: "") { error in
            if error != nil {return}
        }
        inputView.clearSendMessage()
    }
}

extension ChatMessageKitVC {
    // MARK: - 建立 Header UI
    func setUpHeader() {
        let viewWidth = UIScreen.WIDTH
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
                            
                            self.messages.append(MessageNew(sender: SenderNew(senderId:(firebaseMessages[i].fromID!),displayName:self.otherUser?.username ?? ""),messageId: (firebaseMessages[i].messageId)!,sentDate: (firebaseMessages[i].timestamp.dateValue()) as! Date,kind: MessageKind.text((firebaseMessages[i].text)!)))
                            print("Finished request \(i)")
                            myGroup.leave()
                        } else { // 照片
                            let ref = Storage.storage().reference(withPath: "message_images/\(firebaseMessages[i].mssageImageUrl ?? "")")
                            ref.getData(maxSize: 1 * 1024 * 1024) { data, error in
                                if error != nil {
                                    print("DEBUG: 取得 Storage 圖片失敗 \(error?.localizedDescription ?? "")")
                                } else {
                                    let photoHeight = UIImage(data: data!)!.size.height
                                    let photoWidth = UIImage(data: data!)!.size.width
                                    self.messages.append(MessageNew(sender: SenderNew(senderId:(firebaseMessages[i].fromID!),displayName:self.otherUser?.username ?? ""),
                                                                    messageId: (firebaseMessages[i].messageId)!,
                                                                    sentDate: firebaseMessages[i].timestamp.dateValue(),
                                                                    kind: MessageKind.photo(MediaNew(url:nil,image:UIImage(data: data!),placeholderImage:UIImage(data: data!)!,size:CGSize(width: 250, height: 250 * photoHeight / photoWidth)))))
                                    completion()
                                }
                                print("Finished request \(i)")
                                myGroup.leave()
                            }
                        }
                    }
                    myGroup.notify(queue: .main) {
                        print("Finished all requests.")
                        DispatchQueue.main.async { // 排序最早的在前面
                            self.messages = self.messages.sorted(by: {$0.sentDate < $1.sentDate})
                            self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: false)
                            LodingActivityIndicatorUtil.shared.hideLoader()
                        }
                    }
                }
            }
        }
    }
}
// MARK: - 點擊cell
extension ChatMessageKitVC: MessageCellDelegate {
    
    func didTapBackground(in cell: MessageCollectionViewCell) {
        customInputView.bottomConstraint?.constant = 55
        customInputView.messageInputTextView.resignFirstResponder()
    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        customInputView.bottomConstraint?.constant = 55
        customInputView.messageInputTextView.resignFirstResponder()
        print("didTapMessage")
    }
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        customInputView.bottomConstraint?.constant = 55
        customInputView.messageInputTextView.resignFirstResponder()
        let vc = ShowMessageImageVC()
        
        if let indexPath = messagesCollectionView.indexPath(for: cell),
           let messagesDataSource = messagesCollectionView.messagesDataSource {
            let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
            
            switch message.kind {
            case .photo(let photoItem):
                if let image = photoItem.image {
                    vc.image = image
                }
            default:
                break
            }
        }
        
        self.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true, completion: nil)
        print("didTapImage")
    }
    
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        let vc = MyProfileVC()
        vc.userType = .otherUser
        vc.otherUser = otherUser
        self.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true, completion: nil)
        print("didTapAvatar")
    }
    
    func didTapCellTopLabel(in cell: MessageCollectionViewCell) {
        
    }
    
    func didTapCellBottomLabel(in cell: MessageCollectionViewCell) {
        
    }
    
    func didTapMessageTopLabel(in cell: MessageCollectionViewCell) {
        
    }
    
    func didTapMessageBottomLabel(in cell: MessageCollectionViewCell) {
        
    }
    
    func didTapAccessoryView(in cell: MessageCollectionViewCell) {
        print("didTapAccessoryView")
    }
    
    func didTapPlayButton(in cell: AudioMessageCell) {
        
    }
    
    func didStartAudio(in cell: AudioMessageCell) {
        
    }
    
    func didPauseAudio(in cell: AudioMessageCell) {
        
    }
    
    func didStopAudio(in cell: AudioMessageCell) {
        
    }
}

// MARK: - YPImagePickerDelegate
extension ChatMessageKitVC: YPImagePickerDelegate {
    func imagePickerHasNoItemsInLibrary(_ picker: YPImagePicker) {
        // PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: self)
    }
    
    func shouldAddToSelection(indexPath: IndexPath, numSelections: Int) -> Bool {
        return true // indexPath.row != 2
    }
}

extension ChatMessageKitVC:sendStickerDelegate {
    func sendTicker(img: UIImage) {
        let mssageImageUrl = "messageImage\(NSUUID().uuidString)"
        self.messages.append(MessageNew(sender: SenderNew(senderId:currentUser?.uid ?? "",displayName:currentUser?.username ?? ""),
                                        messageId: "",
                                        sentDate: Date(),
                                        kind:MessageKind.photo(MediaNew(url:nil,image:img,placeholderImage:img,size:CGSize(width: 200, height: 200 )))))
        UserManager.uploadMessage("貼圖", to:self.otherUser!, fileName: mssageImageUrl) { error in
            print("DEBUG:上傳照片失敗 \(error?.localizedDescription ?? "")")
        }
        // 上傳照片到Storage
        UserManager.uploadMessagePhoto(with: (img.jpegData(compressionQuality: 0.1))!, fileName: mssageImageUrl, completion: nil)
        
    }
}
