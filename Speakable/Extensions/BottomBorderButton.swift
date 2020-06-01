//
//  BottomBorderButton.swift
//  Speakable
//
//  Created by Nicolas Guerrero on 5/31/20.
//  Copyright © 2020 Nicolas Guerrero. All rights reserved.
//

import UIKit

class BottomBorderButton: UIButton {
    
    var border: CALayer?
    
    func addBottomBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x:0, y:self.frame.size.height - width, width:self.frame.size.width, height:width)
        self.layer.addSublayer(border)
        self.border = border
    }
    
    func removeBottomBorder() {
         self.border?.removeFromSuperlayer()
    }
}
