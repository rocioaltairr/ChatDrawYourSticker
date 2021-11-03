//
//  ChatMessageKitVC.swift
//  ChatFile
//
//  Created by 白白 on 2021/10/18.
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
    //MARK: - 自己做的輸入框
    private lazy var customInputView: CustomInputAccessoryView = {
        let iv = CustomInputAccessoryView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height:59.5))
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
    var keyboardIsOpen:Bool = false
    
    lazy var viewModel:MessagesChatViewModel = {
        return MessagesChatViewModel()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpHeader()
        self.setupLayout()
        LodingActivityIndicatorUtil.shared.showLoader(view: self.view)
        
        self.viewModel.otherUser = self.otherUser
        
        self.viewModel.fetchMessage(chatToUser: otherUser)
        self.viewModel.reloadMessageCollectionViewClosureToTop = { [weak self] () in
            DispatchQueue.main.async {
                self?.messagesCollectionView.reloadData()
                self?.messagesCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                UpLodingActivityIndicatorUtil.shared.hideLoader()
            }
        }
        
        self.viewModel.reloadStillNoChatClosure = { [weak self] () in
            DispatchQueue.main.async {
                LodingActivityIndicatorUtil.shared.hideLoader()
            }
        }
        self.viewModel.reloadMessageCollectionViewClosure = { [weak self] () in
            DispatchQueue.main.async {
                self?.messagesCollectionView.reloadData()
                self?.messagesCollectionView.scrollToLastItem()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                LodingActivityIndicatorUtil.shared.hideLoader()
            }
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            print("keyboard打開")
            let differenceOfBottomInset = keyboardHeight - 50
            if keyboardHeight > 100 {
                print("keyboard 出來")
                if keyboardIsOpen == false {
                    let contentOffset = CGPoint(x: messagesCollectionView.contentOffset.x, y: messagesCollectionView.contentOffset.y + differenceOfBottomInset)
                    if contentOffset.y <= messagesCollectionView.contentSize.height {
                        print("正常:\(contentOffset.y) :::: \(messagesCollectionView.contentOffset.y)")
                        messagesCollectionView.setContentOffset(contentOffset, animated: false)
                        print("正常 更改後:\(contentOffset.y) :::: \(messagesCollectionView.contentOffset.y)")
                    } else {
                        print("不正常:\(contentOffset.y) :::: \(messagesCollectionView.contentOffset.y)")
                        
                    }
                    keyboardIsOpen = true
                }
            } else {
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        keyboardIsOpen = false
        print("keyboard收起")
    }
    
    func setupLayout() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.contentInset.top = 70
       // scrollsToLastItemOnKeyboardBeginsEditing = true // default false
       // maintainPositionOnKeyboardFrameChanged = true // default false
        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            let bottomLabelAlignment = LabelAlignment(textAlignment: .right, textInsets: .zero)
            layout.setMessageOutgoingMessageBottomLabelAlignment(bottomLabelAlignment)
            layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.attributedTextMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.emojiMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.photoMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.videoMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.locationMessageSizeCalculator.outgoingAvatarSize = .zero
           // layout.sectionHeadersPinToVisibleBounds = true
        }
        
    }
    
    // MARK: - 滑動
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if scrollView == messagesCollectionView {
            if messagesCollectionView.contentOffset.y < 50 { //上滑動
                UpLodingActivityIndicatorUtil.shared.showLoader(view: self.view)
                
                self.viewModel.fetchMessage(chatToUser: otherUser)
                let oldContentSizeHeight = messagesCollectionView.contentSize.height
                messagesCollectionView.reloadData()
                let newContentSizeHeight = messagesCollectionView.contentSize.height
                messagesCollectionView.contentOffset = CGPoint(x:messagesCollectionView.contentOffset.x,y:newContentSizeHeight - oldContentSizeHeight)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    UpLodingActivityIndicatorUtil.shared.hideLoader()
                }
            }
        }
    }
    
    func currentSender() -> SenderType {
        if let currentUser = UserDefaults.standard.data(forKey: "currentUser") {
            do {
                let decoder = JSONDecoder()
                let data = try decoder.decode(User.self, from: currentUser)
                return SenderUser(senderId: data.uid, displayName: data.username)
            } catch {
                print("無法Decode存到Userdefault")
            }
        }
        return SenderUser(senderId: "", displayName: "")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return viewModel.getCellViewModel(at: indexPath)
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return viewModel.numberOfSections
    }
    
    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 10
    }
    
    func numberOfItems(inSection section: Int, in messagesCollectionView: MessagesCollectionView) -> Int {
        return viewModel.getRowNum(section: section)
    }
    
    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        return NSAttributedString(
            string: MessageKitDateFormatter.shared.string(from: message.sentDate),
            attributes: [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10),
                NSAttributedString.Key.foregroundColor: UIColor.systemBlue])
    }
    
    func headerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return CGSize(width: view.frame.width, height: 50)
    }
    
    @objc func action_back(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    var keyboardShowHeight:Int?
    var keyboardHideHeight:Int?

}

