//
//  ProfileViewModal.swift
//  ChatGame
//
//  Created by 2008007NB01 on 2021/2/10.
//

import Foundation

enum ProfileViewModal : Int, CaseIterable {
    
    case accountInfo
    case settings
    //case savedMessage
    
    var description: String {
        switch self {
        case .accountInfo:
            return "Posts"
        case .settings: return "Setting"
        //case .savedMessage: return "Saved Messages"
        }
    }
    
    var iconImageName: String {
        switch self {
        case .accountInfo:
            return "person.circle"
        case .settings: return "gear"
        //case .savedMessage: return "envelope"
        }
    }
}
