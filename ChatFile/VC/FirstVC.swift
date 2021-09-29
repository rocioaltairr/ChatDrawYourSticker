//
//  FirstVC.swift
//  ChatFile
//
//  Created by 2008007NB01 on 2021/8/12.
//

import UIKit

class FirstVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
            self.pushToLogin()
        })
        
    }
    
    func pushToLogin() {
        let loginVC = LoginVC()
        let navController = UINavigationController(rootViewController: loginVC)
        // 將navigationBar透明化
        navController.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navController.navigationBar.shadowImage = UIImage()
        navController.navigationBar.isTranslucent = true
        navController.view.backgroundColor = UIColor.clear
        navController.navigationBar.isHidden = true
        UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController = navController
        
        UIApplication.shared.windows.first?.rootViewController = navController
        UIApplication.shared.windows.first?.makeKeyAndVisible()
        
    }

}
