//
//  Following.swift
//  Speakable
//
//  Created by Nicolas Guerrero on 5/31/20.
//  Copyright © 2020 Nicolas Guerrero. All rights reserved.
//

import Foundation
import Parse

class Following: PFObject, PFSubclassing {
    
    static func parseClassName() -> String {
        return "Following"
    }
    @NSManaged var follower : PFUser
    @NSManaged var following: PFUser
}
