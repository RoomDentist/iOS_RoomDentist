//
//  DateModel.swift
//  RoomDentist
//
//  Created by LDH on 2021/10/09.
//

import Foundation
import Firebase
import UIKit
import Kingfisher

class DateModel {
    var date: String = ""
    var count: Int = 0
    
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
    
    // MARK: uid는 개인 번호, date는 다운받을 날짜 폴더, fileName: 파일 번호
    static func downloadPhoto(uid: String, date: String, fileName: String, completion: @escaping (UIImage) -> Void) {
        var resultImage = UIImageView()
        let storage = Storage.storage().reference().child("users")
        storage.child(uid).child(date).child("\(fileName).png").downloadURL { (url, error) in
            if let error = error {
                print("An error has occured: \(error.localizedDescription)")
                return
            }
            guard let url = url else {
                return
            }
            resultImage.kf.setImage(with: url)
            let settingImage = DateModel.settingImage(resultImage.image ?? UIImage(named: "RoomDentist.png")!)
            completion(settingImage)
        }
    }
    
    static func settingImage(_ with: UIImage) -> UIImage {
        return with
    }
    
    static func checkFileMetadates(uid: String, date: String, completion: @escaping (Int) -> Void) {
        let storage = Storage.storage().reference().child("users")
        storage.child(uid).child(date).listAll { (result, error) in
            if let error = error {
                print("ERROR: \(error.localizedDescription)")
                return
            }
            let items = result.items.count
            print("몇개있나요? : \(items)")
            let nums = DateModel.countItems(items)
            completion(nums)
        }
    }
    
    static func countItems(_ with: Int) -> Int {
        return with
    }
}

//func downloadPhoto(uid: String, date: String, fileName: String) -> UIImage {
//    var resultImage = UIImageView()
//    storage.child(uid).child(date).child("\(fileName).png").downloadURL { (url, error) in
//        if let error = error {
//            print("An error has occured: \(error.localizedDescription)")
//            return
//        }
//        guard let url = url else {
//            return
//        }
//        resultImage.kf.setImage(with: url)
//    }
//    return resultImage.image!
//}
//
//func checkFileMetadates(uid: String, date: String) -> Int {
//    var items = 0
//    storage.child(uid).child(date).listAll { (result, error) in
//        if let error = error {
//            print("ERROR: \(error.localizedDescription)")
//            return
//        }
//        items = result.items.count
//        print("몇개있나요? : \(items)")
//    }
//    return items
//}
