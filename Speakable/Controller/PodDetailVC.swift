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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableview.delegate = self
        self.tableview.dataSource = self
        sendButtonView.bindToKeyboard()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        
        //Query for comments
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
        
        self.tableview.reloadData()
        
        //Animate to bottom of table view when sending a new message
        if self.podComments.count > 0 {
            self.tableview.scrollToRow(at: IndexPath(row: self.podComments.count - 1, section: 0), at: .none, animated: true)
        }
    }
    
    var pod : Pod?
    var podComments = [Comment]()
    @IBOutlet weak var podNameLabel: UILabel!
    @IBOutlet weak var podDescription: UILabel!
    @IBOutlet weak var podProfilePicture: UIImageView!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var sendButtonView: UIView!
    
    @IBAction func podRewind(_ sender: Any) {
        
    }
    @IBAction func playButton(_ sender: Any) {
        
    }
    @IBAction func fastForwardButton(_ sender: Any) {
        
    }
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messageTextField: InsetTextField!
    
    
    @IBAction func sendButtonTapped(_ sender: Any) {
        if messageTextField.text != "" {
            messageTextField.isEnabled = false
            sendButton.isEnabled = false
            
            guard let content = messageTextField.text else {return}
            guard let currentUser = PFUser.current() else {return}
            guard let currentPod = self.pod else {return}
            let comment = Comment()
            comment.content = content
            comment.sender = currentUser
            comment.pod = currentPod
            comment.saveInBackground()

            self.messageTextField.text = ""
            self.messageTextField.isEnabled = true
            self.sendButton.isEnabled = true
        }
    }
    
//    func postComment(withMessage message: String, forUser username: String) {
//        let comment = Comment()
//        comment.content = message
//        comment.sender = username
//        comment.pod = self.pod!
//        self.pod?.comments.append(comment)
//        comment.saveInBackground()
//        pod?.saveInBackground()
//    }
    
    
    func initData(forPod pod: Pod) {
        self.pod = pod
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
    
}
