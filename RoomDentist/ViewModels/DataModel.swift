//
//  DataModels.swift
//  RoomDentist
//
//  Created by LDH on 2021/10/15.
//

import Foundation
import Firebase
import Kingfisher
import Alamofire

class DataModel {
    var date: String = ""
    var count: Int = 0
    static let storage = Storage.storage().reference().child("users")
    
    // MARK: Firebase Storage에서 결과 이미지 다운로드, uid는 개인 번호, date는 다운받을 날짜 폴더, fileName: 파일 번호
    static func downloadPhoto(uid: String, date: String, imageCount: Int, completion: @escaping (UIImage) -> Void) {
        var resultImage = UIImageView()
        storage.child(uid).child(date).child("results").child("\(imageCount).png").downloadURL { (url, error) in
            if let error = error {
                print("An error has occured: \(error.localizedDescription)")
                return
            }
            guard let url = url else {
                return
            }
            resultImage.kf.setImage(with: url)
            let settingImage = DataModel.settingImage(resultImage.image ?? UIImage(named: "RoomDentist.png")!)
            completion(settingImage)
        }
    }
    
    static func settingImage(_ with: UIImage) -> UIImage {
        return with
    }
    
    // MARK: Firebase Storage 이미지 개수 확인
    static func checkFileMetadates(uid: String, date: String, completion: @escaping (Int) -> Void) {
        storage.child(uid).child(date).child("results").listAll { (result, error) in
            if let error = error {
                print("ERROR: \(error.localizedDescription)")
                return
            }
            let items = result.items.count
            print("몇개있나요? : \(items)")
            let nums = DataModel.countItems(items)
            completion(nums)
        }
    }
    
    static func countItems(_ with: Int) -> Int {
        return with
    }
    
    // MARK: Firebase Realtime Database 값 확인
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
            return response
        } catch let error {
            print("--> parsing error: \(error.localizedDescription)")
            return [Results.init()]
        }
    }
    
    // MARK: 이미지 Firebase Storage 업로드
    static func saveUserImage(date: String, img: UIImage, imageCount: Int, isCavity: Bool) {
        var data = Data()
        data = img.jpegData(compressionQuality: 1)!
        let filePath = Auth.auth().currentUser?.uid
        let metaData = StorageMetadata()
        metaData.contentType = "image/png"
        print("[카메라뷰] 저장 전 이미지 개수는? : \(imageCount)")
        storage.child(filePath!).child("\(date)").child("\(imageCount + 1).png").putData(data, metadata: metaData) { (metaData, error) in if let error = error {
                print(error.localizedDescription)
                return
            } else {
                print("[카메라뷰] 업로드 성공")
                DataModel.postData(uid: "\(filePath!)", imageCount: imageCount + 1, isCavity: isCavity)
            }
        }
    }
    
    // MARK: uid, imageCount Flask 서버로 전송
    static func postData(uid: String, imageCount: Int, isCavity: Bool) {
        print("테스트 보내기 : \(isCavity)")
        let url = "https://roomdentist.tunahouse97.com/Auth"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 10
        
        // POST 로 보낼 정보
        let params = ["uid": "\(uid)", "numbers": "\(imageCount)", "isCavity": "\(isCavity)"] as Dictionary

        // httpBody 에 parameters 추가
        do {
            try request.httpBody = JSONSerialization.data(withJSONObject: params, options: [])
        } catch {
            print("http Body Error")
        }
        
        AF.request(request).responseString { (response) in
            switch response.result {
            case .success:
                print("POST 성공")
            case .failure(let error):
                print("🚫 Alamofire Request Error\nCode:\(error._code), Message: \(error.errorDescription!)")
            }
        }
    }
}

struct Results: Codable {
    let amalgam, cavity, gold: Int
    let isCavity: String

    enum CodingKeys: String, CodingKey {
        case amalgam = "Amalgam"
        case cavity = "Cavity"
        case gold = "Gold"
        case isCavity
    }
    
    init() {
        amalgam = -1
        cavity = -1
        gold = -1
        isCavity = ""
    }
}
