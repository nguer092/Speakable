//
//  InitialVC.swift
//  Speakable
//
//  Created by Nicolas Guerrero on 5/16/20.
//  Copyright © 2020 Nicolas Guerrero. All rights reserved.
//

import UIKit
import AVKit

class InitialVC: UIViewController {
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpElements()
    }
    
    
    //MARK: - Properties, Outlets, Functions

    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    

    func setUpElements(){
        Utilities.styleHollowButton(loginButton)
        Utilities.styleFilledButton(signupButton)
    }

}
