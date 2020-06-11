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
      let error = validateFields()
        if error != nil {
            showError(error!)
        } else {
             loginUser()
        }
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func loginUser() {
        let email = emailUserTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        PFUser.logInWithUsername(inBackground: email, password: password, block: { [unowned self] (user, error) in
            if (user != nil) {
                self.transitionToHome()
            } else {
                if error != nil {
                    self.errorLabel.text = error!.localizedDescription
                    self.errorLabel.alpha = 1
                } else {
                    self.transitionToHome()
                }
            }
        })
    }
    
    func validateFields() -> String? {
        if  emailUserTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Please fill in every field"
        }
        return nil
    }
    
    func showError(_ message:String) {
        errorLabel.text = message
        errorLabel.alpha = 1
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
