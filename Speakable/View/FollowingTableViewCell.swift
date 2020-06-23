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

    @IBOutlet weak var usernameSearchLabel: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    
    
    func configureSearchCell(user: PFUser){
        user.fetchIfNeededInBackground()
        usernameSearchLabel.text = user.username
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
        profilePic.formatImage()
        }
        
    }
    

