//
//  CARegistrationViewController.swift
//  ChatApp
//
//  Created by Furkan Erdoğan on 12.10.2022.
//

import Foundation
import UIKit
import Lottie

class CARegistrationViewController: UIViewController {
    
    //MARK: - Properties
    
    private var viewModel = CARegistrationViewModel()
    
    private var profileImage: UIImage?
    
    weak var delegate: AuthenticationDelegate?
    
    private lazy var scroolView: UIScrollView = {
        let sc = UIScrollView(frame: .zero)
        sc.backgroundColor = .systemBackground
        sc.contentSize.width = self.view.frame.width
        sc.frame = self.view.bounds
        sc.autoresizingMask = .flexibleHeight
        sc.showsHorizontalScrollIndicator = true
        sc.bounces = true
        
        return sc
    }()
    
    private lazy var scrollSubView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        
        
        return view
        
        
    }()
    
    private var animationView: AnimationView?
    
    
    
    private let registerLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = UIFont.systemFont(ofSize: 26, weight: .bold)
        label.numberOfLines = 3
        label.textAlignment = .center
        label.text = "Kayıt Ol"
        
        
        return label
    }()
    
    private lazy var addPhotoButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "profile"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(handleSelectPhoto), for: .touchUpInside)
        button.clipsToBounds = true
        
        return button
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
    
    private lazy var fullNameContainerView: UIView = {
        let image = UIImage(systemName: "person.fill")
        let view = Utilities().inputContainerView(withImage: image!, textField: fullNameTextField)
        return view
    }()
    
    private let fullNameTextField: UITextField = {
        let tf = Utilities().textField(withPlaceholder: NSLocalizedString("Adınız Soyadınız", comment: ""))
        return tf
    }()
    
    private lazy var userNameContainerView: UIView = {
        let image = UIImage(systemName: "person.fill")
        let view = Utilities().inputContainerView(withImage: image!, textField: userNameTextField)
        return view
    }()
    
    private let userNameTextField: UITextField = {
        let tf = Utilities().textField(withPlaceholder: NSLocalizedString("Kullanıcı adınız", comment: ""))
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
        button.setTitle(NSLocalizedString("Kayıt Ol", comment: ""), for: .normal)
        button.setTitleColor(.gray, for: .normal)
        button.backgroundColor = .red.withAlphaComponent(0.5)
        button.layer.cornerRadius = 20
        
        button.addTarget(self, action: #selector(registerButtonPressed), for: .touchUpInside)

        
        return button
    }()
    
    private let dontHaveAccountButton: UIButton = {
        let button = Utilities().attributedButton(NSLocalizedString("Hesabın var mı?", comment: ""), NSLocalizedString(" Giriş Yap", comment: ""))
        button.addTarget(self, action: #selector(loginButtonAction), for: .touchUpInside)
        return button
    }()
    
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        configureUI()
        configureNotificationObservers()
    }
    
    //MARK: - API
    
    
    //MARK: - Selector
    
    @objc func registerButtonPressed() {
        guard
            let email = emailTextField.text?.trimmingCharacters(in: .whitespaces).lowercased(),
            let fullname = fullNameTextField.text,
            let username = userNameTextField.text?.trimmingCharacters(in: .whitespaces).lowercased(),
            let password = passwordTextField.text,
            let profileImage = profileImage
            else { return }
        
        guard let fcmToken = UserDefaults.standard.string(forKey: "fcm_token") else { return  }
        
        print("DEBUG: FCM Token \(fcmToken)")
        
        let credentials = RegistrationCredentials(email: email,
                                                 password: password,
                                                 fullname: fullname,
                                                 username: username,
                                                  profileImage: profileImage,
                                                  fcmToken: fcmToken,
                                                  isOnline: true)
        
        showLoader(true, withText: NSLocalizedString("Kayıt Olunuyor...", comment: ""))
            
        AuthService.shared.createUser(credentials: credentials) { (error) in
            if let error = error {
                self.showLoader(false)
                self.showError(error.localizedDescription)
                
                print("Debug: error is: \(error.localizedDescription)")
                return
            }
            
            self.showLoader(false)
            self.delegate?.authenticationComplete()
            
            
        }
    }
    
    
    @objc func loginButtonAction() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func handleSelectPhoto() {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            present(imagePickerController, animated: true)
        }
    
    @objc func textDidChange(sender: UITextField) {
            if sender == emailTextField {
                viewModel.email = sender.text
            } else if sender == fullNameTextField {
                viewModel.fullName = sender.text
            } else if sender == userNameTextField {
                viewModel.userName = sender.text
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
        
        view.addSubview(scroolView)
        scroolView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0)
        
        scroolView.addSubview(scrollSubView)
        scrollSubView.anchor(top: scroolView.topAnchor, left: scroolView.leftAnchor, bottom: scroolView.bottomAnchor, width: view.frame.size.width)
        
        
        
        //LOGIN LABEL
        
        scrollSubView.addSubview(registerLabel)
        registerLabel.centerX(inView: view, topAnchor: scrollSubView.topAnchor, paddingTop: 5)
        
        scrollSubView.addSubview(addPhotoButton)
        addPhotoButton.centerX(inView: view, topAnchor: registerLabel.bottomAnchor, paddingTop: 20)
        addPhotoButton.setDimensions(width: 128, height: 128)
        
        
        //TEXTFIELDS
        
        let tfStack = UIStackView(arrangedSubviews: [ emailContainerView, fullNameContainerView, userNameContainerView, passwordContainerView])
        tfStack.axis = .vertical
        tfStack.spacing  = 15
        tfStack.distribution = .fillEqually
        
        scrollSubView.addSubview(tfStack)
        tfStack.anchor(top: addPhotoButton.bottomAnchor, left: scrollSubView.leftAnchor, right: scrollSubView.rightAnchor, paddingTop: 40, paddingLeft: 30, paddingRight: 30)
        
        scrollSubView.addSubview(registerButton)
        registerButton.anchor(top: tfStack.bottomAnchor, left: scrollSubView.leftAnchor, right: scrollSubView.rightAnchor, paddingTop: 40, paddingLeft: 40,  paddingRight: 40, height: 50)
        
        //DON'T HAVE
        
        scrollSubView.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.anchor(top: registerButton.bottomAnchor, left: scrollSubView.leftAnchor,
                                     bottom: scrollSubView.safeAreaLayoutGuide.bottomAnchor,
                                     right: scrollSubView.rightAnchor, paddingTop: 20, paddingLeft: 40, paddingBottom: 20, paddingRight: 40)
        
    }
    
    private func configureNotificationObservers() {
            emailTextField.addTarget(self, action: #selector(textDidChange(sender:)), for: .editingChanged)
            fullNameTextField.addTarget(self, action: #selector(textDidChange(sender:)), for: .editingChanged)
            userNameTextField.addTarget(self, action: #selector(textDidChange(sender:)), for: .editingChanged)
            passwordTextField.addTarget(self, action: #selector(textDidChange(sender:)), for: .editingChanged)
        }
    
    
    
    
    
}

//MARK: - UIImagePickerControllerDelegate
extension CARegistrationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = info[.originalImage] as? UIImage
        self.profileImage = image
        
        addPhotoButton.layer.cornerRadius = 128 / 2
        addPhotoButton.layer.masksToBounds = true
        addPhotoButton.imageView?.contentMode = .scaleAspectFill
        addPhotoButton.imageView?.clipsToBounds = true
        addPhotoButton.layer.borderColor = UIColor.white.cgColor
        addPhotoButton.layer.borderWidth = 3
        
        self.addPhotoButton.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
        
        dismiss(animated: true)
    }
}


