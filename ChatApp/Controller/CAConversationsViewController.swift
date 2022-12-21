//
//  CAConversationsViewController.swift
//  ChatApp
//
//  Created by Furkan Erdoğan on 11.10.2022.
//

import Foundation
import UIKit
import FirebaseAuth
import Lottie

private let reuseIdentifer = "ConversationCell"

final class CAConversationsViewController: UIViewController {
    
    //MARK: - Properties
    
    private let tableView = UITableView()
    private var conversations = [Conversation]()
    private var conversationsDictionary = [String: Conversation]()
    private var animationView: AnimationView?
    let notificationCenter = NotificationCenter.default

    
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        configureUI()
        authenticateUser()
        fetchConversations()
        
        notificationCenter.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(withTitle: NSLocalizedString("Mesajlar", comment: ""), prefLargeTitles: true)
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
                tableView.deselectRow(at: selectedIndexPath, animated: animated)
            }
        
        
        
        print("DEBUG: Conver: \(conversations.isEmpty)")
        
        if conversations.isEmpty == false {
            self.animationView?.isHidden = true
        }
        
        notificationCenter.removeObserver(self)

    }
    
    //MARK: - API
    
    private func fetchConversations() {
        showLoader(true)
        conversations.removeAll()
        conversationsDictionary.removeAll()
        
        self.tableView.reloadData()
        
        Service.fetchConversation { conversations in
            conversations.forEach { conversation in
                let message = conversation.message
                self.conversationsDictionary[message.chatPartnerId] = conversation
            }
            
            print("aha123")
            
            self.conversations = Array(self.conversationsDictionary.values)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        print("DEBUG: Conver: \(conversations.isEmpty)")
        self.showLoader(false)
    }
    
    private func logout() {
            do {
                try Auth.auth().signOut()
                presentLoginScreen()
            } catch let error {
                print("DEBUG: Error signing out...", error.localizedDescription)
            }
        }
    
    
    //MARK: - Selector
    
    @objc func profileButtonTapped() {
        print("Deneme")
        
        let vc = CAProfileViewController()
        vc.delegate = self
        vc.updateDelegate = self
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    @objc func newMessageButtonTapped() {
        
        let vc = CANewMessageController()
        vc.delegate = self
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    
    
    private func authenticateUser() {
            if Auth.auth().currentUser?.uid == nil {
                presentLoginScreen()
                print("DEBUG: User is not logged in ")
                
            }
        print("IDDDD: \(Auth.auth().currentUser?.uid)")
        }
        
        
        
        //MARK: - Helpers
        
        private func presentLoginScreen() {
            DispatchQueue.main.async {
                let controller = CALoginViewController()
                controller.delegate = self
                let navVC = UINavigationController(rootViewController: controller)
                navVC.modalPresentationStyle = .fullScreen
                self.present(navVC, animated: true)
            }
        }
    
    func configureUI() {
        
        view.backgroundColor = .systemBackground
        
        configureTableView()
        
        let image = UIImage(systemName: "person.circle.fill")
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(profileButtonTapped))
        
        let image2 = UIImage(systemName: "plus.message.fill")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image2, style: .plain, target: self, action: #selector(newMessageButtonTapped))
        
        //Animation View
        
        animationView = .init(name: "100757-not-found")
          
        animationView!.frame = view.bounds
        animationView?.backgroundColor = .clear
          
        animationView!.contentMode = .scaleAspectFit
          
        animationView!.loopMode = .playOnce
        animationView?.isHidden = true
          
        animationView!.animationSpeed = 1.0
          
        view.addSubview(animationView!)
        animationView?.center(inView: view)
        animationView?.setDimensions(width: 180, height: 180)
          
        animationView!.play()
        
    }
    
    func configureTableView() {
        tableView.backgroundColor = .systemBackground
        tableView.rowHeight = 80
        tableView.register(CAConversationCell.self, forCellReuseIdentifier: reuseIdentifer)
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(tableView)
        tableView.frame  = view.frame
    }
    
    
    
    
    
    
    
}

extension CAConversationsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if conversations.count == 0 {
            print("ahaha2")
            animationView?.isHidden = false
        } else {
            animationView?.isHidden = true
        }
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifer, for: indexPath) as! CAConversationCell
        
        cell.conversation = conversations[indexPath.row]
        
        print("Abee: \(conversations[indexPath.row].message.timeStamp.dateValue())")
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = conversations[indexPath.row].user
        let vc = CAChatViewController(user: user)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                // delete your item here and reload table view
            }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
            -> UISwipeActionsConfiguration? {
            let deleteAction = UIContextualAction(style: .destructive, title: nil) { (_, _, completionHandler) in
                // delete the item here
                completionHandler(true)
            }
            deleteAction.image = UIImage(systemName: "trash")
            deleteAction.backgroundColor = .systemRed
            let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
            return configuration
    }

    
    
}


extension CAConversationsViewController: NewMessageControllerDelegate {
    func controller(_ controller: CANewMessageController, wantsToStartChatWith user: User) {
        controller.dismiss(animated: true, completion: nil)
        let chatVC = CAChatViewController(user: user)
        navigationController?.pushViewController(chatVC, animated: true)
    }
    
    
}

extension CAConversationsViewController: ProfileFooterViewDelegate {
    func handleLogout() {
        self.logout()
    }
    
}

extension CAConversationsViewController: ProfileInfoUpdateDelegate {
    func handleProfile() {
        let vc = CASetProfileInfoViewController()
        vc.delegate = self
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
    
    
}

extension CAConversationsViewController: DeleteAccountDelegate {
    func handleDelete() {
        self.presentLoginScreen()
    }
    
    
}

extension CAConversationsViewController: AuthenticationDelegate {
    func authenticationComplete() {
        dismiss(animated: true) {
            self.configureUI()
            self.fetchConversations()
        }
        
    }
    
    
}
