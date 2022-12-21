//
//  CAConversationViewModel.swift
//  ChatApp
//
//  Created by Furkan Erdoğan on 31.10.2022.
//

import Foundation

struct CAConversationViewModel {
    
    private let conversation: Conversation
    
    var profileImageUrl: URL? {
        return URL(string: conversation.user.profileImageUrl)
    }
    
    var messageText: String {
        if conversation.message.imageUrl.isEmpty == false {
            return conversation.message.isFromCurrentUser ? NSLocalizedString("Bir fotoğraf gönderdiniz.", comment: "") : NSLocalizedString("Bir fotoğraf gönderdi.", comment: "")
        } else {
            return conversation.message.text
        }
        
    }
    
    var timeStamp: String {
        let date = conversation.message.timeStamp.dateValue()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: date)
    }
    
    init(conversation: Conversation) {
        self.conversation = conversation
    }
}
