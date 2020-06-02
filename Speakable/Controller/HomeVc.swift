//
//  FirstViewController.swift
//  Speakable
//
//  Created by Nicolas Guerrero on 5/16/20.
//  Copyright © 2020 Nicolas Guerrero. All rights reserved.
//

import UIKit
import Parse

class HomeVC: UITableViewController {
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
     
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = false
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        if PFUser.current() == nil {
            goToLogin()
        } else {
            fetchPods()
        }
    }
    
    
    //MARK: Properties, Outlets, Actions
    var pods: [Pod] = []
    let tap = UITapGestureRecognizer.self
    
    
    //MARK: Functions
    private func goToLogin() {
        performSegue(withIdentifier: "LoginViewController", sender: self)
    }
    
    func fetchPods() {
        let podQuery = Pod.query()
        podQuery?.includeKey("createdBy")
        podQuery?.includeKey("audio")
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


extension HomeVC: UIGestureRecognizerDelegate {
    
    //MARK: - Table View Methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pods.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? HomeTableViewCell else {
            return UITableViewCell() }
        
        //Pass Pods
        cell.profilePicture.layer.contentsGravity = CALayerContentsGravity.bottom
        let pod = pods[indexPath.row]
        cell.configureCell(pod: pod)
        
        //Tap Gesture
        let tap = UITapGestureRecognizer(target: self, action: #selector(HomeVC.handleTap))
        tap.delegate = self as UIGestureRecognizerDelegate
        cell.profilePicture.addGestureRecognizer(tap)
        cell.addGestureRecognizer(tap)
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
    
    
}

