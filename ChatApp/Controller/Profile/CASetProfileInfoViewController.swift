//
//  CASetProfileInfoViewController.swift
//  ChatApp
//
//  Created by Furkan Erdoğan on 3.11.2022.
//



import UIKit
import SDWebImage
import FirebaseFirestore
import Firebase
import AVFoundation

var isDeleteAcount = false

protocol DeleteAccountDelegate: class {
    func handleDelete()
}

class CASetProfileInfoViewController: UIViewController {

    //MARK: - Properties
    
    private let imagePicker = UIImagePickerController()
    private var profileImage: UIImage?
    
    var selectedImage: URL?
    var selectedName: String?
    var selectedSurname: String?
    var selectedBirthday: String?
    
    weak var delegate: DeleteAccountDelegate?
    
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
    
    
    
   
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.setDimensions(width: 150, height: 150)
        iv.sd_setImage(with: URL(string: selectedProfileImageUrl!), completed: nil)
        iv.tintColor = .lightGray
        iv.layer.cornerRadius = 75
        iv.layer.masksToBounds = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleAddProfilePhoto))
            iv.isUserInteractionEnabled = true
            iv.addGestureRecognizer(tapGestureRecognizer)
        
        
        
        return iv
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.numberOfLines = 3
        label.textAlignment = .center
        label.text = selectedName
        
        
        return label
    }()
    
    private lazy var nameContainerView: UIView = {
        let image = UIImage(systemName: "person.fill")
        let view = Utilities().inputContainerView(withImage: image!, textField: nameTextField)
        return view
    }()
    
    private lazy var nameTextField: UITextField = {
        let tf = Utilities().textField(withPlaceholder: NSLocalizedString("Adınız Soyadınız", comment: ""))
        tf.text = selectedName
        return tf
    }()
    
    private lazy var surnameameContainerView: UIView = {
        let image = UIImage(systemName: "person.fill")
        let view = Utilities().inputContainerView(withImage: image!, textField: surnameTextField)
        return view
    }()
    
    private lazy var surnameTextField: UITextField = {
        let tf = Utilities().textField(withPlaceholder: NSLocalizedString("Kullanıcı Adınız", comment: ""))
        tf.text = selectedSurname
        return tf
    }()
    
    
    
    private lazy var editProfileButton: UIButton = {
        let button = UIButton()
        button.setTitle("Değişiklikleri Kaydet", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .chatButtonBG
        button.layer.cornerRadius = 20
        button.setDimensions(width: 100, height: 50)
        
        button.addTarget(self, action: #selector(saveButtonPressed), for: .touchUpInside)

        
        return button
    }()
    
    
    private lazy var deleteAccountButton: UIButton = {
        let button = UIButton()
        button.setTitle("Hesabımı Sil", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .chatButtonBG
        button.layer.cornerRadius = 20
        button.setDimensions(width: 100, height: 50)
        
        button.addTarget(self, action: #selector(deleteButtonPressed), for: .touchUpInside)

        
        return button
    }()
    
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        configureNavigationBar(withTitle: "Profili Düzenle", prefLargeTitles: true)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .done, target: self, action: #selector(backButtonTapped))
        
        configureUI()
        
    }
    
    //MARK: - API
    
    
    //MARK: - Selector
    
    @objc func backButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    
    @objc func handleAddProfilePhoto() {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func deleteButtonPressed() {
        let user = Auth.auth().currentUser
        
        showLoader(true)
        

        user?.delete { error in
          if let error = error {
              print("DEBUG: Error is \(error.localizedDescription)")
              
              do {
                  try Auth.auth().signOut()
                  self.dismiss(animated: true) {
                      self.delegate?.handleDelete()
                  }
                  
                  
              } catch {
                  print("DEBUG: Failed to log user out")
              }
              
          } else {
            // Account deleted.
              
              print("Account Deleted")
              
              self.showLoader(false)
              
              self.dismiss(animated: true) {
                  self.delegate?.handleDelete()
              }
          }
        }
    }
    
    @objc func saveButtonPressed() {
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        
        guard let name = nameTextField.text?.trimmingCharacters(in: .whitespaces),
              !name.isEmpty else {
            showMessage(withTitle: NSLocalizedString("Ad Soyad", comment: ""), message: NSLocalizedString("Lütfen isminizi girin", comment: ""))
            return
        }
        
        guard let surname = surnameTextField.text?.trimmingCharacters(in: .whitespaces),
              !surname.isEmpty else {
            showMessage(withTitle: NSLocalizedString("Kullanıcı Adı", comment: ""), message: NSLocalizedString("Lütfen kullanıcı adınızı girin", comment: ""))
            return
        }
        
        
        let values = ["name": name,
                      "fullname": surname] as [String : Any]
        
        showLoader(true)

        COLLECTION_USERS.document(uid).updateData(values) { err in
            if let error = err {
                self.showMessage(withTitle: NSLocalizedString("Hata", comment: ""), message: error.localizedDescription)
                self.showLoader(false)
            }
            
            self.showLoader(false)
        }
        
    }
    
    func setProfileImage() {
        
    }
    
    

     @objc func cancelDatePicker(){
        self.view.endEditing(true)
      }
    
    
    
    //MARK: - Helper
    
    func configureUI() {
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        
        view.addSubview(scroolView)
        scroolView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0)
        
        scroolView.addSubview(scrollSubView)
        scrollSubView.anchor(top: scroolView.topAnchor, left: scroolView.leftAnchor, bottom: scroolView.bottomAnchor, width: view.frame.size.width)
        
        scrollSubView.addSubview(profileImageView)
        profileImageView.centerX(inView: scrollSubView, topAnchor: scrollSubView.safeAreaLayoutGuide.topAnchor, paddingTop: 40)
        
        
        let tfStack = UIStackView(arrangedSubviews: [ nameContainerView, surnameameContainerView])
        tfStack.axis = .vertical
        tfStack.spacing  = 15
        tfStack.distribution = .fillEqually
        
        scrollSubView.addSubview(tfStack)
        tfStack.anchor(top: profileImageView.bottomAnchor, left: scrollSubView.leftAnchor, right: scrollSubView.rightAnchor, paddingTop: 40, paddingLeft: 10, paddingRight: 10)
        
        
        scrollSubView.addSubview(editProfileButton)
        editProfileButton.anchor(top: tfStack.bottomAnchor, left: scrollSubView.leftAnchor, right: scrollSubView.rightAnchor, paddingTop: 60, paddingLeft: 10, paddingRight: 10, height: 120)
        
        
        
        scrollSubView.addSubview(deleteAccountButton)
        deleteAccountButton.anchor(top: editProfileButton.bottomAnchor, left: scrollSubView.leftAnchor, bottom: scrollSubView.bottomAnchor, right: scrollSubView.rightAnchor, paddingTop: 20, paddingLeft: 10, paddingBottom: 10, paddingRight: 10, height: 120)
        
        
        
    }
    
    func updateProfileImage() {
            guard let image = profileImage else { return }
        
        self.showLoader(true)
            
        AuthService.shared.updateProfileImage(image: image) { profileImageUrl in
            self.showLoader(false)
            }
        }

}

extension CASetProfileInfoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let profileImage = info[.editedImage] as? UIImage else { return }
        self.profileImage = profileImage
        
        profileImageView.setDimensions(width: 150, height: 150)
        profileImageView.layer.cornerRadius = 150 / 2
        profileImageView.layer.masksToBounds = true
        profileImageView.tintColor = .lightGray
        profileImageView.layer.borderColor = UIColor.white.cgColor
        
        self.profileImageView.image = profileImage.withRenderingMode(.alwaysOriginal)
        
        
        
        dismiss(animated: true) {
            print("XCXCXC")
            self.updateProfileImage()
        }
    }
    
}


