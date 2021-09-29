//
//  AppDelegate.swift
//  ChatFile
//
//  Created by 2008007NB01 on 2021/8/12.
//

import UIKit
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    // iOS12 & before work
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        if let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.path {
            print(documentsPath)   // "var/folder/.../documents\n" copy the full path
        }
        
        let rootVC = FirstVC()
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = rootVC
       // window?.makeKeyAndVisible()
        
        return true
    }
    
}

