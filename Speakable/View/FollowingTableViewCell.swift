//
//  FollowingTableViewCell.swift
//  Speakable
//
//  Created by Nicolas Guerrero on 5/31/20.
//  Copyright © 2020 Nicolas Guerrero. All rights reserved.
//

import UIKit
import Parse

class FollowingTableViewCell: UITableViewCell {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var usernameSearchLabel: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    
    func configureCell(user: String){
        var mutableUser = user

        let nameQuery = PFUser.query()
        nameQuery?.whereKey("objectId", equalTo: user)
        nameQuery?.includeKey("objectId")
        nameQuery?.includeKey("username")
        nameQuery?.findObjectsInBackground(block: { (objects, error) in
            for object in objects! {
                mutableUser = object["username"] as! String
                self.usernameLabel.text = mutableUser
            }
        })

    }
    
    func configureSearchCell(user: PFUser){
        self.usernameSearchLabel.text = user.username
        let userImageFile = user["picture"] as? PFFileObject
        userImageFile?.getDataInBackground(block: { (imageData, error) -> Void in
            if error == nil {
                if let imageData = imageData {
                    let image = UIImage(data: imageData)
                    self.profilePic.image = image
                }
            }
            else {
                print(error?.localizedDescription as Any)
            }
        })
        profilePic.layer.contentsGravity = CALayerContentsGravity.bottom
        profilePic.contentMode = UIView.ContentMode.scaleAspectFill
        profilePic.setRadius()
        profilePic.isUserInteractionEnabled = true
        }
        
    }
    

