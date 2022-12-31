//
//  User.swift
//  ChatApp
//
//  Created by Furkan Erdoğan on 24.10.2022.
//

import Foundation

struct User {
    let uid: String
    let profileImageUrl: String
    let username: String
    let fullname: String
    let email: String
    let fcmToken: String
    let isOnline: Bool
    
    init(dictionary: [String: Any]) {
        self.uid = dictionary["uid"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""
        self.fullname = dictionary["fullname"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.fcmToken = dictionary["fcmToken"] as? String ?? ""
        self.isOnline = dictionary["isOnline"] as? Bool ?? false
    }
}
