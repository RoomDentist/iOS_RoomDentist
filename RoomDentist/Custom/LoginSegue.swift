//
//  LoginSegue.swift
//  RoomDentist
//
//  Created by LDH on 2021/10/07.
//

import UIKit

class LoginSegue: UIStoryboardSegue {
    override func perform (){
        let srcUVC = self.source
        let destUVC = self.destination
        
        UIView.transition(from: srcUVC.view, to: destUVC.view, duration: 0.5, options: .transitionCrossDissolve)
    }
}
