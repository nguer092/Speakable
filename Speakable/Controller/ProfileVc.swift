//
//  SecondViewController.swift
//  Speakable
//
//  Created by Nicolas Guerrero on 5/16/20.
//  Copyright © 2020 Nicolas Guerrero. All rights reserved.
//

import UIKit
import Parse

class ProfileVC: UIViewController {
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard (tabBarController as? TabViewController) != nil else { return }
        
        profilePic.layer.contentsGravity = CALayerContentsGravity.bottom
        profilePic.contentMode = UIView.ContentMode.scaleAspectFill
        profilePic.isUserInteractionEnabled = true
        profilePic.setRadius()
        editUsernameTextField.isHidden = true
        saveButton.isHidden = true
        navigationController?.navigationBar.isHidden = true
        podsButton.addBottomBorderWithColor(color: greenColor(), width: 3)
        
        self.tableview.dataSource = self
        self.tableview.delegate = self
        self.tabBarController?.delegate = self
        self.tableview.allowsSelection = false
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        guard let tabController = tabBarController as? TabViewController else { return }
        tabController.currentUser = nil
        currentUser = nil
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        guard let tabController = tabBarController as? TabViewController else { return }
        
        if tabController.currentUser != nil {
            currentUser = tabController.currentUser
        } else {
            currentUser = PFUser.current()
        }
        setupProfile()
    }
    
    func setupProfile() {
        usernameLabel.text = currentUser?.username
        
        if currentUser != PFUser.current() {
            followingSwitch.isHidden = false
            editButton.isHidden = true
            logoutButton.isHidden = true
        } else if currentUser == PFUser.current() {
            followingSwitch.isHidden = true
            editButton.isHidden = false
            logoutButton.isHidden  = false
        }
        
        let podQuery = Pod.query()
        podQuery?.whereKey("createdBy", equalTo: currentUser as Any)
        podQuery?.includeKey("audio")
        podQuery?.findObjectsInBackground(block: { (objects, error) in
            if error != nil {
                print("Error")
            } else if let pods = objects {
                self.pods.removeAll()
                for pod in pods {
                    if let pod = pod as? Pod {
                        self.pods.insert(pod, at: 0)
                    }
                }
                self.tableview.reloadData()
            }
        })
        
        let subscribersQuery = Following.query()
        subscribersQuery?.whereKey("following", equalTo: currentUser as Any)
        subscribersQuery?.includeKey("follower")
        subscribersQuery?.findObjectsInBackground(block: {(objects, error) in
            if let objects = objects {
                self.subscribers.removeAll()
                for object in objects {
                    self.subscribers.insert(object["follower"] as! PFUser, at: 0)
                }
            }
            querySubscribed()
        })
    

        func querySubscribed () {
            let subscribedQuery = Following.query()
            subscribedQuery?.whereKey("follower", equalTo: currentUser as Any)
            subscribersQuery?.includeKey("following")
            subscribedQuery?.findObjectsInBackground(block: { (objects, error) in
                if let objects = objects {
                    self.subscribed.removeAll()
                    for object in objects {
                        self.subscribed.insert(object["following"] as! PFUser, at: 0)
                    }
                }
            })
        }
        
        
        //Switch State
        let switchQuery = Following.query()
        switchQuery?.whereKey("follower", equalTo: PFUser.current() as Any)
        switchQuery?.whereKey("following", equalTo: currentUser as Any)
        switchQuery?.findObjectsInBackground(block: { (objects, error) in
            if error != nil {
                print(error?.localizedDescription as Any)
            } else if objects != nil && objects!.count != 0 {
                self.followingSwitch.isOn = true
            } else {
                self.followingSwitch.isOn = false
            }
        })
    }
    
    
    //MARK:  - Properties, Outlets
    
    var pods: [Pod] = []
    var subscribers: [PFUser] = []
    var subscribed: [PFUser] = []
    var displayState = DisplayState.pods
    override var prefersStatusBarHidden: Bool { return true }
    var currentUser: PFUser! {
        didSet {
            if self.currentUser == nil {
                self.profilePic.image = nil
                return
            }
            let userImageFile = self.currentUser["picture"] as? PFFileObject
            userImageFile?.getDataInBackground { (imageData: Data?, error: Error?) -> Void in
                if error == nil {
                    if let imageData = imageData {
                        let image = UIImage(data:imageData)
                        self.profilePic.image = image
                    }
                    else {
                        print(error?.localizedDescription as Any)
                    }
                }
            }
        }
    }
    let tap = UITapGestureRecognizer.self
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var podsButton: BottomBorderButton!
    @IBOutlet weak var subscribedButton: BottomBorderButton!
    @IBOutlet weak var subscribersButton: BottomBorderButton!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var editUsernameTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var followingSwitch: UISwitch!
    
    
    //MARK: - Actions
    
    @IBAction func followSwitched(_ sender: UISwitch) {
        if followingSwitch.isOn {
            let following = PFObject(className: "Following")
            following["follower"] = PFUser.current()
            following["following"] = currentUser
            following.saveInBackground()
        }
        else {
            let followingQuery = PFQuery(className: "Following")
            followingQuery.whereKey("follower", equalTo: PFUser.current() as Any)
            followingQuery.whereKey("following", equalTo: currentUser as Any)
            followingQuery.findObjectsInBackground(block: { (objects, error) in
                if let objects = objects {
                    for object in objects {
                        object.deleteInBackground()
                    }
                }
            })
        }
    }
    
    @IBAction func logoutButtonPressed(_ sender: UIButton) {
        PFUser.logOut()
        goToLaunch()
    }
    
    @IBAction func editButtonPressed(_ sender: UIButton) {
        editButton.isHidden = true
        saveButton.isHidden = false
        editUsernameTextField.isHidden = false
        editUsernameTextField.placeholder = PFUser.current()?.username
    }
    
    @IBAction func saveButtonClicked(_ sender: UIButton) {
        saveButton.isHidden = true
        editButton.isHidden = false
        editUsernameTextField.isHidden = true
        self.editUsernameTextField.resignFirstResponder()
        self.currentUser.username = editUsernameTextField.text
        self.currentUser.saveInBackground()
        usernameLabel.text = currentUser?.username
    }
    
    @IBAction func podsButtonClicked(_ sender: BottomBorderButton) {
        displayState = .pods
        podsButton.addBottomBorderWithColor(color: greenColor(), width: 3)
        subscribedButton.removeBottomBorder()
        subscribersButton.removeBottomBorder()
        self.tableview.reloadData()
    }
    
    @IBAction func subscribedButtonClicked(_ sender: BottomBorderButton) {
        displayState = .subscribed
        subscribedButton.addBottomBorderWithColor(color: greenColor(), width: 3)
        podsButton.removeBottomBorder()
        subscribersButton.removeBottomBorder()
        self.tableview.reloadData()
    }
    
    @IBAction func subscribersButtonClicked(_ sender: BottomBorderButton) {
        displayState = .subscribers
        subscribersButton.addBottomBorderWithColor(color: greenColor(), width: 3)
        podsButton.removeBottomBorder()
        subscribedButton.removeBottomBorder()
        self.tableview.reloadData()
    }
    
    
    //MARK: - Functions
    
    private func greenColor() -> UIColor {
        return UIColor(displayP3Red: 154.0/255.0, green: 251.0/255.0, blue: 126.0/255.0, alpha: 0.75)
    }
    
    private func goToLaunch() {
        let logoutPopup = UIAlertController(title: "Logout?", message: "Are you sure you want to logout?", preferredStyle: .actionSheet)
        let logoutAction = UIAlertAction(title: "Logout", style: .destructive) { (buttonTapped) in
            do {
                PFUser.logOut()
                let launchVC = self.storyboard?.instantiateViewController(withIdentifier: "InitialVC")
                self.present(launchVC!, animated: true, completion: nil)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { (buttonTapped) in
            do {
                self.dismiss(animated: true, completion: nil)
            }
        }
        logoutPopup.addAction(logoutAction)
        logoutPopup.addAction(cancelAction)
        present(logoutPopup, animated: true, completion: nil)
    }
    
}


    //MARK: - TableView Delegate

extension ProfileVC: UITableViewDataSource, UITableViewDelegate {
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        if displayState == .pods {
            count = pods.count
        } else if displayState == .subscribers {
            count = subscribers.count
        } else if displayState == .subscribed {
            count = subscribed.count
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tap = UITapGestureRecognizer(target: self, action: #selector(ProfileVC.handleTap))
        tap.delegate = self as UIGestureRecognizerDelegate
        
        if displayState == .pods{
            let cell = tableView.dequeueReusableCell(withIdentifier: displayState.rawValue) as! ProfileTableViewCell
            let pod = pods[indexPath.row]
            cell.configureCell(pod: pod)
            cell.audioPlayer = nil
            
            cell.playButtonTapped = {
                for tempCell in tableView.visibleCells {
                    if let ultraTempCell = tempCell as? ProfileTableViewCell, ultraTempCell != cell {
                        if let ultraAudioPlayer = ultraTempCell.audioPlayer {
                            ultraAudioPlayer.pause()
                            ultraTempCell.playButton.setImage(#imageLiteral(resourceName: "bluePlay"), for: .normal)
                        } }
                }
            }
            return cell
        } else if displayState == .subscribed  {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell") as! FollowingTableViewCell
            let user = subscribed[indexPath.row]
            cell.configureSearchCell(user: user)
            cell.addGestureRecognizer(tap)
            return cell
        } else if displayState == .subscribers {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell") as! FollowingTableViewCell
            let user = subscribers[indexPath.row]
            cell.configureSearchCell(user: user)
            cell.addGestureRecognizer(tap)
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    
    //MARK: - Pod Deletion
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if currentUser == PFUser.current() { return true }
        else {return false}
    
}
     
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
         return UITableViewCell.EditingStyle.none
     }
    
     func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
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


    //MARK: - ImagePickerDelegate

extension ProfileVC: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBAction func selectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        if currentUser == PFUser.current() {
            let imagePickerController = UIImagePickerController()
            imagePickerController.sourceType = .photoLibrary
            imagePickerController.delegate = self
            present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let selectedPhoto = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.originalImage.rawValue)] as! UIImage
        dismiss(animated: true, completion: {
            self.profilePic.image = selectedPhoto
            let imageData = selectedPhoto.pngData()
            if let imageFile = PFFileObject(data: imageData!) {
                self.currentUser["picture"] = imageFile
                self.currentUser.saveInBackground()
            }
        })
    }
}


    //MARK: - TabBarControllerDelegate

extension ProfileVC: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if viewController === self.navigationController && self.isViewLoaded  {
            if self.view.window != nil {
                currentUser = PFUser.current()
                self.profilePic?.image = self.currentUser["picture"] as? UIImage ?? nil
                setupProfile()
                self.tableview.reloadData()
            }
        }
    }
}

extension ProfileVC: UIGestureRecognizerDelegate {
    
    @objc func handleTap(sender: UITapGestureRecognizer? = nil) {
        let point = sender!.location(in: tableview)
        guard let indexPath = tableview.indexPathForRow(at: point) else { return }
        
        if displayState == .subscribed  {
            currentUser = subscribed[indexPath.row]
               } else if displayState == .subscribers {
            currentUser = subscribers[indexPath.row]
        }
        guard let tabController = tabBarController as? TabViewController else { return }
        tabController.currentUser = currentUser
        tabBarController?.selectedIndex = 1
        displayState = .pods
        podsButton.addBottomBorderWithColor(color: greenColor(), width: 3)
        subscribedButton.removeBottomBorder()
        subscribersButton.removeBottomBorder()
        setupProfile()
        self.tableview.reloadData()
}
}
