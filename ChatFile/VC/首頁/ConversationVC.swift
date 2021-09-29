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
    
    var mainUser : User?
    var users = [User]()
    var converstions = [Conversation]()
    let hud = JGProgressHUD(style: .dark)
    var nsCache = NSCache<NSString, UIImage>()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        hud.textLabel.text = "Loading"
        hud.show(in: self.view)
        searchBar.textField?.font = UIFont.systemFont(ofSize: 12)
        fetchUserID()
        
        self.tbvMain.allowsSelection = true
        self.tbvMain.delegate = self
        self.tbvMain.dataSource = self
        self.tbvMain.register(UINib(nibName: "ConversationsTbvCell", bundle: nil), forCellReuseIdentifier: "ConversationsTbvCell")
        
    }
    // 抓取使用者
    func fetchUserID() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        UserManager.fetchUser(whitUid: uid) { user in
            self.mainUser = user
            self.fetchOtherUsers()
            let ref = Storage.storage().reference().child(user.profileImageUrl)
            ref.getData(maxSize: 1 * 1024 * 1024) { data, error in
                if error != nil {
                    print("DEBUG: 取得 Storage 圖片失敗")
                } else {
                    let image = UIImage(data: data!)
                    self.nsCache.setObject(image!,
                                                   forKey: "currentUserImage")
                    //self.imgSender = image
                }
            }
        }
    }
    
    // MARK: - 抓取其他使用者資料
    func fetchOtherUsers() {
        UserManager.fetchOtherUsers { users in
            self.users = users
            //print("DEBUG: User is new message controller \(users)")
            self.tbvMain.reloadData()
        }
    }
//    // MARK: - 抓取新聊天訊息
//    func fetchNewMessages() {
//        UserManager.fetchNewMessage { converstions in
//            self.converstions = converstions
//            self.tbvMain.reloadData()
//        }
//    }
    
    @IBAction func action_MyProfile(_ sender: Any) {
        let vc = MyProfileVC()
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
        return users.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationsTbvCell", for: indexPath) as! ConversationsTbvCell
        cell.lbName.text = users[indexPath.row].username
        let ref = Storage.storage().reference().child(users[indexPath.row].profileImageUrl)
        ref.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if error != nil {
                print("DEBUG: 取得 Storage 圖片失敗")
            } else {
                
                DispatchQueue.main.async {
                    cell.vwImg.image = UIImage(data: data!)
                    self.nsCache.setObject(UIImage(data: data!)!,
                                                   forKey: "otherUserImage")
                    self.hud.dismiss()// << store result
                    
                }
            }
        }
        cell.selectionStyle = .none
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showChatCVC(forUser: users[indexPath.row])
//        let vc = ChatVC()
//        //vc.nsCache = self.nsCache
//        //vc.currentUser = mainUser
//        vc.otherUser = users[indexPath.row]
//        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func showChatCVC(forUser user:User) {
        let cv = ChatCVC(user: user)
        cv.nsCache = self.nsCache
        cv.currentUser = mainUser
        cv.otherUser = user
        
        self.navigationController?.pushViewController(cv, animated: true)
    }

}


extension UISearchBar {
    var textField: UITextField? {
        if #available(iOS 13.0, *) {
            return self.searchTextField
        } else {
            // Fallback on earlier versions
            for view in (self.subviews[0]).subviews {
                if let textField = view as? UITextField {
                    return textField
                }
            }
        }
        return nil
    }
}
