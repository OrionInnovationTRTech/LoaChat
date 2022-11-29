//
//  Utilities.swift
//  ChatApp
//
//  Created by Furkan Erdoğan on 12.10.2022.
//

import Foundation
import UIKit

class Utilities {
    
    func inputContainerView(withImage image: UIImage, textField: UITextField) -> UIView {
        let view = UIView()
        let iv = UIImageView()
        view.layer.borderWidth = 0.75
        view.layer.borderColor = UIColor(named: "mainColor")?.cgColor
        view.clipsToBounds = true
        view.layer.cornerRadius = 8
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        iv.image = image
        iv.tintColor = UIColor(named: "mainColor")
        
        view.addSubview(textField)
        textField.layer.cornerRadius = 20
        
        textField.backgroundColor = .clear
        textField.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor,
                         right: view.rightAnchor, paddingLeft: 8, height: 50 )
        
        
        textField.addSubview(iv)
        textField.setLeftPaddingPoints(40)
        iv.anchor(left: textField.leftAnchor, bottom: textField.bottomAnchor,
                  paddingLeft: 8, paddingBottom: 15)
        iv.setDimensions(width: 21, height: 21)
        
        
        return view
    }
    
    func textField(withPlaceholder placeholder: String) -> UITextField {
        let tf = UITextField()
        
        tf.textColor = UIColor(named: "mainColor")
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "placeholderColor")!])
        return tf
    }
    
    func attributedButton(_ firstPart: String, _ secondPart: String) -> UIButton {
        let button = UIButton(type: .system)
        button.tintColor = .label
        
        let attributedTitle = NSMutableAttributedString(string: firstPart, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.label])
        
        attributedTitle.append(NSAttributedString(string: secondPart, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.red]))
        
        button.setAttributedTitle(attributedTitle, for: .normal)
        
        return button
    }
}

extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
    
    static let chatGunmetal = UIColor(red: 0.07, green: 0.31, blue: 0.36, alpha: 1.00)
    static let chatVridianGreen = UIColor(red: 0.07, green: 0.62, blue: 0.64, alpha: 1.00)
    static let chatButtonBG = UIColor(red: 0.07, green: 0.31, blue: 0.36, alpha: 1.00)
    
}
