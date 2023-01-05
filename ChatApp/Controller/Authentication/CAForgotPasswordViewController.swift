//
//  CAForgotPasswordViewController.swift
//  ChatApp
//
//  Created by Furkan Erdoğan on 27.12.2022.
//

import Foundation
import UIKit

protocol ResetPasswordControllerDelegate: class {
    func controllerDidSendResetPasswordLink(_ controller: CAForgotPasswordViewController)
}

class CAForgotPasswordViewController: UIViewController {
    
    //MARK: - Properties
    
    private var viewModel = ResetPasswordViewModel()
    weak var delegate: ResetPasswordControllerDelegate?
    
    private let passwordTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        label.numberOfLines = 3
        label.textAlignment = .center
        label.text = NSLocalizedString("Şifremi Unuttum", comment: "")
        
        
        return label
    }()
    
    private let infoTextLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.numberOfLines = .max
        label.textAlignment = .center
        label.text = NSLocalizedString("Şifrenizi yenilemek için lütfen e-posta adresinizi giriniz.", comment: "")
        
        
        return label
    }()
    
    
    private lazy var emailContainerView: UIView = {
        let image = UIImage(systemName: "envelope.fill")
        let view = Utilities().inputContainerView(withImage: image!, textField: emailTextField)
        return view
    }()
    
    private let emailTextField: UITextField = {
        let tf = Utilities().textField(withPlaceholder: "Mailiniz")
        tf.keyboardType = .emailAddress
        return tf
    }()
    
    private lazy var sendButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("Gönder", comment: ""), for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .cyan.withAlphaComponent(0.5)
        button.layer.cornerRadius = 20
        
        button.addTarget(self, action: #selector(sendButtonPressed), for: .touchUpInside)

        
        return button
    }()
    
    
    
    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        button.setDimensions(width: 40, height: 40)
        button.tintColor = .black
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
        
        return button
    }()
    
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        configureUI()
        view.backgroundColor = .systemBackground
        
    }
    
    //MARK: - API
    
    
    //MARK: - Selector
    
    @objc func sendButtonPressed() {
        
        print("xxxxx")
        
        guard let email = emailTextField.text?.lowercased() else {return}
        
        showLoader(true)
        AuthService.resetPassword(withEmail: email) { error in
            if let error = error {
                self.showMessage(withTitle: "Hata", message: error.localizedDescription)
                
                self.showLoader(false)
                
                return
            }
            
            self.delegate?.controllerDidSendResetPasswordLink(self)
         
        }
        
    }
    
    @objc func backButtonTapped() {
        
        navigationController?.popViewController(animated: true)
        
    }
    
    @objc func textDidChange(sender: UITextField) {
        if sender == emailTextField {
            viewModel.email = sender.text
        } else {
            
            viewModel.email = sender.text
            
        }
        
        updateForm()
    }
    
    
    
    //MARK: - Helper
    
    func configureUI() {
        
        
        emailTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        
        
        view.addSubview(backButton)
        backButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingTop: -4, paddingLeft: 20)
        
        view.addSubview(passwordTitleLabel)
        passwordTitleLabel.centerX(inView: view, topAnchor: view.safeAreaLayoutGuide.topAnchor)
        
        view.addSubview(infoTextLabel)
        infoTextLabel.anchor(top: passwordTitleLabel.bottomAnchor , left: view.leftAnchor, right: view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingRight: 20)
        
        
        
        view.addSubview(emailContainerView)
        emailContainerView.anchor(top: infoTextLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 40, paddingLeft: 30, paddingRight: 30)
        
        view.addSubview(sendButton)
        sendButton.anchor(top: emailContainerView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 40, paddingLeft: 40,  paddingRight: 40, height: 50)
        
        
    }
    

}

extension CAForgotPasswordViewController: FormViewModel {
    func updateForm() {
        sendButton.backgroundColor = viewModel.buttonBackgroundColor
        sendButton.isEnabled = viewModel.formIsValid
    }
    
    
    
}
