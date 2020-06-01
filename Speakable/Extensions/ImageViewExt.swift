//
//  ImageViewExt.swift
//  Speakable
//
//  Created by Nicolas Guerrero on 5/31/20.
//  Copyright © 2020 Nicolas Guerrero. All rights reserved.
//

import UIKit

extension UIImageView {
    func setRadius() {
        self.layer.cornerRadius = self.frame.height/2
        self.layer.masksToBounds = true
    }
}
