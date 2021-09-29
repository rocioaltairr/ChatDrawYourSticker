//
//  ChatVC.swift
//  ChatFile
//
//  Created by 2008007NB01 on 2021/8/12.
//
import UIKit
import FirebaseStorage
import JGProgressHUD
import FirebaseAuth
import MessageKit

private let reuseIdentifier = "MessageCVCell"

class ChatCVC: UICollectionViewController {
 
    private let user: User
    private var messages = [Message]()
    var fromCurrentUser = false
    let hud = JGProgressHUD(style: .dark)

    var isOnChatCVC:Bool = true
    private var profileImage: UIImage?
    
    
    var nsCache = NSCache<NSString, UIImage>()
    var currentUser : User?
    var otherUser : User?
    
    private lazy var customInputView: CustomInputAccessoryView = {
        let iv = CustomInputAccessoryView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 50))
        iv.delegate = self
        return iv
    }()
    
    init(user: User) {
        self.user = user
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init has not been implement")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.contentInset = UIEdgeInsets(top: 40, left: 0, bottom: 0, right: 0)
        setUpHeader()
        configureUI()
        fetchMessages()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
       /// delegate?.isOnChatCVC()???????
    }
    
    func configureUI() {
        collectionView.backgroundColor = .white
        configureNavigationBar(withTitle: user.username, prefersLargeTitles: false)
        
        collectionView.register(MessageCVCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.alwaysBounceVertical = true
        // 滑動時取消keyboard
        collectionView.keyboardDismissMode = .interactive
        
    }
    func setUpHeader() {
        
        let viewWidth = self.view.bounds.size.width
        let vwTop = UIView(frame: CGRect(x: 0, y:-UIScreen.SAFE_AREA_TOP, width: viewWidth, height: UIScreen.SAFE_AREA_TOP + 20))
        let headerView = UIView(frame: CGRect(x: 0, y:20, width: viewWidth, height: 70))
        let descLabel = UILabel(frame: CGRect(x: 0, y:30, width: viewWidth , height: 20))
        let backBtn = UIButton(frame: CGRect(x: 18, y: 30, width: 20 , height: 20))
        backBtn.setImage(UIImage(named: "back"), for: .normal)
        backBtn.addTarget(self, action: #selector(action_back(_:)), for: .touchUpInside)

        vwTop.backgroundColor = #colorLiteral(red: 0.4309999943, green: 0.8308880516, blue: 0.5249999762, alpha: 0.8338976709)
        descLabel.text = user.username
        descLabel.textAlignment = .center
        headerView.backgroundColor = #colorLiteral(red: 0.4309999943, green: 0.8308880516, blue: 0.5249999762, alpha: 0.8338976709)
        headerView.addSubview(descLabel)
        headerView.addSubview(backBtn)
        
        
        self.view.addSubview(headerView)
        self.view.addSubview(vwTop)
    }
    
    @objc func action_back(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override var inputAccessoryView: UIView? { // ??
        get { return customInputView }
    }
    
    override var canBecomeFirstResponder: Bool { // ??
        return true
    }
    
    var indexReload: Int = 0
    
    func fetchMessages() {
        UserManager.fetchMessage2(forUser: user) { [self] (messages, type, messageId)  in
            self.messages = messages

            for (index,message) in messages.enumerated() {
                if message.messageId == messageId { // 更新已讀UI
                    indexReload = index
                }
            }

            if type == "modified" {
                let indexPathReload = IndexPath(item: indexReload, section: 0)
                self.collectionView.reloadItems(at: [indexPathReload])
            } else {
                self.collectionView.reloadData()
                self.collectionView.scrollToItem(at: [0, self.messages.count - 1],
                                                 at: .bottom, animated: true) // 有鍵盤時在最下面

            }
        }
    }

}

extension ChatCVC {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MessageCVCell
        //message.user = user
        cell.message = messages[indexPath.row]
        //MARK: - 從Storage下載圖片
        
        if messages[indexPath.row].fromID == currentUser?.uid{
            // 顯示使用者照片
           // avatarView.image = imgSender
            cell.profileImageView.image = self.nsCache.object(forKey: "currentUserImage")
            
        } else {
            // 顯示對方照片
            cell.profileImageView.image = self.nsCache.object(forKey: "otherUserImage")
            
        }
//        if cell.profileImageView.image == nil {
//
//            Storage.storage().reference().child(user.profileImageUrl).downloadURL { (url, error) in
//              cell.profileImageView.sd_setImage(with: url, completed: nil)
//            }
//        }
        return cell
    }
}

extension ChatCVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 16, left: 0, bottom: 16, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 自適應高度
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let estimatedSizeCell = MessageCVCell(frame: frame)
        
        
        estimatedSizeCell.layoutIfNeeded()
        
        let targetSize = CGSize(width: view.frame.width , height: 1000)
        let estimatedSize = estimatedSizeCell.systemLayoutSizeFitting(targetSize)
        
        return .init(width: view.frame.width, height: estimatedSize.height)
    }
}

extension ChatCVC: CustomInputAccessoryViewDelegate {
    func inputView(_ inputView: CustomInputAccessoryView, wantsToSend message: String) {
        // upload
        UserManager.uploadMessage(message, to:user) { error in
            if error != nil {
                //print("DEBUG: Failed to upload message with error. \(error.localizedDescription)")
                return
            } else {
               // self.fetchMessages()
                
            }
        }
        inputView.clearSendMessage()
    }
    
    func presentActionSheet() {
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
    }
}
    

extension ChatCVC: UIImagePickerControllerDelegate & UINavigationControllerDelegate{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        if let selectedImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage
        {
            profileImage = selectedImage
            guard let imageData = profileImage?.jpegData(compressionQuality: 0.5) else {
                showError("圖片轉擋失敗Data-->jpg")
                return
            }
            
            let filename = NSUUID().uuidString
            // 上傳照片
            let ref = Storage.storage().reference(withPath: "/message_images/\(filename)")
            ref.putData(imageData, metadata: nil) { (meta, error) in
                //print("DEBUG: Failed upload image to firebase storage \(error?.localizedDescription)")
                return
            }
            

            dismiss(animated: true, completion: nil)
        }
        else
        {
            fatalError("error while selectig image \(info)")
        }
        
//        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage,
//              let imageData = image.pngData() else {
//            return
//        }
        
        //let fileName = "photo_message_" + messageId
       //
        
        // Upload Image
        
        // Send Message
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}


