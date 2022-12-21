//
//  CALoginViewController.swift
//  ChatApp
//
//  Created by Furkan Erdoğan on 12.10.2022.
//

import Foundation
import UIKit
import Lottie
import Firebase

protocol AuthenticationDelegate: class {
    func authenticationComplete()
}

class CALoginViewController: UIViewController {
    
    //MARK: - Properties
    
    weak var delegate: AuthenticationDelegate?
    
    private var viewModel = CALoginViewModel()
    
    private var animationView: AnimationView?
    
    private lazy var loginLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Giriş Yap", comment: "")
        label.textColor = .label
        label.font = UIFont.systemFont(ofSize: 26, weight: .bold)
        
        return label
    }()
    
    private lazy var emailContainerView: UIView = {
        let image = UIImage(systemName: "envelope.fill")
        let view = Utilities().inputContainerView(withImage: image!, textField: emailTextField)
        return view
    }()
    
    private let emailTextField: UITextField = {
        let tf = Utilities().textField(withPlaceholder: NSLocalizedString("Mailiniz", comment: ""))
        tf.keyboardType = .emailAddress
        return tf
    }()
    
    private lazy var passwordContainerView: UIView = {
        let image = UIImage(systemName: "lock.fill")
        let view = Utilities().inputContainerView(withImage: image!, textField: passwordTextField)
        return view
    }()
    
    private let passwordTextField: UITextField = {
        let tf = Utilities().textField(withPlaceholder: NSLocalizedString("Şifre", comment: ""))
        tf.isSecureTextEntry = true
        return tf
    }()
    
    
    private lazy var registerButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("Giriş Yap", comment: ""), for: .normal)
        button.setTitleColor(.gray, for: .normal)
        button.backgroundColor = .red.withAlphaComponent(0.5)
        button.layer.cornerRadius = 20
        button.isEnabled = false
        
        button.addTarget(self, action: #selector(logInButtonPressed), for: .touchUpInside)

        
        return button
    }()
    
    private let dontHaveAccountButton: UIButton = {
        let button = Utilities().attributedButton(NSLocalizedString("Hesabın yok mu?", comment: ""), NSLocalizedString(" Kayıt Ol", comment: ""))
        button.addTarget(self, action: #selector(loginButtonAction), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        configureUI()
    }
    
    //MARK: - API
    
    
    //MARK: - Selector
    
    @objc func logInButtonPressed() {
        
        guard let email = emailTextField.text?.trimmingCharacters(in: .whitespaces),
              let password = passwordTextField.text
              else { return }
               
        showLoader(true, withText: NSLocalizedString("Giriş yapılıyor...", comment: ""))
               
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                self.showError(error.localizedDescription)
                
                self.showLoader(false)
                print("DEBUG: Error is logIn \(error.localizedDescription)")
                return
            }
            
            self.showLoader(false)
            self.delegate?.authenticationComplete()
            
        }
    }
    
    
    @objc func loginButtonAction() {
        let vc = CARegistrationViewController()
        vc.delegate = delegate
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func textDidChange(sender: UITextField) {
            if sender == emailTextField {
                viewModel.email = sender.text
            } else {
                viewModel.password = sender.text
            }
            
            checkFormStatus()
        }
    
    
    //MARK: - Helper
    
    func checkFormStatus() {
        if viewModel.formIsValid {
            registerButton.isEnabled = true
            registerButton.backgroundColor = .cyan
        } else {
            registerButton.isEnabled = false
            registerButton.backgroundColor = .red.withAlphaComponent(0.5)
        }
    }
    
    func configureUI() {
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.isHidden = true
        
        //Animation View
        
        animationView = .init(name: "116791-chat")
          
        animationView!.frame = view.bounds
        animationView?.backgroundColor = .clear
          
        animationView!.contentMode = .scaleAspectFit
          
        animationView!.loopMode = .loop
          
        animationView!.animationSpeed = 0.5
          
        view.addSubview(animationView!)
        animationView?.anchor(top: self.view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 0, width: 280, height: 280)
          
        animationView!.play()
        
        //LOGIN LABEL
        
        view.addSubview(loginLabel)
        loginLabel.centerX(inView: view, topAnchor: animationView?.bottomAnchor, paddingTop: 5)
        
        //TEXTFIELDS
        
        let tfStack = UIStackView(arrangedSubviews: [  emailContainerView, passwordContainerView])
        tfStack.axis = .vertical
        tfStack.spacing  = 15
        tfStack.distribution = .fillEqually
        
        view.addSubview(tfStack)
        tfStack.anchor(top: loginLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 40, paddingLeft: 30, paddingRight: 30)
        
        view.addSubview(registerButton)
        registerButton.anchor(top: tfStack.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 40, paddingLeft: 40,  paddingRight: 40, height: 50)
        
        //DON'T HAVE
        
        view.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.centerX(inView: view, topAnchor: view.safeAreaLayoutGuide.bottomAnchor, paddingTop: -30)
        
        emailTextField.addTarget(self, action: #selector(textDidChange(sender:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textDidChange(sender:)), for: .editingChanged)
    }
    
    
    
    
}
