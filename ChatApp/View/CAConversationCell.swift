//
//  CAConversationCell.swift
//  ChatApp
//
//  Created by Furkan Erdoğan on 31.10.2022.
//

import UIKit
import SDWebImage

class CAConversationCell: UITableViewCell {
    
    //MARK: - Properties
    
    var conversation: Conversation? {
        didSet {
            configure()
        }
    }
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .clear
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        
        return iv
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.text = "Your UserName"
        label.textColor = .label
        return label
    }()
    
    private let messageTextLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .label
        label.text = "Your message"
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .label
        label.text = "12.00"
        return label
    }()
    
    //MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        profileImageView.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 12)
        profileImageView.setDimensions(width: 50, height: 50)
        profileImageView.layer.cornerRadius = 50 / 2
        profileImageView.centerY(inView: self)
        
        let stack = UIStackView(arrangedSubviews: [usernameLabel, messageTextLabel])
        stack.axis = .vertical
        stack.spacing = 2
        
        addSubview(stack)
        stack.centerY(inView: profileImageView)
        stack.anchor(left: profileImageView.rightAnchor, right: rightAnchor ,paddingLeft: 12, paddingRight: 15)
        
        addSubview(timeLabel)
        timeLabel.anchor(top: topAnchor, right: rightAnchor, paddingTop: 20, paddingRight: 12)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helpers
    
    private func configure() {
        guard
            let user = conversation?.user,
            let message = conversation?.message
        else { return }
        
        guard let conversation = conversation else {
            return
        }

        
        let viewModel = CAConversationViewModel(conversation: conversation)

        messageTextLabel.text = message.text
        usernameLabel.text = user.username
        timeLabel.text = viewModel.timeStamp
        profileImageView.sd_setImage(with: viewModel.profileImageUrl)
    }
}
