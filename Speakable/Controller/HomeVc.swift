//
//  FirstViewController.swift
//  Speakable
//
//  Created by Nicolas Guerrero on 5/16/20.
//  Copyright © 2020 Nicolas Guerrero. All rights reserved.
//

import UIKit
import Parse

class DataManager {
        static let shared = DataManager()
        var homeVC = HomeVC()
}

class HomeVC: UITableViewController {
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DataManager.shared.homeVC = self
        navigationController?.navigationBar.prefersLargeTitles = true
        self.tableView.allowsSelection = false
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        if PFUser.current() == nil {
            goToLogin()
        } else {
            fetchPods()
        }
    }

    
    //MARK: Properties, Outlets, Functions
    
    var pods: [Pod] = []
    var check = Array<Bool>()
    
    private func goToLogin() {
        performSegue(withIdentifier: "LoginViewController", sender: self)
    }
    
    func fetchPods() {
        let podQuery = Pod.query()
        podQuery?.includeKey("createdBy")
        podQuery?.includeKey("audio")
        podQuery?.includeKey("listens")
        podQuery?.addDescendingOrder("createdAt")
        podQuery?.findObjectsInBackground{ (objects: [PFObject]?, error) in
            if error != nil {
                print("Error")
                return
            }
            guard let objects = objects as? [Pod] else { return }
            self.pods = objects
            self.tableView.reloadData()
        }
    }
}

    //MARK: - TableView Delegate

extension HomeVC: UIGestureRecognizerDelegate {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pods.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? HomeTableViewCell else {
            return UITableViewCell() }

        let pod = pods[indexPath.row]
        cell.configureCell(pod: pod)

        cell.playButtonTapped = {
        pod.incrementKey("listens", byAmount: 0.5)
        pod.saveInBackground()
        for tempCell in tableView.visibleCells {
                if let ultraTempCell = tempCell as? HomeTableViewCell, ultraTempCell != cell {
                    if let ultraAudioPlayer = ultraTempCell.audioPlayer {
                        ultraAudioPlayer.pause()
                        ultraTempCell.playButton.setImage(#imageLiteral(resourceName: "bluePlay"), for: .normal)
                    } }
            }
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(HomeVC.handleTap))
        tap.delegate = self as UIGestureRecognizerDelegate
        cell.profilePicture.addGestureRecognizer(tap)
        return cell
    }
    
 
    @objc func handleTap(sender: UITapGestureRecognizer? = nil) {
        let point = sender!.location(in: view)
        guard let indexPath = tableView.indexPathForRow(at: point) else { return }
        
        let pod = pods[indexPath.row]
        var currentUser = pod.createdBy
        
        if pod.createdBy.email == PFUser.current()?.email{
            currentUser = PFUser.current()!
        }
        
        guard let tabController = tabBarController as? TabViewController else { return }
        tabController.currentUser = currentUser
        tabBarController?.selectedIndex = 1
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let pod = pods[indexPath.row]
        if pod.createdBy.email == PFUser.current()?.email {
            return true
        }
        else { return false }
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle.none
    }
   
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {  (contextualAction, view, boolValue) in
            self.removePod(atIndexPath: indexPath)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        deleteAction.backgroundColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteAction])
        return swipeActions
    }
    
    func removePod(atIndexPath indexPath: IndexPath) {
        let pod = pods[indexPath.row]
        pods.remove(at: indexPath.row)
        pod.deleteInBackground()
    }
 
}

