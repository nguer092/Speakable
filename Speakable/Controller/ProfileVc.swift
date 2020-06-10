//
//  SecondViewController.swift
//  Speakable
//
//  Created by Nicolas Guerrero on 5/16/20.
//  Copyright © 2020 Nicolas Guerrero. All rights reserved.
//

import UIKit
import Parse

class ProfileVC: UIViewController{
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        guard (tabBarController as? TabViewController) != nil else { return }
        
        self.profilePic.layer.contentsGravity = CALayerContentsGravity.bottom
        profilePic.isUserInteractionEnabled = true
        profilePic.setRadius()
        profilePic.contentMode = UIView.ContentMode.scaleAspectFill
        
        editUsernameTextField.isHidden = true
        saveButton.isHidden = true
        
        self.tableview.dataSource = self
        self.tableview.delegate = self
        
        navigationController?.navigationBar.isHidden = true
        
        podsButton.addBottomBorderWithColor(color: greenColor(), width: 3)
        followingSwitch.isOn = false
    }

    
    override func viewDidDisappear(_ animated: Bool) {
        guard let tabController = tabBarController as? TabViewController else { return }
        tabController.currentUser = nil
        currentUser = nil
    }

    
    override func viewWillAppear(_ animated: Bool) {
        
        
        guard let tabController = tabBarController as? TabViewController else { return }
        
        if tabController.currentUser != nil {
            currentUser = tabController.currentUser
        } else {
            currentUser = PFUser.current()
        }
        
        if currentUser != PFUser.current() {
            followingSwitch.isHidden = false
            editButton.isHidden = true
            logoutButton.isHidden = true
        }
        
        if currentUser == PFUser.current() {
            followingSwitch.isHidden = true
            editButton.isHidden = false
            logoutButton.isHidden  = false
        }
        
        // Set user's properties
        usernameLabel.text = currentUser?.username

        // Query for user's pods
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
        
        //Query for the user's subscribers
        let subscribersQuery = Following.query()
        subscribersQuery?.whereKey("following", equalTo: currentUser.objectId as Any)
        subscribersQuery?.includeKey("follower")
        subscribersQuery?.findObjectsInBackground(block: {(objects, error) in
            if let objects = objects {
                self.subscribers.removeAll()
                for object in objects {
                    self.subscribers.insert(object["follower"] as! String, at: 0)
                }
            }
            querySubscribed()
        })

        //Query for the users that the user is subscribed to
        func querySubscribed () {
        let subscribedQuery = Following.query()
        subscribedQuery?.whereKey("follower", equalTo: currentUser.objectId as Any)
        subscribersQuery?.includeKey("following")
        subscribedQuery?.findObjectsInBackground(block: { (objects, error) in
            if let objects = objects {
                self.subscribed.removeAll()
                for object in objects {
                    self.subscribed.insert(object["following"] as! String, at: 0)
                }
            }
        })
        }
        
        //Switch State
        
        // Figure out which user's profile you're viewing and check if the current logged-in user is following them
        
        let switchQuery = Following.query()
        switchQuery?.whereKey("follower", equalTo: PFUser.current()?.objectId as Any)
        switchQuery?.whereKey("following", equalTo: currentUser.objectId as Any)
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
    

    //MARK: Properties, Outlets, Actions
    
    var pods: [Pod] = []
    var subscribers: [String] = []
    var subscribed: [String] = []
    var displayState = DisplayState.pods
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
    
    @IBAction func followSwitched(_ sender: UISwitch) {
        if followingSwitch.isOn {
            let following = PFObject(className: "Following")
            following["follower"] = PFUser.current()?.objectId
            following["following"] = currentUser.objectId
            following.saveInBackground()
        }
        else {
            let followingQuery = PFQuery(className: "Following")
            followingQuery.whereKey("follower", equalTo: PFUser.current()?.objectId as Any)
            followingQuery.whereKey("following", equalTo: currentUser.objectId as Any)
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
        goToLogin()
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
    

    //MARK: Functions

    private func greenColor() -> UIColor {
        return UIColor(displayP3Red: 154.0/255.0, green: 251.0/255.0, blue: 126.0/255.0, alpha: 0.75)
    }
    
    private func goToLogin() {
        performSegue(withIdentifier: "goToLogin", sender: self)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}


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
        if displayState == .pods{
            let cell = tableView.dequeueReusableCell(withIdentifier: displayState.rawValue) as! ProfileTableViewCell
            let pod = pods[indexPath.row]
            cell.configureCell(pod: pod)
            cell.audioPlayer = nil
            return cell
        } else if displayState == .subscribed  {
            let cell = tableView.dequeueReusableCell(withIdentifier: displayState.rawValue) as! FollowingTableViewCell
            let user = subscribed[indexPath.row]
            cell.configureCell(user: user)
            return cell
        } else if displayState == .subscribers {
            let cell = tableView.dequeueReusableCell(withIdentifier: displayState.rawValue) as! FollowingTableViewCell
            let user = subscribers[indexPath.row]
            cell.configureCell(user: user)
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
}


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
 
