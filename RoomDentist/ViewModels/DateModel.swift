//
//  DateModel.swift
//  RoomDentist
//
//  Created by LDH on 2021/10/09.
//

import Foundation
import Firebase
import Kingfisher

class DateModel {
    var date: String = ""
    
    init() {
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = NSTimeZone(name: "ko_KR") as TimeZone?
        self.date = dateFormatter.string(from: now)
    }
    
    func datetToString(sender: Date) -> String {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: sender)
    }
    
    func stringToDate(sender: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.locale = Locale(identifier: "ko_kr")
        return dateFormatter.date(from: sender)!
    }
    
    func nextDate(today: Date) -> Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: today)!
    }
    
    func prevDate(today: Date) -> Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: today)!
    }
}
