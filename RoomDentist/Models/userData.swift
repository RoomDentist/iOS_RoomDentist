//
//  userData.swift
//  RoomDentist
//
//  Created by LDH on 2021/10/07.
//

import Foundation

struct userData {
    let name: String
    let emailAddress: String
    let userUid: String
    
    init(name: String, emailAddress: String, userUid: String) {
        self.name = name
        self.emailAddress = emailAddress
        self.userUid = userUid
    }
}
