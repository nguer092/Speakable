//
//  InitialVC.swift
//  Speakable
//
//  Created by Nicolas Guerrero on 5/16/20.
//  Copyright © 2020 Nicolas Guerrero. All rights reserved.
//

import UIKit

class InitialVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpElements()
    }
    
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    
    func setUpElements(){
        Utilities.styleHollowButton(loginButton)
        Utilities.styleFilledButton(signupButton)
    }

}
