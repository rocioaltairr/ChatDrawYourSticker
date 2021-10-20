//
//  SearchVC.swift
//  ChatFile
//
//  Created by 2008007NB01 on 2021/9/25.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseStorage


class SearchVC: UIViewController {
    
    @IBOutlet weak var tbv: UITableView!
    var currentUser : User?
    var otherUsers = [User]()
    var nsCache = NSCache<NSString, ImageCache>()
    var selectedIndex:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tbv.delegate = self
        tbv.dataSource = self
        tbv.register(UINib(nibName: "SearchTbvCell", bundle: nil), forCellReuseIdentifier: "SearchTbvCell")
        fetchUserID()
    }
    
    // 抓取使用者
    func fetchUserID() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        UserManager.fetchUser(whitUid: uid) { user in
            self.currentUser = user
            self.fetchOtherUsers()
            let ref = Storage.storage().reference().child(user.profileImageUrl)
            ref.getData(maxSize: 1 * 1024 * 1024) { data, error in
                if error != nil {
                    print("DEBUG: 取得 Storage 圖片失敗")
                } else {
                    //let image = UIImage(data: data!)
                    //self.nsCache.setObject(image!,
                    // forKey: "currentUserImage")
                    
                    let cacheImage = ImageCache()
                    cacheImage.image = UIImage(data: data!)
                    self.nsCache.setObject(cacheImage, forKey: "currentUserImage" as NSString)
                    
                    //self.imgSender = image
                }
            }
        }
    }
    // MARK: - 抓取其他使用者資料
    func fetchOtherUsers() {
        UserManager.fetchOtherUsers { users in
            self.otherUsers = users
            //print("DEBUG: User is new message controller \(users)")
            self.tbv.reloadData()
        }
    }
    
    @IBAction func action_back(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func action_close(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    
}

extension SearchVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return otherUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTbvCell", for: indexPath) as! SearchTbvCell
        cell.selectionStyle = .none
        cell.lbTitle.text = otherUsers[indexPath.row].username
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let vwHeader = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 44))
        let lb = UILabel(frame: CGRect(x: 16, y: 12, width: 100, height: 20))
        
        lb.text = "最近搜尋"
        vwHeader.addSubview(lb)
        return vwHeader
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let cv = ChatMessageKitVC()
        selectedIndex = indexPath.row
        cv.currentUser = currentUser
        cv.otherUser = otherUsers[indexPath.row]
        cv.nsCache = self.nsCache
        self.navigationController?.pushViewController(cv, animated: true)
    }
}

