//
//  CustomInputAccessoryView.swift
//  ChatApp
//
//  Created by Furkan Erdoğan on 27.10.2022.
//



import UIKit
import Firebase

protocol CustomInputAccessoryViewDelegate: class {
    func inputView(_ inputView: CustomInputAccessoryView, wantsToSend message: String)
    func inputImageView( wantsToSendImage image: UIImage)
}

class CustomInputAccessoryView: UIView {
    
    // MARK: - Properties
    weak var delegate: CustomInputAccessoryViewDelegate?
    
    private lazy var messageInputTextView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.isScrollEnabled = false
        return tv
    }()
    
    private let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("Gönder", comment: ""), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.chatButtonBG, for: .normal)
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleSendMessage), for: .touchUpInside)
        return button
    }()
    
    
    private lazy var sendPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "camera"), for: .normal)
        button.tintColor = .chatButtonBG
        button.setTitleColor(.systemPurple, for: .normal)
        button.addTarget(self, action: #selector(handleUploadTap), for: .touchUpInside)
        return button
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Mesaj yaz...", comment: "")
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .lightGray
        return label
    }()
    
    // MARK: - LifeCycle

    override init(frame: CGRect) {
        super.init(frame: frame)

        autoresizingMask = .flexibleHeight
        backgroundColor = .systemBackground
        
        layer.shadowOpacity = 0.25
        layer.shadowRadius = 10
        layer.shadowOffset = .init(width: 0, height: -8)
        layer.shadowColor = UIColor.lightGray.cgColor
        
        
        
        addSubview(sendButton)
        sendButton.anchor(top: topAnchor,
                          right: rightAnchor,
                          paddingTop: 4,
                          paddingRight: 8,
                          width: 60,
                          height: 50)
        
        addSubview(sendPhotoButton)
        sendPhotoButton.anchor(top: topAnchor,
                          left: leftAnchor,
                          paddingTop: 4,
                          paddingLeft: 8,
                          width: 50,
                          height: 50)
        
        addSubview(messageInputTextView)
        messageInputTextView.anchor(top: topAnchor,
                                    left: sendPhotoButton.rightAnchor,
                                    bottom: safeAreaLayoutGuide.bottomAnchor,
                                    right: sendButton.leftAnchor,
                                    paddingTop: 12,
                                    paddingLeft: 3,
                                    paddingBottom: 8,
                                    paddingRight: 8)
        
        addSubview(placeholderLabel)
        placeholderLabel.anchor(left: messageInputTextView.leftAnchor, paddingLeft: 4)
        placeholderLabel.centerY(inView: messageInputTextView)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleTextInputChange),
                                               name: UITextView.textDidChangeNotification,
                                               object: nil)
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return .zero
    }
    
    // MARK: - Selectors
    
    
    @objc func handleSendMessage() {
        guard let message = messageInputTextView.text else { return }
        delegate?.inputView(self, wantsToSend: message)
    }
    
    @objc func handleUploadTap() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        self.window?.rootViewController?.present(imagePickerController, animated: true)
    }
    
    
    @objc func handleTextInputChange() {
        
        placeholderLabel.isHidden = !self.messageInputTextView.text.isEmpty
        sendButton.isEnabled = !self.messageInputTextView.text.isEmpty

        
    }

    //MARK: - Helpers

    func clearMessageText() {
        messageInputTextView.text = nil
        placeholderLabel.isHidden = false
        sendButton.isEnabled = false
    }
}

extension CustomInputAccessoryView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage") ] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerOriginalImage") ] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            delegate?.inputImageView(wantsToSendImage: selectedImage)
        }
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
