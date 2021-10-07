//
//  CharSet.swift
//  RoomDentist
//
//  Created by LDH on 2021/07/23.
//

import Foundation

// 새 캐릭터 셋 추가하기
let charSet: CharacterSet = {
    var cs = CharacterSet.letters
    cs.insert(charactersIn: "0123456789")
    cs.insert(charactersIn: "!@#$%^&*-+.")
    return cs.inverted // 캐릭터 속성을 뒤집어서 전달, 허용되지 않는 문자 검색이 더 편함
}()
