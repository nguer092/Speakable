//
//  SearchVC.swift
//  Speakable
//
//  Created by Nicolas Guerrero on 5/16/20.
//  Copyright © 2020 Nicolas Guerrero. All rights reserved.
//

import UIKit
import Parse

class SearchVC: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    var users : [PFUser] = []
    var filteredUsers = [PFUser]()
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Setup the Search Controller
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Users"
        definesPresentationContext = true
        fetchUsers()
    }
    
    // MARK: - Methods
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredUsers = users.filter({( user : PFUser) -> Bool in
            return (user.username?.lowercased().contains(searchText.lowercased()))!
        })
        self.tableView.reloadData()
    }
    
    func fetchUsers() {
        let userQuery = PFUser.query()
        userQuery?.includeKey("username")
        userQuery?.includeKey("picture")
        userQuery?.findObjectsInBackground{ (objects: [PFObject]?, error) in
            if error != nil {
                print("Error")
                return
            }
            guard let objects = objects as? [PFUser] else { return }
            self.users = objects
            self.tableView.reloadData()
        }
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath) as! FollowingTableViewCell
        
        let user: PFUser
        if isFiltering() {
            user = filteredUsers[indexPath.row]
        } else {
            user = users[indexPath.row]
        }
        
        cell.configureSearchCell(user: user)
        
        
        //Tap Gesture
        let tap = UITapGestureRecognizer(target: self, action: #selector(SearchVC.handleTap))
        tap.delegate = self as UIGestureRecognizerDelegate
        cell.addGestureRecognizer(tap)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredUsers.count
        } else {
        return users.count
        }
    }
}


extension SearchVC: UIGestureRecognizerDelegate {
    
    @objc func handleTap(sender: UITapGestureRecognizer? = nil) {
        let point = sender!.location(in: tableView)
        guard let indexPath = tableView.indexPathForRow(at: point) else { return }
        
        let currentUser = users[indexPath.row]

        DataManager.shared.tabController.currentUser = currentUser
        tabBarController?.selectedIndex = 1
    }
}

extension SearchVC: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

