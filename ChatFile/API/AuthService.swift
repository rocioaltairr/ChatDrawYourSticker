//
//  AuthService.swift
//  ChatGame
//
//  Created by 2008007NB01 on 2021/2/3.
//

import Firebase

// API file to manage datebase
struct AuthService {
    static let shared = AuthService() // make usure we use the same instance and not to create it multiple time.
    func logUserIn(withEmail email:String, password:String,completion: AuthDataResultCallback?) {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                //print("DEBUG: Faild to log in with error. \(error.localizedDescription)")
                return
            }
            //self.dismiss(animated: true, completion: nil)
            //print("DEBUG: User login successful.")
        }
    }
    
    func logUserOut() {
        do {
            try Auth.auth().signOut()
            presentLoginScreen()
        } catch {
            //print("DEBUG: Error signing out..")
        }
    }
    
    
    func presentLoginScreen() {
        DispatchQueue.main.async {
            let vc = LoginVC()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            nav.present(nav, animated: true) {
                print("presentLoginScreen()")
            }
        }
    }
}
