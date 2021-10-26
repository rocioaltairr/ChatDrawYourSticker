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
class ConversationVC: UIViewController {
    @IBOutlet weak var tbvMain: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var currentUser : User?
    var otherUsers:[User]? = []

    var nsCache = NSCache<NSString, ImageCache>()
    private var messages = [Message]()
    var conversations:[Conversation]?
    var conversation:Conversation?
    
    var firstTime:Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LoadingUtil.showWithTitle(title: "請稍候")
        searchBar.textField?.font = UIFont.systemFont(ofSize: 15)
        tbvMain.separatorStyle = .none
       // self.tbvMain.allowsSelection = true
        self.tbvMain.delegate = self
        self.tbvMain.dataSource = self
        self.tbvMain.register(UINib(nibName: "ConversationsTbvCell", bundle: nil), forCellReuseIdentifier: "ConversationsTbvCell")
        fetchCurrentUser()
        //fetchUserAndLastMessage()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchAllConversation()
    }
    
    
    func fetchAllConversation() {
        UserManager.fetchConversations {[weak self] con in
            guard let self = self else { return }
            if con.count == 0 {
                LoadingUtil.hideView()
                return
            }
            if self.firstTime == true {
                self.conversations = con
                self.firstTime = false
            } else {
                if con.count == 1 {

                    // 如果是新的加入到conversation
                    var isNewCon  = true
                    for i in 0..<self.conversations!.count {
                        if self.conversations?[i].message.isFromCurrentUser == false {
                            if self.conversations?[i].message.toID == con[0].message.toID {
                                isNewCon = false
                            }
                        } else {
                            if self.conversations?[i].message.fromID == con[0].message.fromID {
                                isNewCon = false
                            }
                        }
                    }
                    
                    if isNewCon == true {
                        self.conversations?.append(con[0])
                    } else {
                        for i in 0..<self.conversations!.count {

                            if self.conversations?[i].message.isFromCurrentUser == false { // 如果是從我這邊
                                if self.conversations?[i].message.toID == con[0].message.toID {
                                    self.conversations?.remove(at: i)
                                    self.conversations?.insert(con[0], at: 0)
                                    self.conversations = self.conversations?.sorted(by: {$0.message.timestamp.dateValue() > $1.message.timestamp.dateValue()}) // 排序最早的在前面
                                    self.tbvMain.reloadData()
                                    return
                                }

                            } else {
                                if self.conversations?[i].message.fromID == con[0].message.fromID {
                                    self.conversations?.remove(at: i)
                                    self.conversations?.insert(con[0], at: 0)
                                    self.conversations = self.conversations?.sorted(by: {$0.message.timestamp.dateValue() > $1.message.timestamp.dateValue()}) // 排序最早的在前面
                                    self.tbvMain.reloadData()
                                    return
                                }
                            }
                        }
                    }

                } else {
                    self.conversations = con
                }
            }
            
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
                    UserDefaultUtil.save(key: "currentUserImage", saveObj: data!)
                }
            }
        }
    }


    @IBAction func action_MyProfile(_ sender: Any) {
        let vc = MyProfileVC()

        vc.nsCache = self.nsCache
        let transition = CATransition()
            transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.moveIn
        transition.subtype = CATransitionSubtype.fromTop
            navigationController?.view.layer.add(transition, forKey: nil)
            navigationController?.pushViewController(vc, animated: false)
    }
    
    // MARK: - 登出
    @IBAction func action_logout(_ sender: Any) {
       // AlertUtil.showMessage(message: "確認登出？")
        AlertUtil.strBtnCancel = "取消"
        AlertUtil.showMessage(message: "確認登出？") { alert in
            AuthManager.shared.logUserOut()
            self.navigationController?.popViewController(animated: true)
        } cancelHandler: { alert in
            print("")
        }
    }
    
    // MARK: - 搜尋othersUser（使用者們）
    @IBAction func action_search(_ sender: Any) {
        
        let vc = SearchVC()
        let transition = CATransition()
            transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.moveIn
        transition.subtype = CATransitionSubtype.fromTop
            navigationController?.view.layer.add(transition, forKey: nil)
            navigationController?.pushViewController(vc, animated: false)
    }
    
    @objc func dismissKeyBoard() {
        self.view.endEditing(true)
    }
    
}

extension ConversationVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if conversations != nil {
            LoadingUtil.hideView()
            return conversations!.count
            
        } else {
            return 0
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationsTbvCell", for: indexPath) as! ConversationsTbvCell
        
        cell.lbName.text = conversations?[indexPath.row].user.username
        cell.lbMessage.text = conversations?[indexPath.row].message.text
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        cell.selectionStyle = .none
        cell.lbTime.text = dateFormatter.string(from: conversations?[indexPath.row].message.timestamp.dateValue() ?? Date())
  
        if let cons = self.conversations {
            if let otherImageData = UserDefaults.standard.data(forKey: "otherUserImage\(cons[indexPath.row].user.uid)") {
                    cell.vwImg.image = UIImage(data: otherImageData)
            } else {
                let ref = Storage.storage().reference().child(conversations![indexPath.row].imgUrl)
                ref.getData(maxSize: 1 * 1024 * 1024) { data, error in
                    if error != nil {
                        print("DEBUG: 取得 Storage 圖片失敗")
                    } else {
                        UserDefaultUtil.save(key: "otherUserImage\(cons[indexPath.row].user.uid)", saveObj: data!)
                    }
                }
            }
            if indexPath.row == cons.count - 1 {
                LoadingUtil.hideView()
            }
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cv = ChatMessageKitVC()
        cv.currentUser = currentUser
        cv.otherUser = conversations?[indexPath.row].user
        //cv.nsCache = self.nsCache
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

