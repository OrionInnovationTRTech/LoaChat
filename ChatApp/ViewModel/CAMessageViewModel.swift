//
//  CAMessageViewModel.swift
//  ChatApp
//
//  Created by Furkan Erdoğan on 27.10.2022.
//

import UIKit

struct CAMessageViewModel {
    
    private let message: Message
    
    var messageBackgroundColor: UIColor {
        return message.isFromCurrentUser ? .chatGunmetal : .lightGray
    }
    
    var messageTextColor: UIColor {
        return message.isFromCurrentUser ? .white : .white
    }
    
    var rightAnchorActive: Bool {
        return message.isFromCurrentUser
    }
    
    var leftAnchorActive: Bool {
        return !message.isFromCurrentUser
    }
    
    var shouldHideProfileImage: Bool {
        return message.isFromCurrentUser
    }
    var profileImageURL: URL? {
        guard let user = message.user else { return nil }
        return URL(string: user.profileImageUrl)
    }
    var messageImage: URL? {
        guard let user = message.user else { return nil }
        return URL(string: message.imageUrl)
    }
    init(message: Message) {
        self.message = message
    }
    
}
