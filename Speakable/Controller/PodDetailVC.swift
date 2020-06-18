//
//  PodDetailVC.swift
//  Speakable
//
//  Created by Nicolas Guerrero on 6/16/20.
//  Copyright © 2020 Nicolas Guerrero. All rights reserved.
//

import UIKit
import Parse

class PodDetailVC: UIViewController {

    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableview.delegate = self
        self.tableview.dataSource = self
        sendButtonView.bindToKeyboard()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:  #selector(refreshComments), for: .valueChanged)
        self.tableview.refreshControl = refreshControl
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchComments()
        //Configure Pod
        self.podNameLabel.text = self.pod?.createdBy.username
        self.podDescription.text = self.pod?.podDescription
        let userImageFile = self.pod?.createdBy["picture"] as? PFFileObject
        userImageFile?.getDataInBackground(block: { (imageData, error) -> Void in
            if error == nil {
                if let imageData = imageData {
                    let image = UIImage(data: imageData)
                    self.podProfilePicture.image = image
                }
            }
            else {
                print(error?.localizedDescription as Any)
            }
        })
        self.podProfilePicture.layer.contentsGravity = CALayerContentsGravity.bottom
        self.podProfilePicture.contentMode = UIView.ContentMode.scaleAspectFill
        self.podProfilePicture.setRadius()
        //Animate to bottom of table view when sending a new message
        if self.podComments.count > 0 {
            self.tableview.scrollToRow(at: IndexPath(row: self.podComments.count - 1, section: 0), at: .none, animated: true)
        }
    }
    
    
    //MARK: - Properties, Outlets, Actions
    
    var pod : Pod?
    var podComments = [Comment]()
    @IBOutlet weak var podNameLabel: UILabel!
    @IBOutlet weak var podDescription: UILabel!
    @IBOutlet weak var podProfilePicture: UIImageView!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var sendButtonView: UIView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messageTextField: InsetTextField!
    
    @IBAction func rewindButton(_ sender: Any) {
        
    }
    
    @IBAction func playButton(_ sender: Any) {
        
    }
    
    @IBAction func fastForwardButton(_ sender: Any) {
        
    }
    

    @IBAction func sendButtonTapped(_ sender: Any) {
        if messageTextField.text != "" {
            messageTextField.isEnabled = false
            sendButton.isEnabled = false

            guard let content = messageTextField.text else {return}
            guard let currentUser = PFUser.current() else {return}
            guard let currentPod = self.pod else {return}
            postComment(withMessage: content, byUser: currentUser, forPod: currentPod)
            tableview.reloadData()
            self.messageTextField.text = ""
            self.messageTextField.isEnabled = true
            self.sendButton.isEnabled = true
        }
    }
    
    
    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: - Functions
    
    func fetchComments() {
        let commentsQuery = Comment.query()
        commentsQuery?.whereKey("pod", equalTo: self.pod as Any)
        commentsQuery?.includeKey("content")
        commentsQuery?.includeKey("sender")
        commentsQuery?.addAscendingOrder("createdAt")
        commentsQuery?.findObjectsInBackground(block: { (comments, error) in
            if error != nil {
                print("Error")
            } else if let comments = comments {
                self.podComments.removeAll()
                for comment in comments {
                    if let comment = comment as? Comment {
                        self.podComments.insert(comment, at: 0)
                    }
                }
                self.tableview.reloadData()
            }
        })
    }
    
    
    func postComment(withMessage message: String, byUser user: PFUser, forPod: Pod) {
        let comment = Comment()
        comment.content = message
        comment.sender = user
        comment.pod = self.pod!
        comment.saveInBackground()
    }
    
    
    func initData(forPod pod: Pod) {
        self.pod = pod
    }
    
    @objc func refreshComments() {
        self.tableview.reloadData()
        tableview.refreshControl?.endRefreshing()
    }
    
    func removeComment(atIndexPath indexPath: IndexPath) {
        let comment = podComments[indexPath.row]
        podComments.remove(at: indexPath.row)
        comment.deleteInBackground()
    }
    
}


extension PodDetailVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return podComments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommetCell", for: indexPath) as? CommentTableViewCell else { return UITableViewCell() }
        let comment = podComments[indexPath.row]
        cell.configureCell(comment: comment)
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let comment = podComments[indexPath.row]
        if comment.sender.email == PFUser.current()?.email {
            return true
        }
        else { return false }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle.none
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {  (contextualAction, view, boolValue) in
            self.removeComment(atIndexPath: indexPath)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        deleteAction.backgroundColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteAction])
        swipeActions.performsFirstActionWithFullSwipe = false
        return swipeActions
    }

}
