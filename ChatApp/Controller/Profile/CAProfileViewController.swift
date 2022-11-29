//
//  CAProfileViewController.swift
//  ChatApp
//
//  Created by Furkan Erdoğan on 31.10.2022.
//

import UIKit
import Firebase

struct Section {
    let title : String
    let options : [SettingsOptionType]
}

enum SettingsOptionType {
    case staticCell(model: SettingsOption)
    case switchCell(model: SettingsSwitchOption)
}

struct SettingsSwitchOption {
    let name : String
    let username : String
    let image : UIImage?
    let iconBackgroundColor : UIColor
    let handler : (() -> Void)
    var isOn : Bool
}

struct SettingsOption {
    let title : String
    let icon : UIImage?
    let iconBackgroundColor : UIColor
    let handler : (() -> Void)
}

protocol ProfileFooterViewDelegate: class {
    func handleLogout()
}

protocol ProfileInfoUpdateDelegate: class {
    func handleProfile()
}

var selectedProfileImageUrl: String?

 final class CAProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
     
     //MARK: - PROPERTIES
     
     private var user: User? {
         didSet {
             configure()
         }
     }
     
     weak var delegate: ProfileFooterViewDelegate?
     weak var updateDelegate: ProfileInfoUpdateDelegate?
     
     
    private let tableView : UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(CASettingTableViewCell.self,
                       forCellReuseIdentifier: CASettingTableViewCell.identifier)
        table.register(CAProfileInfoViewCell.self,
                       forCellReuseIdentifier: CAProfileInfoViewCell.identifier)
        return table
    }()
    
    var models = [Section]()
     
     private let photoURL = "https://images.unsplash.com/photo-1667202374063-3c995a7517ae?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1064&q=80"
     
     //MARK: - LIFECYCLE


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        configureNavigationBar(withTitle: NSLocalizedString("Ayarlar", comment: ""), prefLargeTitles: true)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .done, target: self, action: #selector(backButtonTapped))
        showLoader(true)

        fetchUser()
        
        view.addSubview(tableView)
        tableView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
        tableView.rowHeight = 60
        

    }
     
     //MARK: - API
     
     func fetchUser() {
         
         guard let uid = Auth.auth().currentUser?.uid else {return}
         Service.fetchUser(withUID: uid) { user in
             self.user = user
             selectedProfileImageUrl = user.profileImageUrl
             self.tableView.reloadData()
             self.showLoader(false)
         }
     }
     
     

     
     //MARK: - SELECTOR

     
     @objc func backButtonTapped() {
         dismiss(animated: true, completion: nil)
     }
     
     
    
    func configure() {
        
        models = []
        
                
        //MARK: SWİTCH
        models.append(Section(title: NSLocalizedString(NSLocalizedString("Profil", comment: ""), comment: ""), options: [
            .switchCell(model: SettingsSwitchOption(name: NSLocalizedString(user?.fullname ?? "Deneme", comment: ""), username: "@\(user?.username ?? "username")", image: UIImage(url: URL(string: user?.profileImageUrl ?? photoURL)), iconBackgroundColor: .chatButtonBG, handler: {
                //Switch action code is here
                
                self.dismiss(animated: true) {
                    self.updateDelegate?.handleProfile()
                }
                
                
                
            }, isOn: false))
        ]))
        
        //MARK: SECTION ONE
        models.append(Section(title: NSLocalizedString(NSLocalizedString("Genel", comment: ""), comment: ""), options: [
            
            .staticCell(model: SettingsOption(title: NSLocalizedString("Dil", comment: ""), icon: UIImage(systemName: "textbox"), iconBackgroundColor: .chatButtonBG, handler: {
                //Hücrenin yapacağı işlev buraya ...
                
                guard let url = URL(string: UIApplication.openSettingsURLString) else {
                   return
                }
                if UIApplication.shared.canOpenURL(url) {
                   UIApplication.shared.open(url, options: [:])
                }
                
                print("İlk Hücreye tıklandı")
            })),
            
            .staticCell(model: SettingsOption(title: NSLocalizedString(NSLocalizedString("Çıkış Yap", comment: ""), comment: ""), icon: UIImage(systemName: "rectangle.righthalf.inset.fill.arrow.right"), iconBackgroundColor: .chatButtonBG, handler: {
                
                let alertController = UIAlertController(title: nil, message: NSLocalizedString("Çıkış yapmak istediğinden emin misin?", comment: ""), preferredStyle: .actionSheet)
                       
                       
                       alertController.addAction(UIAlertAction(title: NSLocalizedString("Çıkış Yap", comment: ""), style: .destructive, handler: { (_) in
                           self.dismiss(animated: true) {
                               self.delegate?.handleLogout()
                           }
                       }))
                       
                       alertController.addAction(UIAlertAction(title: NSLocalizedString("İptal", comment: ""), style: .cancel))
                       
                self.present(alertController, animated: true)
            }))
            
            
        ]))
        
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = models[section]
        return section.title
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return models.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models[section].options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.section].options[indexPath.row]
        
        switch model.self {
        case .staticCell(let model):
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: CASettingTableViewCell.identifier,
                for: indexPath
            ) as? CASettingTableViewCell else {
                return UITableViewCell()
            }
            cell.configure(with: model)
            return cell
        case .switchCell(let model):
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: CAProfileInfoViewCell.identifier,
                for: indexPath
            ) as? CAProfileInfoViewCell else {
                return UITableViewCell()
            }
            cell.configure(with: model)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let type = models[indexPath.section].options[indexPath.row]
        switch type.self {
        case .staticCell(let model):
            model.handler()
        case .switchCell(let model):
            model.handler()
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UIView()
        footer.frame = CGRect(x: 0, y: 0, width: 540, height: 55)
          
        if (section == models.count - 1){
            footer.backgroundColor = .clear
            let lbl = UILabel()
            lbl.frame = CGRect(x: 10, y: 0, width: 540, height: 40)
            lbl.backgroundColor = .clear
            lbl.font = UIFont(name: "HelveticaNeue-Light", size: 10)
            lbl.text = "Messaging For Everyone"
            lbl.numberOfLines = 1
            footer.addSubview(lbl)
            let lbl2 = UILabel()
            lbl2.frame = CGRect(x: 10, y: 12, width: 540, height: 40)
            lbl2.backgroundColor = .clear
            lbl2.font = UIFont(name: "HelveticaNeue-Light", size: 10)
            lbl2.text = "V 1.0.0"
            lbl2.numberOfLines = 1
            footer.addSubview(lbl2)
            self.tableView.tableFooterView = footer

        }
            return footer
    }
     
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
         let type = models[indexPath.section].options[indexPath.row]
         var height = CGFloat(60)
         switch type.self {
         case .staticCell:
             height = CGFloat(40)
         case .switchCell:
             height = CGFloat(60)
         }
         
         return height
     }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (section == models.count - 1) {
            return 60.0
        } else {
            return 0.0
        }
    }
}
