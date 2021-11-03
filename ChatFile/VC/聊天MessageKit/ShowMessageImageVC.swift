//
//  ShowMessageImageVC.swift
//  ChatFile
//
//  Created by 白白 on 2021/10/27.
//

import UIKit

class ShowMessageImageVC: UIViewController {
    @IBOutlet weak var img: UIImageView!
    
    var image:UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        img.image = image
    }
    
    @IBAction func action_close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
