//
//  EditVC.swift
//  Speakable
//
//  Created by Nicolas Guerrero on 6/15/20.
//  Copyright © 2020 Nicolas Guerrero. All rights reserved.
//

import UIKit
import Parse

class EditVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionTextfield.text = DataManager.shared.pod?.podDescription
    }
    

    @IBOutlet weak var descriptionTextfield: UITextField!
    
    @IBAction func saveButtonTapped(_ sender: Any) {
       let pod = DataManager.shared.pod
             if let desc = descriptionTextfield.text  {
                pod?.podDescription = desc
            } else {
                pod?.podDescription = "No Description"
            }
            pod?.saveInBackground {
                (success: Bool, error: Error?) in
                if (!success) {
                    print(#line, "fy===!")
                }
                self.presentingViewController?.dismiss(animated: true, completion:{
                    DataManager.shared.homeVC.tableView.reloadData()
                    DataManager.shared.profileVC.tableview.reloadData()
                } )
            }
    }
    
    
 
    
}
