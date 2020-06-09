//
//  SignupVC.swift
//  Speakable
//
//  Created by Nicolas Guerrero on 5/16/20.
//  Copyright © 2020 Nicolas Guerrero. All rights reserved.
//

import UIKit
import Parse

class SignupVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpElements()
    }
 
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
        @IBAction func signupButtonPressed(_ sender: UIButton) {
            if emailTextField.text == "" || passwordTextField.text == "" {
                    self.displayAlert(title: "Error in form", message: "Please enter an email & password")
                }
            signUpUser()
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func setUpElements(){
        errorLabel.alpha = 0
        Utilities.styleTextField(usernameTextField)
        Utilities.styleTextField(passwordTextField)
        Utilities.styleTextField(confirmPasswordTextField)
        Utilities.styleTextField(emailTextField)
        Utilities.styleFilledButton(signupButton)
    }
    
    func signUpUser() {
        let user = PFUser()
        user.username = emailTextField.text
        user.password = passwordTextField.text
        user.email = emailTextField.text
        //user["picture"] = #imageLiteral(resourceName: "circle-user-7")
        
        user.signUpInBackground {[unowned self] (succes, error) in
            if let error = error {
                self.displayAlert(title: "Error signing up", message: error.localizedDescription)
            } else {
                print("Signed up!")
                self.transitionToHome()
            }
        }
    }
    
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func transitionToHome() {
        let homeViewController = storyboard?.instantiateViewController(identifier: "TabViewController")
        view.window?.rootViewController = homeViewController
        view.window?.makeKeyAndVisible()
    }

    
    
}
