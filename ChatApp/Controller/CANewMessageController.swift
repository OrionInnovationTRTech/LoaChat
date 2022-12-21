//
//  CANewMessageController.swift
//  ChatApp
//
//  Created by Furkan Erdoğan on 24.10.2022.
//

import Foundation
import UIKit

protocol NewMessageControllerDelegate: class {
    func controller(_ controller: CANewMessageController, wantsToStartChatWith user: User)
}

private let reuseIdentifer = "NewMessageCell"


class CANewMessageController: UITableViewController {
    
    //MARK: - Properties
    
    weak var delegate: NewMessageControllerDelegate?
    
    private var users = [User]()
    
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        configureUI()
        fetchUsers()
    }
    
    //MARK: - API
    
    private func fetchUsers() {
            showLoader(true)
            Service.fetchUsers { [weak self] (users) in
                guard let self = self else { return }
                
                self.showLoader(false)
                self.users = users
                self.tableView.reloadData()
            }
        }
    
    
    //MARK: - Selector
    
    @objc func dissmisButtonPressed() {
        dismiss(animated: true)
    }
    
    
    
    //MARK: - Helper
    
    func configureUI() {
        view.backgroundColor = .systemBackground
        configureNavigationBar(withTitle: NSLocalizedString("Yeni Mesaj", comment: ""), prefLargeTitles: false)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dissmisButtonPressed))
        
        tableView.tableFooterView = UIView()
        tableView.register(CAUserCell.self, forCellReuseIdentifier: reuseIdentifer)
        tableView.rowHeight = 80
        
    }
    
<<<<<<< Updated upstream
=======
    func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.searchBar.showsCancelButton = false
        navigationItem.searchController = searchController
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = NSLocalizedString("Kullanıcı arayın...", comment: "")
        definesPresentationContext = false
        
        if let textfield = searchController.searchBar.value(forKey: "searchField") as? UITextField {
            textfield.textColor = .chatGunmetal
            textfield.backgroundColor = .white
        }
    }
    
>>>>>>> Stashed changes
    
    
    
}

extension CANewMessageController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifer, for: indexPath) as! CAUserCell
        
        cell.user = users[indexPath.row]
        
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        delegate?.controller(self, wantsToStartChatWith: users[indexPath.row])

    }
    
    
}
