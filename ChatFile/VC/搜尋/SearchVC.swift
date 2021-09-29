//
//  SearchVC.swift
//  ChatFile
//
//  Created by 2008007NB01 on 2021/9/25.
//

import UIKit

class SearchVC: UIViewController {
    

    @IBOutlet weak var tbv: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tbv.delegate = self
        tbv.dataSource = self
        tbv.register(UINib(nibName: "SearchTbvCell", bundle: nil), forCellReuseIdentifier: "SearchTbvCell")
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
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTbvCell", for: indexPath) as! SearchTbvCell
        cell.selectionStyle = .none
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
}
