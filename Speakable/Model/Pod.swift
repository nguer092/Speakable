//
//  Pod.swift
//  Speakable
//
//  Created by Nicolas Guerrero on 5/31/20.
//  Copyright © 2020 Nicolas Guerrero. All rights reserved.
//

import Foundation
import Parse

class Pod: PFObject, PFSubclassing {
    
    static func parseClassName() -> String {
        return "Pod"
    }
    @NSManaged var createdBy : PFUser
    @NSManaged var audio: Data
    @NSManaged var podDescription: String
    @NSManaged var listens: Int
}
