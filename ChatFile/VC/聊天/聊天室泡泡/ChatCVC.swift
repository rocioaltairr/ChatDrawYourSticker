//
//  ChatCVC.swift
//  ChatGame
//
//  Created by 2008007NB01 on 2021/2/5.
//

import UIKit
import FirebaseStorage
import JGProgressHUD
import FirebaseAuth
import MessageKit

private let reuseIdentifier = "MessageCVCell"

class ChatCVC: UICollectionViewController {
    
    var nsCache = NSCache<NSString, ImageCache>()
    
    private let user: User
    private var messages = [Message]()
    let hud = JGProgressHUD(style: .dark)
    var profileImage: UIImage?
    var selectedIndex:Int = 0
    
    private lazy var customInputView: CustomInputAccessoryView = {
        let iv = CustomInputAccessoryView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 50))
        iv.delegate = self
        return iv
    }()
    
    
    func setUpHeader() {
        let viewWidth = self.view.bounds.size.width
        let vwTop = UIView(frame: CGRect(x: 0, y:-UIScreen.SAFE_AREA_TOP, width: viewWidth, height: UIScreen.SAFE_AREA_TOP + 15))
        let vwHeader = UIView(frame: CGRect(x: 0, y:0, width: viewWidth, height: 60))
        let lbHeader = UILabel(frame: CGRect(x: 0, y:0, width: viewWidth , height: 20))
        let btnBack = UIButton(frame: CGRect(x: 12, y: 0, width: 60 , height: 60))
        btnBack.setImage(UIImage(named: "navBack"), for: .normal)
        btnBack.addTarget(self, action: #selector(action_back(_:)), for: .touchUpInside)
        
        vwTop.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8832397461)
        lbHeader.text = user.username
        lbHeader.textAlignment = .center
        lbHeader.textColor = .white
        vwHeader.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8832397461)
        vwHeader.addSubview(lbHeader)
        vwHeader.addSubview(btnBack)
        
        self.view.addSubview(vwHeader)
        self.view.addSubview(vwTop)
    }
    
    @objc func action_back(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    
    init(user: User) {
        self.user = user
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init has not been implement")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setUpHeader()
        fetchMessages()
    }
    
    
    func configureUI() {
        collectionView.backgroundColor = .white
        configureNavigationBar(withTitle: user.username, prefersLargeTitles: false)
        
        collectionView.register(MessageCVCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.alwaysBounceVertical = true
        // 滑動時取消keyboard
        collectionView.keyboardDismissMode = .interactive
        // 自適應高度
        (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.estimatedItemSize = UICollectionViewFlowLayout.automaticSize

    }
    
    
    override var inputAccessoryView: UIView? { // ??
        get { return customInputView }
    }
    
    override var canBecomeFirstResponder: Bool { // ??
        return true
    }
    
    
    func fetchMessages() {
//        UserManager.newFetchMessage(forUser: user) { [self] (messages)  in
//            self.messages = messages
//
//
//            self.collectionView.reloadData()
//            self.collectionView.scrollToItem(at: [0, self.messages.count - 1],
//                                             at: .bottom, animated: true) // 有鍵盤時在最下面
//
//        }

    }
    

}

extension ChatCVC {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MessageCVCell
        
        cell.message = messages[indexPath.row]
        
        // 顯示對方照片
        if let cachedVersion = nsCache.object(forKey: "otherUserImage\(selectedIndex)" as NSString) {
            cell.profileImageView.image = cachedVersion.image
        }

        return cell
        
    }
    
    
}

extension ChatCVC: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 46) //add your height here
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 16, left: 0, bottom: 16, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: view.frame.width, height: 50)
//        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
//        let estimatedSizeCell = MessageCVCell(frame: frame)
//        estimatedSizeCell.layoutIfNeeded()
//
//        let targetSize = CGSize(width: view.frame.width , height: 1000)
//        let estimatedSize = estimatedSizeCell.systemLayoutSizeFitting(targetSize)
//
//        return .init(width: view.frame.width, height: estimatedSize.height)
    }
}

extension ChatCVC: CustomInputAccessoryViewDelegate {
    func presentAdd() {
        print("DEBUG:ADD")
    }

    func presentCameraInput() {
        self.presentPhotoPicker()//拍照
    }

    func presentAlbum() {
        self.presentAlbum()//照片
    }
        
    func inputView(_ inputView: CustomInputAccessoryView, wantsToSend message: String) {
        // upload
        UserManager.uploadMessage(message, to:user, fileName: "") { error in
            if error != nil {
                //print("DEBUG: Failed to upload message with error. \(error.localizedDescription)")
                return
            } else {
               // self.fetchMessages()
                
            }
        }
        inputView.clearSendMessage()
    }
    

}
  

extension ChatCVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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

    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        if let selectedImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage
        {
         
            profileImage = selectedImage
    
            
            dismiss(animated: true, completion: nil)
        }
        else
        {
            fatalError("error while selectig image \(info)")
        }
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


//extension ChatCVC: UIImagePickerControllerDelegate & UINavigationControllerDelegate{
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        picker.dismiss(animated: true, completion: nil)
//    }
//
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        // Local variable inserted by Swift 4.2 migrator.
//        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
//
//        if let selectedImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage
//        {
//            profileImage = selectedImage
//            guard let imageData = profileImage?.jpegData(compressionQuality: 0.5) else {
//                showError("圖片轉擋失敗Data-->jpg")
//                return
//            }
//
//            let filename = NSUUID().uuidString
//            // 上傳照片
//            let ref = Storage.storage().reference(withPath: "/message_images/\(filename)")
//            ref.putData(imageData, metadata: nil) { (meta, error) in
//                //print("DEBUG: Failed upload image to firebase storage \(error?.localizedDescription)")
//                return
//            }
//
//
//            dismiss(animated: true, completion: nil)
//        }
//        else
//        {
//            fatalError("error while selectig image \(info)")
//        }
//    }
//}
//
//// Helper function inserted by Swift 4.2 migrator.
//fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
//    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
//}
//
//// Helper function inserted by Swift 4.2 migrator.
//fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
//    return input.rawValue
//}


