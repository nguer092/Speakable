//
//  LoginVC.swift
//  Speakable
//
//  Created by Nicolas Guerrero on 5/16/20.
//  Copyright © 2020 Nicolas Guerrero. All rights reserved.
//

import UIKit
import Parse

class LoginVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpElements()
    }
    
    @IBOutlet weak var emailUserTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBAction func lgnupButtonPressed(_ sender: UIButton) {
        if emailUserTextField.text == "" || passwordTextField.text == "" {
            self.displayAlert(title: "Error in form", message: "Please enter an email & password")
        }
        loginUser()
    }
    
    
    func loginUser() {
        
        PFUser.logInWithUsername(inBackground: emailUserTextField.text!, password: passwordTextField.text!, block: { [unowned self] (user, error) in
            if (user != nil) {
                print("Login successfull")
                self.transitionToHome()
            } else {
                var errorText = "Unknwon error: Please try again"
                if let error = error {
                    errorText = error.localizedDescription
                }
                self.displayAlert(title: "Something went wrong", message: errorText)
            }
        })
    }
    
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func setUpElements(){
        errorLabel.alpha = 0
        Utilities.styleTextField(emailUserTextField)
        Utilities.styleTextField(passwordTextField)
        Utilities.styleFilledButton(loginButton)
    }
    
    func transitionToHome() {
        let homeViewController = storyboard?.instantiateViewController(identifier: "TabViewController")
        view.window?.rootViewController = homeViewController
        view.window?.makeKeyAndVisible()
    }
}
