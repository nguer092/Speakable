//
//  ResetPasswordVC.swift
//  Speakable
//
//  Created by Nicolas Guerrero on 6/11/20.
//  Copyright © 2020 Nicolas Guerrero. All rights reserved.
//

import UIKit
import Parse

class ResetPasswordVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBOutlet weak var emailTextfield: UITextField!
    
    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func sendButtonTapped(_ sender: Any) {
        if let email = emailTextfield.text {
        PFUser.requestPasswordResetForEmail(inBackground: email)
        } else {return}
    }
}
