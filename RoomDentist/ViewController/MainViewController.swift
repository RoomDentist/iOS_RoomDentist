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
    let db = Database.database().reference()
    let storage = Storage.storage().reference()
    var userData = UserModel()
    
    lazy var profileImage: UIImageView = {
        let profileImage = UIImageView()
        profileImage.layer.cornerRadius = 100
        profileImage.contentMode = .scaleAspectFill
        profileImage.layer.masksToBounds = true
        return profileImage
    }()
    
    lazy var settingImage: UIButton = {
        let settingImage = UIButton()
        settingImage.setImage(UIImage(named: "Logo.png"), for: .normal)
        return settingImage
    }()
    
    lazy var emailImageView: UIImageView = {
        let emailImageView = UIImageView()
        emailImageView.image = UIImage(named: "BlueBox.png")
        return emailImageView
    }()

    lazy var emailText: UILabel = {
        let emailText = UILabel()
        emailText.text = userData.email
        emailText.font = UIFont(name: "GmarketSansBold", size: CGFloat(15))
        return emailText
    }()
    
    lazy var userDataView: UIImageView = {
        let userDataView = UIImageView()
        userDataView.image = UIImage(named: "YellowBox.png")
        return userDataView
    }()
    
    lazy var userDataText: UILabel = {
        let userDataText = UILabel()
        userDataText.text = "\(userData.name)(\(userData.gender)) / \(userData.age)세"
        userDataText.font = UIFont(name: "GmarketSansBold", size: CGFloat(15))
        return userDataText
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getProfile()
        setImage()
        configureUI()
    }
    
    func configureUI() {
        self.view.addSubview(self.profileImage)
        self.view.addSubview(self.settingImage)
        self.view.addSubview(self.emailImageView)
        self.view.addSubview(self.emailText)
        self.view.addSubview(self.userDataView)
        self.view.addSubview(self.userDataText)
        
        self.profileImage.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(50)
            $0.height.width.size.equalTo(200)
            $0.left.equalTo(self.view.safeAreaLayoutGuide.snp.left).offset(50)
        }
        
        self.settingImage.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(30)
            $0.height.width.size.equalTo(100)
            $0.right.equalTo(self.view.safeAreaLayoutGuide.snp.right).offset(0)
        }
        
        self.emailImageView.snp.makeConstraints {
            $0.top.equalTo(self.profileImage.snp.bottom).offset(20)
            $0.right.equalTo(self.view.safeAreaLayoutGuide.snp.right).offset(-20)
        }
        
        self.emailText.snp.makeConstraints {
            $0.centerX.equalTo(self.emailImageView.snp.centerX).offset(0)
            $0.centerY.equalTo(self.emailImageView.snp.centerY).offset(-10)
        }
        
        self.userDataView.snp.makeConstraints {
            $0.top.equalTo(self.emailImageView.snp.bottom).offset(-10)
            $0.left.equalTo(self.view.safeAreaLayoutGuide.snp.left).offset(20)
        }
        
        self.userDataText.snp.makeConstraints {
            $0.centerX.equalTo(self.userDataView.snp.centerX).offset(0)
            $0.centerY.equalTo(self.userDataView.snp.centerY).offset(-10)
        }
    }
}

// MARK: 계정 설정 및 프로필사진 불러오기
extension MainViewController {
    func getProfile() {
        let user = Auth.auth().currentUser
        if let user = user {
            self.userData.uid = user.uid
            self.userData.email = user.email!
            print(self.userData)
        }
        
        db.child("users").child(userData.uid).observeSingleEvent(of: .value, with: { snapshot in
            // Get user value
            let value = snapshot.value as? NSDictionary
            self.userData.name = value?["username"] as? String ?? "홍길동"
            self.userData.gender = value?["gender"] as? String ?? "남성"
            self.userData.birth = value?["birth"] as? String ?? ""

            // MARK: 나이 계산
            let calendar = Calendar.current
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy/MM/dd"
            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            dateFormatter.locale = Locale(identifier: "ko_kr")
            let date: Date = dateFormatter.date(from: self.userData.birth)!
            let birthYear = calendar.dateComponents([.year], from: date)
        
            let nowDate = Date()
            let nowYear = calendar.dateComponents([.year], from: nowDate)
            self.userData.age = Int(nowYear.year! - birthYear.year!)
            
            self.userDataText.text = "\(self.userData.name)(\(self.userData.gender)) / \(self.userData.age)세"
          }) { error in
            print(error.localizedDescription)
          }
    }
    
    func setImage() {
        storage.child("users").child("\(userData.uid)/ProfileImage.png").downloadURL { [self] (url, error) in
            if let error = error {
                print("An error has occured: \(error.localizedDescription)")
                return
            }
            guard let url = url else {
                return
            }
            DispatchQueue.main.async {
                self.profileImage.kf.setImage(with: url)
            }
        }
    }
}
