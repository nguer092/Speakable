//
//  CommentTableViewCell.swift
//  Speakable
//
//  Created by Nicolas Guerrero on 6/16/20.
//  Copyright © 2020 Nicolas Guerrero. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {

    @IBOutlet weak var commentUsernameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var commentProfilePic: UIImageView!
    
    func configureCell(profileImage: UIImage, username: String, content: String) {
        self.commentProfilePic.image = profileImage
        self.commentUsernameLabel.text = username
        self.commentLabel.text = content
    }
    

}
