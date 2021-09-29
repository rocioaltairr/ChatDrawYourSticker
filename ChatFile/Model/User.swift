//
//  User.swift
//  ChatGame
//
//  Created by 2008007NB01 on 2021/2/4.
//

import Foundation

struct User {
    let uid: String
    var profileImageUrl: String
    let profileImageStorage: String
    var username: String
    var fullname: String
    var email: String
    
    init(dictionary: [String: Any]) {
        self.uid = dictionary["uid"] as? String ?? ""
        self.profileImageUrl = dictionary["imageUrl"] as? String ?? ""
        self.profileImageStorage = dictionary["imageUrlStorage"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""
        self.fullname = dictionary["fullname"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        
    }
    
}
