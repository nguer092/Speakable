//
//  CommentTableViewCell.swift
//  Speakable
//
//  Created by Nicolas Guerrero on 6/16/20.
//  Copyright © 2020 Nicolas Guerrero. All rights reserved.
//

import UIKit
import Parse

class CommentTableViewCell: UITableViewCell {

    @IBOutlet weak var commentUsernameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var commentProfilePic: UIImageView!
    
    func configureCell(comment: Comment) {
        self.commentUsernameLabel.text = comment.sender.username
        self.commentLabel.text = comment.content
        let userImageFile = comment.sender["picture"] as? PFFileObject
        userImageFile?.getDataInBackground {
            (imageData: Data?, error: Error?) -> Void in
            if error == nil {
                if let imageData = imageData {
                    let image = UIImage(data:imageData)
                    self.commentProfilePic.image = image
                }
                else {
                    print(error?.localizedDescription as Any)
                }
            }
        }
        commentProfilePic.formatImage()
    }
    

}
