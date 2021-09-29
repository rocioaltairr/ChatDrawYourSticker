//
//  MessagesVC.swift
//  ChatFile
//
//  Created by 2008007NB01 on 2021/8/13.
//

import UIKit

class MessagesVC: UIViewController{

    @IBOutlet weak var tbvMain: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tbvMain.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tbvMain.delegate = self
        tbvMain.dataSource = self
    }

}

extension MessagesVC: UITableViewDataSource, UITableViewDelegate {
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return 3
   }
   
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "Jam"
        cell.accessoryType = .disclosureIndicator
        return cell
   }
}
