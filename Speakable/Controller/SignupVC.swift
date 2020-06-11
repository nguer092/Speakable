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
         //Validate the fields
          let error = validateFields()
          if error != nil {
              showError(error!)
          } else {
            signUpUser()
        }
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
        //Create cleaned versions of the data
        let user = PFUser()
        user.username = usernameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        user.email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        user.password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        //Create the user
        user.signUpInBackground {[unowned self] (succes, err) in
            //Check for errors
            if err != nil {
                //There was an error creating the user
                let message = err?.localizedDescription
                self.showError(message ?? "There was an error creating the user")
            } else {
                //Transition to the Home Screen
                self.transitionToHome()
            }
        }
    }
    
    func validateFields() -> String? {
        //Check the fields & validate that the data is correct. If everything is correct, this method returns nil. Otherwise, it returns an error message)
        // Check that all fields are filled in
        if  usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            confirmPasswordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Please fill in every field"
        }
        //Check that password is secure
        let cleanedPassword = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if Utilities.isPasswordValid(cleanedPassword) == false {
            //Password isn't secure enough
            return "Please make sure your password is at least 8 characters, contains a special character & contains a number"
        }
        return nil
    }
     
    func showError(_ message:String) {
        errorLabel.text = message
        errorLabel.alpha = 1
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
