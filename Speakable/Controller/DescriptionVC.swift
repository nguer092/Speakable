//
//  DescriptionVC.swift
//  Speakable
//
//  Created by Nicolas Guerrero on 5/31/20.
//  Copyright © 2020 Nicolas Guerrero. All rights reserved.
//

import UIKit

class DescriptionVC: UIViewController {
    
    @IBOutlet weak var descriptionText: UITextView!
    
    var completion:((String) -> ())!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        self.completion(descriptionText.text)
        dismiss(animated: true, completion: nil)
    }
    
}
