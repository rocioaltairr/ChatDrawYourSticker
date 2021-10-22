//
//  ConversationVC.swift
//  ChatFile
//
//  Created by 2008007NB01 on 2021/8/12.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseStorage
import JGProgressHUD
class ConversationVC: UIViewController {

    
    @IBOutlet weak var tbvMain: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var currentUser : User?
    var otherUsers:[User]? = []
    
    let hud = JGProgressHUD(style: .dark)
    var nsCache = NSCache<NSString, ImageCache>()
    private var messages = [Message]()
    var conversations:[Conversation]?
    var conversation:Conversation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hud.textLabel.text = "Loading"
        hud.show(in: self.view)
        searchBar.textField?.font = UIFont.systemFont(ofSize: 12)
        
        self.tbvMain.allowsSelection = true
        self.tbvMain.delegate = self
        self.tbvMain.dataSource = self
        self.tbvMain.register(UINib(nibName: "ConversationsTbvCell", bundle: nil), forCellReuseIdentifier: "ConversationsTbvCell")
        fetchCurrentUser()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //fetchAllConversation()
        fetchUserAndLastMessage()
    }
    
    func fetchAllConversation() {
        
        UserManager.fetchConversations {[weak self] con in
            guard let self = self else { return }
            self.hud.textLabel.text = "Loading"
            self.hud.show(in: self.view)
            
            self.conversations = con
            self.conversations = self.conversations?.sorted(by: {$0.message.timestamp.dateValue() > $1.message.timestamp.dateValue()}) // 排序最早的在前面
            self.tbvMain.reloadData()
        }
    }
    
    func fetchUserAndLastMessage() {
        UserManager.fetchNewConversations {[weak self] con in
            guard let self = self else { return }
//            self.hud.textLabel.text = "Loading"
//            self.hud.show(in: self.view)
            if con.count == 1 { // 如果只有1代表為更新的資料
                self.conversations = con
//                for i in 0..<self.conversations!.count {
//                    if self.conversations?[i].message.user?.username == self.conversation?.message.user?.username {
//                        //self.conversations?.remove(at: i)
//                        self.conversations?[i] = con[0]
//                        //self.conversations?.insert(contentsOf: con, at: 0)
//                        return
//                    }
//                }
            } else {
                self.conversations = con
            }
            //self.conversations = con
//            for i in 0..<self.conversations!.count {
//                if self.conversations?[i].message.user?.uid == self.conversation?.message.user?.uid {
//                    self.conversations?.remove(at: i)
//                    self.conversations?.insert(self.conversation!, at: 0)
//                    self.conversations = self.conversations?.sorted(by: {$0.message.timestamp.dateValue() >  $1.message.timestamp.dateValue()}) // 排序最早的在前面
//                    self.tbvMain.reloadData()
//                }
//
//            }
            
            self.conversations = self.conversations?.sorted(by: {$0.message.timestamp.dateValue() > $1.message.timestamp.dateValue()}) // 排序最早的在前面
            self.tbvMain.reloadData()
        }
    }
    
    func fetchCurrentUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        UserManager.fetchUser(whitUid: uid) {[weak self] user in
            guard let self = self else { return }
            self.currentUser = user
            let ref = Storage.storage().reference().child(user.profileImageUrl)
            ref.getData(maxSize: 1 * 1024 * 1024) { data, error in
                if error != nil {
                    print("DEBUG: 取得 Storage 圖片失敗")
                } else {
                    let cacheImage = ImageCache()
                    cacheImage.image = UIImage(data: data!)
                    self.nsCache.setObject(cacheImage, forKey: "currentUserImage" as NSString)
                }
            }
        }
    }


    @IBAction func action_MyProfile(_ sender: Any) {
        let vc = MyProfileVC()
        vc.nsCache = self.nsCache
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func action_logout(_ sender: Any) {
        AuthManager.shared.logUserOut()
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func action_search(_ sender: Any) {
        let vc = SearchVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func dismissKeyBoard() {
        self.view.endEditing(true)
    }
    
}

extension ConversationVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if conversations != nil {
            hud.dismiss()
            return conversations!.count
            
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationsTbvCell", for: indexPath) as! ConversationsTbvCell
        
        cell.lbName.text = conversations?[indexPath.row].user.username
        cell.lbMessage.text = conversations?[indexPath.row].message.text
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        cell.lbTime.text = dateFormatter.string(from: conversations?[indexPath.row].message.timestamp.dateValue() ?? Date())
        
   
        if let cachedVersion = nsCache.object(forKey: "otherUserImage\(self.conversations![indexPath.row].user.uid)" as NSString) { // 如果cache 沒照片再去抓

            cell.vwImg.image = cachedVersion.image
        } else {
            cell.vwImg.image = nil
            let ref = Storage.storage().reference().child(conversations![indexPath.row].imgUrl)
            ref.getData(maxSize: 1 * 1024 * 1024) { data, error in
                if error != nil {
                    print("DEBUG: 取得 Storage 圖片失敗")
                } else {
                    
                    DispatchQueue.main.async {
                        cell.vwImg.image = UIImage(data: data!)
                        let cacheImage = ImageCache()
                        cacheImage.image = UIImage(data: data!)
                        if let cons = self.conversations {
                            self.nsCache.setObject(cacheImage, forKey: "otherUserImage\(cons[indexPath.row].user.uid)" as NSString)
                        }
                    }
                }
            }
        }

        cell.selectionStyle = .none
        if indexPath.row == conversations!.count - 1 {
            self.hud.dismiss()
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let cv = ChatMessageKitVC()
        cv.currentUser = currentUser
        cv.otherUser = conversations?[indexPath.row].user
        cv.nsCache = self.nsCache
        self.navigationController?.pushViewController(cv, animated: true)
    }
}


extension UISearchBar {
    var textField: UITextField? {
        if #available(iOS 13.0, *) {
            return self.searchTextField
        } else {
            for view in (self.subviews[0]).subviews {
                if let textField = view as? UITextField {
                    return textField
                }
            }
        }
        return nil
    }
}

