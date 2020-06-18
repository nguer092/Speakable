//
//  Message.swift
//  Speakable
//
//  Created by Nicolas Guerrero on 6/16/20.
//  Copyright © 2020 Nicolas Guerrero. All rights reserved.
//

import Foundation
import Parse

class Comment: PFObject, PFSubclassing {
    
    static func parseClassName() -> String {
        return "Comment"
    }

@NSManaged var content: String
@NSManaged var sender: PFUser
@NSManaged var pod: Pod

}
