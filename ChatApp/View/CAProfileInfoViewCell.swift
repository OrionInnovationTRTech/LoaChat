//
//  CAProfileInfoViewCell.swift
//  ChatApp
//
//  Created by Furkan Erdoğan on 31.10.2022.
//

import UIKit

final class CAProfileInfoViewCell: UITableViewCell {
    static let identifier = "SwitchTableViewCell"
    
    private let profileContainer : UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 25
        view.layer.masksToBounds = true
        return view
    }()
    
    private let profileImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .white
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 25
        return imageView
    }()
    
    private let nameLabel : UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        return label
    }()
    
    private let usernameLabel : UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        return label
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(nameLabel)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(profileContainer)
        profileContainer.addSubview(profileImageView)
        contentView.clipsToBounds = true
        accessoryType = .disclosureIndicator
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let size : CGFloat = 50
        profileContainer.frame = CGRect(x: 15, y: 6, width: size, height: size)
        
        let imageSize : CGFloat = 50
        profileImageView.frame = CGRect(x: (size - imageSize)/2, y: (size - imageSize)/2, width: imageSize, height: imageSize)
        
        
        nameLabel.frame = CGRect(x: 25 + profileContainer.frame.size.width,
                             y: -10,
                             width: contentView.frame.size.width - 20 - profileContainer.frame.size.width,
                             height: contentView.frame.size.height)
        
        usernameLabel.frame = CGRect(x: 25 + profileContainer.frame.size.width,
                             y: 10,
                             width: contentView.frame.size.width - 20 - profileContainer.frame.size.width,
                             height: contentView.frame.size.height)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.image = nil
        nameLabel.text = nil
        profileContainer.backgroundColor = nil
    }
    
    public func configure(with model : SettingsSwitchOption) {
        nameLabel.text = model.name
        usernameLabel.text = model.username
        profileImageView.image = model.image
        profileContainer.backgroundColor = model.iconBackgroundColor
    }

}
