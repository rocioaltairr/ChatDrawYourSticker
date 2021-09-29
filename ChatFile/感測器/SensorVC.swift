//
//  HomeVC.swift
//  TaoyuanCropCultivation
//
//  Created by 忠義 on 2021/8/6.
//

import UIKit

class SensorVC: UIViewController {

    
    var sections: [Section] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
    }
    
    //MARK: - Func
    

    //MARK: - Action
    
    @IBAction func action_openMenu(_ sender: UIButton) {

    }
    
    @IBAction func action_back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

