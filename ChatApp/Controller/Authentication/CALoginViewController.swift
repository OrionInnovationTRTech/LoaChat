//
//  CALoginViewController.swift
//  ChatApp
//
//  Created by Furkan Erdoğan on 12.10.2022.
//

import Foundation
import UIKit
import Lottie

protocol AuthenticationDelegate: class {
    func authenticationComplete()
}

class CALoginViewController: UIViewController {
    
    //MARK: - Properties
    
    weak var delegate: AuthenticationDelegate?
    
    private var viewModel = CALoginViewModel()
    
    private lazy var animationView: AnimationView = {
        let av = AnimationView()
        av.frame = view.bounds
        av.backgroundColor = .clear
        av.contentMode = .scaleAspectFit
        av.loopMode = .loop
        av.animationSpeed = 0.5
        
        return av
    }()
    
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
    
    private lazy var forgotPassLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Şifreni mi unuttun?", comment: "")
        label.font = UIFont.systemFont(ofSize: 16, weight: .light)
        label.textColor = .label
        label.numberOfLines = 2
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(forgotPasswordLabelTapped))
                label.isUserInteractionEnabled = true
                label.addGestureRecognizer(tap)
        
        return label
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
               
        AuthService.logUserIn(withEmail: email, password: password) { result, error in
            
            if let error = error {
                
                self.showLoader(false)
                self.showMessage(withTitle: "Error", message: error.localizedDescription)
                
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
    
    @objc func forgotPasswordLabelTapped() {
        
        print("xxx")
        let controller = CAForgotPasswordViewController()
        controller.delegate = self
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func configureUI() {
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.isHidden = true
        
        //Animation View
        
        animationView = .init(name: "116791-chat")
          
        view.addSubview(animationView)
        animationView.anchor(top: self.view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 0, width: 280, height: 280)
          
        animationView.play()
        
        //LOGIN LABEL
        
        view.addSubview(loginLabel)
        loginLabel.centerX(inView: view, topAnchor: animationView.bottomAnchor, paddingTop: 5)
        
        //TEXTFIELDS
        
        let tfStack = UIStackView(arrangedSubviews: [  emailContainerView, passwordContainerView])
        tfStack.axis = .vertical
        tfStack.spacing  = 15
        tfStack.distribution = .fillEqually
        
        view.addSubview(tfStack)
        tfStack.anchor(top: loginLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 40, paddingLeft: 30, paddingRight: 30)
        
        view.addSubview(registerButton)
        registerButton.anchor(top: tfStack.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 40, paddingLeft: 40,  paddingRight: 40, height: 50)
        
        view.addSubview(forgotPassLabel)
        forgotPassLabel.centerX(inView: view, topAnchor: registerButton.bottomAnchor, paddingTop: 15)
        
        //DON'T HAVE
        
        view.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.centerX(inView: view, topAnchor: view.safeAreaLayoutGuide.bottomAnchor, paddingTop: -30)
        
        emailTextField.addTarget(self, action: #selector(textDidChange(sender:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textDidChange(sender:)), for: .editingChanged)
    }
    
    
    
    
}

extension CALoginViewController: ResetPasswordControllerDelegate {
    func controllerDidSendResetPasswordLink(_ controller: CAForgotPasswordViewController) {
        navigationController?.popViewController(animated: true)
        self.showMessage(withTitle: "Başarılı", message: "Email adresinize şifre yenileme linkini gönderdik")
    }
    
    
}
