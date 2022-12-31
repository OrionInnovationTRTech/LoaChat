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
    private var filteresUsers = [User]()
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var inSearchMode: Bool {
        return searchController.isActive && !searchController.searchBar.text!.isEmpty
    }
    
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        configureUI()
        setupSearchController()
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
    
    func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.searchBar.showsCancelButton = false
        navigationItem.searchController = searchController
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Kullanıcı arayın..."
        searchController.searchBar.placeholder = NSLocalizedString("Kullanıcı arayın...", comment: "")
        definesPresentationContext = false
        
        if let textfield = searchController.searchBar.value(forKey: "searchField") as? UITextField {
            textfield.textColor = .chatGunmetal
            textfield.backgroundColor = .white
        }
    }
    
    
    
    
}

extension CANewMessageController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inSearchMode ? filteresUsers.count : users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifer, for: indexPath) as! CAUserCell
        
        cell.user = inSearchMode ? filteresUsers[indexPath.row] : users[indexPath.row]
        
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = inSearchMode ? filteresUsers[indexPath.row] : users[indexPath.row]
        
        delegate?.controller(self, wantsToStartChatWith: user)

    }
    
    
}

extension CANewMessageController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
        guard let searchText = searchController.searchBar.text?.lowercased() else {return}
        
        filteresUsers = users.filter({ user in
            return user.username.contains(searchText) || user.fullname.contains(searchText)
        })
        
        self.tableView.reloadData()
         
    }
    
    
}
