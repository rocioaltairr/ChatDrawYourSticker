//
//  ConversationVC.swift
//  ChatFile
//
//  Created by 白白 on 2021/8/12.
//

import UIKit

class ConversationVC: UIViewController {
    @IBOutlet weak var tbvMain: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    lazy var viewModel: ConversationViewModel = {
        return ConversationViewModel()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LodingActivityIndicatorUtil.shared.showLoader(view: self.view)
        self.searchBar.textField?.font = UIFont.systemFont(ofSize: 15)
        self.tbvMain.separatorStyle = .none
        self.tbvMain.delegate = self
        self.tbvMain.dataSource = self
        self.tbvMain.register(UINib(nibName: "ConversationsTbvCell", bundle: nil), forCellReuseIdentifier: "ConversationsTbvCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.viewModel.fetchAllConversation()
        self.viewModel.reloadTableViewClosure = { [weak self] () in
            DispatchQueue.main.async {
                LodingActivityIndicatorUtil.shared.hideLoader()
                self?.tbvMain.reloadData()
            }
        }
    }
    
    // MARK: - 搜尋othersUser（使用者們）
    @IBAction func action_MyProfile(_ sender: Any) {
        let vc = MyProfileVC()
        vc.userType = .currentUser
        let transition = CATransition()
            transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.moveIn
        transition.subtype = CATransitionSubtype.fromTop
            navigationController?.view.layer.add(transition, forKey: nil)
            navigationController?.pushViewController(vc, animated: false)
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
}

extension ConversationVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.numberOfCells
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationsTbvCell", for: indexPath) as! ConversationsTbvCell
        let cellViewModel = viewModel.getCellViewModel(at: indexPath)
        cell.conversationTbvCellViewModel = cellViewModel
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cv = ChatMessageKitVC()
        LodingActivityIndicatorUtil.shared.showLoader(view: self.view)
        cv.otherUser = viewModel.getCellUser(at: indexPath)
        self.navigationController?.pushViewController(cv, animated: true)
    }
}


