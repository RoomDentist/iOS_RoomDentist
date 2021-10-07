//
//  MainViewController.swift
//  RoomDentist
//
//  Created by LDH on 2021/07/23.
//

import Firebase
import UIKit
import TextFieldEffects

class MainViewController: UIViewController {
    let storage = Storage.storage()
    var userUid: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getProfile()
        print(userUid)
    }
    
    func getProfile() {
        let user = Auth.auth().currentUser
        if let user = user {
            self.userUid = user.uid
            let email = user.email
            let photoURL = user.photoURL
        }
    }
}