extension ChatMessageKitVC: MessagesDisplayDelegate {
    
    // MARK: - Message background color
    func backgroundColor(for message: MessageType,at indexPath: IndexPath,in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .systemBlue : #colorLiteral(red: 0.9274844527, green: 0.9256587625, blue: 0.9554644227, alpha: 1)
    }
    
    func shouldDisplayHeader(for message: MessageType, at indexPath: IndexPath,in messagesCollectionView: MessagesCollectionView) -> Bool {
        return true
    }
    
    func messageHeaderView(for indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageReusableView {
        let header = messagesCollectionView.dequeueReusableHeaderView(MessageReusableView.self, for: indexPath)
        header.backgroundColor = .white
        let vw = UIView()
        vw.frame = CGRect(x: 0, y: 0, width: UIScreen.WIDTH, height: 50)
        vw.backgroundColor = .white
        let lbDate = UILabel()
        lbDate.frame = CGRect(x: 0, y: 0, width: UIScreen.WIDTH, height: 50)
        lbDate.textAlignment = .center
        lbDate.font = UIFont(name: "HelveticaNeue-UltraLight", size: 13)
        lbDate.textColor = .black
        lbDate.text = viewModel.getSectionDay(section: indexPath.section)
        vw.addSubview(lbDate)
        header.addSubview(vw)
        return header
    }
    
    // MARK: - 頭貼照
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard let currentUserUid = Auth.auth().currentUser?.uid else {return}
        if message.sender.senderId == currentUserUid {
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
           // _ = items.map { print("🧀 \($0)") }
            var uploadMessgeTotalySucuess = false
            var profileImage: UIImage?
            self.selectedItems = items
            if let firstItem = items.first {
                switch firstItem {
                case .photo(let photo):
                    LodingActivityIndicatorUtil.shared.showLoader(view: self.view)
                    // self.selectedImageV.image = photo.image
                    DispatchQueue.global(qos: .userInitiated).async { // 好像沒用
                        profileImage = photo.image
                        let mssageImageUrl = "messageImage\(NSUUID().uuidString)"
                        // 上傳照片到Storage
                        
                        MessageManager.shared.uploadMessagePhoto(with: (profileImage?.jpegData(compressionQuality: 0.75))!, fileName: mssageImageUrl, completion: { error in
                            if error == nil {
                                print("DEBUG:上傳Message照片成功")
                                MessageManager.shared.uploadMessage("照片", to:self.otherUser!, fileName: mssageImageUrl) { error in
                                    if error != nil {
                                        print("DEBUG:上傳訊息失敗 \(error?.localizedDescription ?? "")")
                                        MessageManager.shared.uploadMessage("照片", to:self.otherUser!, fileName: mssageImageUrl,completion: nil) // 沒成功再跑一次
                                    } else {
                                        print("DEBUG:上傳訊息成功")
                                        uploadMessgeTotalySucuess = true
                                    }
                                    
                                }
                            } else {
                                print("DEBUG:上傳Message照片失敗 \(error?.localizedDescription ?? "")")
                                MessageManager.shared.uploadMessagePhoto(with: (profileImage?.jpegData(compressionQuality: 0.75))!, fileName: mssageImageUrl, completion:nil) // 沒成功再跑一次
                            }
                            
                        })
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                           print("DEBUG:上傳一秒後")
                        
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
            //_ = items.map { print(" \($0)") }
            self.selectedItems = items
            LodingActivityIndicatorUtil.shared.showLoader(view: self.view)
            var uploadMessgeTotalySucuess = false
            for item in items {
                switch item {
                case .photo(let p):
                    let mssageImageUrl = "messageImage\(NSUUID().uuidString)"
                    LodingActivityIndicatorUtil.shared.showLoader(view: self.view)
                    // 上傳照片到Storage
                    MessageManager.shared.uploadMessagePhoto(with: (p.image.jpegData(compressionQuality: 0.07))!, fileName: mssageImageUrl, completion: { error in
                        if error != nil {
                            print("DEBUG:上傳Message照片失敗 \(error?.localizedDescription ?? "")")
                            MessageManager.shared.uploadMessagePhoto(with: (p.image.jpegData(compressionQuality: 0.07))!, fileName: mssageImageUrl, completion: nil)
                        } else {
                            print("DEBUG:上傳Message照片成功")
                            MessageManager.shared.uploadMessage("照片", to:self.otherUser!, fileName: mssageImageUrl) { error in
                                if error != nil {
                                    print("DEBUG:上傳訊息失敗 \(error?.localizedDescription ?? "")")
                                } else {
                                    print("DEBUG:上傳訊息成功")
                                    uploadMessgeTotalySucuess = true
                                }
                               
                            }
                        }
                    })
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
        LodingActivityIndicatorUtil.shared.showLoader(view: self.view)
        MessageManager.shared.uploadMessage(message, to:otherUser!, fileName: "") { error in
            if error != nil {return}
        }
        customInputView.messageInputTextView.resignFirstResponder()
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
}

// MARK: - 點擊cell
extension ChatMessageKitVC: MessageCellDelegate {
    
    func didTapBackground(in cell: MessageCollectionViewCell) {
        print("didTapBackground")
        customInputView.messageInputTextView.resignFirstResponder()
        //messagesCollectionView.bottomConstraint = customInputView.messageInputTextView.topAnchor
    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        customInputView.messageInputTextView.resignFirstResponder()
       // messagesCollectionView.bottomAnchor = customInputView.messageInputTextView.topAnchor
        print("didTapMessage")
    }
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        customInputView.messageInputTextView.resignFirstResponder()
        //messagesCollectionView.bottomAnchor = customInputView.messageInputTextView.topAnchor
        print("didTapImage")
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
        
    }
    
    // MARK: - 點擊頭像
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        let vc = MyProfileVC()
        vc.userType = .otherUser
        vc.otherUser = otherUser
        self.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true, completion: nil)
        vc.closureClose = { [weak self] () in
            guard let self = self else { return }
        }
        print("didTapAvatar")
    }
    
    func didTapCellTopLabel(in cell: MessageCollectionViewCell) {
        customInputView.messageInputTextView.resignFirstResponder()
        print("didTapCellTopLabel")
    }
    
    func didTapCellBottomLabel(in cell: MessageCollectionViewCell) {
        customInputView.messageInputTextView.resignFirstResponder()
        print("didTapCellBottomLabel")
    }
    
    func didTapMessageTopLabel(in cell: MessageCollectionViewCell) {
        customInputView.messageInputTextView.resignFirstResponder()
        print("didTapMessageBottomLabel")
    }
    
    func didTapMessageBottomLabel(in cell: MessageCollectionViewCell) {
        customInputView.messageInputTextView.resignFirstResponder()
        print("didTapMessageBottomLabel")
    }
    
    func didTapAccessoryView(in cell: MessageCollectionViewCell) {
        customInputView.messageInputTextView.resignFirstResponder()
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

// MARK: - 傳頭貼照片
extension ChatMessageKitVC:sendStickerDelegate {
    func sendTicker(img: UIImage) {
        let mssageImageUrl = "messageImage\(NSUUID().uuidString)"
        //        self.messages.append(Message(sender: SenderUser(senderId:currentUser?.uid ?? "",displayName:currentUser?.username ?? ""),
        //                                        messageId: "",
        //                                        sentDate: Date(),
        //                                        kind:MessageKind.photo(MediaNew(url:nil,image:img,placeholderImage:img,size:CGSize(width: 200, height: 200 )))))
        LodingActivityIndicatorUtil.shared.showLoader(view: self.view)
        MessageManager.shared.uploadMessage("貼圖", to:self.otherUser!, fileName: mssageImageUrl) { error in
            print("DEBUG:上傳照片失敗 \(error?.localizedDescription ?? "")")
        }
        // 上傳照片到Storage
        MessageManager.shared.uploadMessagePhoto(with: (img.jpegData(compressionQuality: 0.75))!, fileName: mssageImageUrl, completion: nil)
        
    }
}
