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
        storage.child(uid).child(date).child("results").child("\(fileName).png").downloadURL { (url, error) in
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
        storage.child(uid).child(date).child("results").listAll { (result, error) in
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
    
    static func checkDatabase(uid: String, date: String, completion: @escaping ([Results]) -> Void) {
        let db = Database.database().reference().child("users")
        db.child(uid).child("results").child(date).observeSingleEvent(of: .value, with: { (snapshot) in
            do {
                let data = try JSONSerialization.data(withJSONObject: snapshot.value!, options: [])
                completion(parsingData(data))
            } catch let error {
                print("---> error: \(error.localizedDescription)")
            }
        })
    }
    
    static func parsingData(_ data: Data) -> [Results] {
        let decoder = JSONDecoder()
        do {
            let response = try decoder.decode([Results].self, from: data)
            print(response)
            return response
        } catch let error {
            print("--> parsing error: \(error.localizedDescription)")
            return [Results.init()]
        }
    }
}

struct Value: Codable {
    let results: [Results]?
}

struct Results: Codable {
    let amalgam, cavity, gold: Int

    enum CodingKeys: String, CodingKey {
        case amalgam = "Amalgam"
        case cavity = "Cavity"
        case gold = "Gold"
    }
    
    init() {
        amalgam = -1
        cavity = -1
        gold = -1
    }
}
