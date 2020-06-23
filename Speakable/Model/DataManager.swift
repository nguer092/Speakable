//
//  DataManager.swift
//  Speakable
//
//  Created by Nicolas Guerrero on 6/15/20.
//  Copyright © 2020 Nicolas Guerrero. All rights reserved.
//

import Foundation
import UIKit
import Parse


class DataManager {
    static let shared = DataManager()
    var homeVC = HomeVC()
    var tabController = TabViewController()
    var pod : Pod?
    var profileVC = ProfileVC()
}


class TabViewController: UITabBarController {
    var currentUser: PFUser?
}
