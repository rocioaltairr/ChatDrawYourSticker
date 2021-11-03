//
//  SearchVC.swift
//  ChatFile
//
//  Created by 白白 on 2021/9/25.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseStorage

class SearchVC: UIViewController {
    @IBOutlet weak var searchBae: UISearchBar!
    @IBOutlet weak var tbv: UITableView!
    
    var otherUsers = [User]()
    var newUsers = [User]()
    var shouldShowSearchResults = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tbv.delegate = self
        tbv.dataSource = self
        tbv.register(UINib(nibName: "SearchTbvCell", bundle: nil), forCellReuseIdentifier: "SearchTbvCell")
        searchBae.delegate = self
        searchBae.searchTextField.delegate = self
        fetchUserData()
    }
    
    // MARK: - 取得使用者資料
    func fetchUserData() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        UserManager.shared.fetchUser(whitUid: uid) { user in
            self.fetchOtherUsers()
        }
    }
    
    // MARK: - 抓取其他使用者資料
    func fetchOtherUsers() {
        UserManager.shared.fetchOtherUsers { users in
            self.otherUsers = users
            self.tbv.reloadData()
        }
    }
    
    // MARK: - 關閉搜尋
    @IBAction func action_back(_ sender: Any) {
        dismiss_VC()
    }
    
    // MARK: - 關閉搜尋
    @IBAction func action_close(_ sender: Any) {
        dismiss_VC()
    }
    
    func dismiss_VC() {
        let transition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromBottom
        navigationController?.view.layer.add(transition, forKey: nil)
        _ = navigationController?.popViewController(animated: false)
    }
    
}

extension SearchVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if shouldShowSearchResults == true {
            return otherUsers.count
        } else {
            return otherUsers.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTbvCell", for: indexPath) as! SearchTbvCell
        cell.selectionStyle = .none
        
        cell.lbTitle.text = otherUsers[indexPath.row].username
        if let otherUserImageData = UserDefaults.standard.data(forKey: "otherUserImage\(self.otherUsers[indexPath.row].uid)") {
            cell.imgUser.image = UIImage(data: otherUserImageData)
        } else {
            let ref = Storage.storage().reference().child(otherUsers[indexPath.row].profileImageUrl)
            ref.getData(maxSize: 1 * 1024 * 1024) { data, error in
                if error != nil {
                    print("DEBUG: 取得 Storage 圖片失敗")
                } else {
                    if let imageData = data {
                        UserDefaultUtil.save(key: "otherUserImage\(self.otherUsers[indexPath.row].uid)", saveObj: imageData)
                        cell.imgUser.image = UIImage(data: imageData)
                    }
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cv = ChatMessageKitVC()
        cv.otherUser = otherUsers[indexPath.row]
        self.navigationController?.pushViewController(cv, animated: true)
    }
    
    /*
     func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
     let vwHeader = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 44))
     let lb = UILabel(frame: CGRect(x: 16, y: 12, width: 100, height: 20))
     
     lb.text = "全部"
     vwHeader.addSubview(lb)
     return vwHeader
     }
     
     func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
     return 45
     
     }*/
}

extension SearchVC: UISearchBarDelegate, UITextFieldDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            UserManager.shared.fetchOtherUsers { users in
                self.otherUsers = users
                self.tbv.reloadData()
            }
        } else {
            UserManager.shared.fetchOtherUsers { users in
                self.otherUsers = users
                self.reload(text: searchText)
            }
        }
    }
    
    func reload(text:String) {
        newUsers.removeAll()
        for otherUser in otherUsers {
            if otherUser.username.contains(text) {
                newUsers.append(otherUser)
            }
        }
        DispatchQueue.main.async {
            self.otherUsers = self.newUsers
            self.tbv.reloadData()
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        shouldShowSearchResults = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        shouldShowSearchResults = false
        tbv.reloadData()
    }
}
