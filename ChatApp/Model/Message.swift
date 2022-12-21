//
//  Message.swift
//  ChatApp
//
//  Created by Furkan Erdoğan on 26.10.2022.
//

import Firebase

struct Message {
    let text: String
    let toId: String
    let fromId: String
    var timeStamp: Timestamp!
    var user: User?
    var imageUrl: String

    
    let isFromCurrentUser: Bool
    
    var chatPartnerId: String {
        return isFromCurrentUser ? toId : fromId
    }
    
    init(dictionary: [String: Any]) {
        self.text = dictionary["text"] as? String ?? ""
        self.toId = dictionary["toId"] as? String ?? ""
        self.fromId = dictionary["fromId"] as? String ?? ""
        self.timeStamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: Date())
        self.imageUrl = (dictionary["imageUrl"] as? String ?? "")

        self.isFromCurrentUser = fromId == Auth.auth().currentUser?.uid
    }
}

struct Conversation {
    let user: User
    let message: Message
}
