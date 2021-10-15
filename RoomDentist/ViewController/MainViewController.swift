//
//  MainViewController.swift
//  RoomDentist
//
//  Created by LDH on 2021/07/23.
//

import UIKit
import Firebase
import SafariServices

class MainViewController: UIViewController {
    let db = Database.database().reference()
    let storage = Storage.storage().reference()
    var userData = UserModel()
    let identifier = "ResultCollectionView"
    var DateModels = DateModel()
    var count = 0 // 서버에서 받아오는 사진 개수
    
    @IBOutlet weak var circleImage: UIImageView!
    lazy var profileImage: UIImageView = {
        let profileImage = UIImageView()
        profileImage.layer.cornerRadius = 100
        profileImage.contentMode = .scaleAspectFill
        profileImage.layer.masksToBounds = true
        return profileImage
    }()
    
    lazy var logoImage: UIButton = {
        let logoImage = UIButton()
        logoImage.contentEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20);
        logoImage.translatesAutoresizingMaskIntoConstraints = true
        logoImage.semanticContentAttribute = .forceRightToLeft
//        logoImage.adjustsImageWhenHighlighted = false
        logoImage.setBackgroundImage(UIImage(named: "Logo.png"), for: .normal)
        logoImage.addTarget(self, action: #selector(logout), for: .touchUpInside)
        return logoImage
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
    
    lazy var dateBox: UIButton = {
        let dateBox = UIButton()
        dateBox.translatesAutoresizingMaskIntoConstraints = true
        dateBox.setBackgroundImage(UIImage(named: "BlueBox.png"), for: .normal)
        dateBox.addTarget(self, action: #selector(refresh), for: .touchUpInside)
        return dateBox
    }()
    
    lazy var dateBoxText: UILabel = {
        let dateBoxText = UILabel()
        dateBoxText.text = DateModels.date
        dateBoxText.font = UIFont(name: "GmarketSansBold", size: CGFloat(15))
        return dateBoxText
    }()
    
    lazy var backButton: UIButton = {
        let backButton = UIButton()
        backButton.setBackgroundImage(UIImage(named: "backward.circle.fill"), for: .normal)
        backButton.addTarget(self, action: #selector(backButtonEvent), for: .touchUpInside)
        return backButton
    }()
    
    lazy var forwardButton: UIButton = {
        let forwardButton = UIButton()
        forwardButton.setBackgroundImage(UIImage(named: "forward.circle.fill"), for: .normal)
        forwardButton.addTarget(self, action: #selector(forwardButtonEvent), for: .touchUpInside)
        return forwardButton
    }()
    
    lazy var ResultView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let size: CGSize = UIScreen.main.bounds.size
        layout.itemSize = CGSize(width: size.width - 40, height: 200)
        layout.minimumLineSpacing = 10
        layout.scrollDirection = .vertical
        layout.sectionFootersPinToVisibleBounds = true
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.view.addSubview(collectionView)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = false
        collectionView.backgroundColor = .clear
        collectionView.register(ResultCollectionView.self, forCellWithReuseIdentifier: self.identifier)
        return collectionView
      }()
    
    lazy var cameraButton: UIButton = {
        let cameraButton = UIButton()
        cameraButton.layer.cornerRadius = 10
        cameraButton.backgroundColor = UIColor(named: "SignatureBlack")
        cameraButton.setTitleColor(.white, for: .normal)
        cameraButton.setTitle("구강 검사하기", for: .normal)
        cameraButton.titleLabel?.font = UIFont(name: "GmarketSansBold", size: CGFloat(17))
        cameraButton.addTarget(self, action: #selector(cameraButtonEvent), for: .touchUpInside)
        return cameraButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getProfile()
        setImage()
        refreshCount()
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        refreshCount()
    }
    
    // MARK: 로그아웃 구현
    @objc func logout() {
        makeAlertDialog(title: "설정", message: "원하는 메뉴를 선택하세요")
    }
    
    @objc func refresh() {
        refreshCount()
    }
    
    // MARK: 버튼 기능 구현
    @objc func backButtonEvent() {
        print("뒤로")
        var update = DateModels.stringToDate(sender: DateModels.date)
        update = DateModels.prevDate(today: update)
        let result = DateModels.datetToString(sender: update)
        DateModels.date = result
        dateBoxText.text = result
//        self.count = DateModel.checkFileMetadates(uid: userData.uid, date: DateModels.date)
        refreshCount()
    }
    
    @objc func forwardButtonEvent() {
        print("앞으로")
        var update = DateModels.stringToDate(sender: DateModels.date)
        update = DateModels.nextDate(today: update)
        let result = DateModels.datetToString(sender: update)
        DateModels.date = result
        dateBoxText.text = result
        refreshCount()
    }
    
    @objc func cameraButtonEvent() {
        print("캡쳐")
        let pushVC = self.storyboard?.instantiateViewController(withIdentifier: "CameraViewController")
        self.navigationController?.pushViewController(pushVC!, animated: true)
    }

    // MARK: configureUI
    func configureUI() {
        self.view.addSubview(self.profileImage)
        self.view.addSubview(self.userDataView)
        self.view.addSubview(self.userDataText)
        self.view.addSubview(self.logoImage)
        self.view.addSubview(self.dateBox)
        self.view.addSubview(self.dateBoxText)
        self.view.addSubview(self.backButton)
        self.view.addSubview(self.forwardButton)
        self.view.addSubview(self.ResultView)
        self.view.addSubview(self.cameraButton)
        
        self.profileImage.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(10)
            $0.height.width.size.equalTo(200)
            $0.left.equalTo(self.view.safeAreaLayoutGuide.snp.left).offset(50)
        }
        
        self.logoImage.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(0)
            $0.height.width.size.equalTo(100)
            $0.right.equalTo(self.view.safeAreaLayoutGuide.snp.right).offset(0)
        }
        
        self.userDataView.snp.makeConstraints {
            $0.top.equalTo(self.profileImage.snp.bottom).offset(20)
            $0.left.equalTo(self.view.safeAreaLayoutGuide.snp.left).offset(20)
        }
        
        self.userDataText.snp.makeConstraints {
            $0.centerX.equalTo(self.userDataView.snp.centerX).offset(0)
            $0.centerY.equalTo(self.userDataView.snp.centerY).offset(-10)
        }
        
        self.dateBox.snp.makeConstraints {
            $0.top.equalTo(self.userDataView.snp.bottom).offset(-10)
            $0.centerX.equalTo(self.view.safeAreaLayoutGuide.snp.centerX).offset(0)
        }
        
        self.dateBoxText.snp.makeConstraints {
            $0.centerX.equalTo(self.dateBox.snp.centerX).offset(0)
            $0.centerY.equalTo(self.dateBox.snp.centerY).offset(-10)
        }
        
        self.backButton.snp.makeConstraints {
            $0.left.equalTo(self.view.safeAreaLayoutGuide.snp.left).offset(20)
            $0.centerY.equalTo(self.dateBox.snp.centerY).offset(-10)
        }
        
        self.forwardButton.snp.makeConstraints {
            $0.right.equalTo(self.view.safeAreaLayoutGuide.snp.right).offset(-20)
            $0.centerY.equalTo(self.dateBox.snp.centerY).offset(-10)
        }
        
        self.ResultView.snp.makeConstraints {
            $0.left.right.equalTo(0)
            $0.top.equalTo(self.dateBox.snp.bottom).offset(-10)
            $0.bottom.equalTo(self.cameraButton.snp.top).offset(-10)
        }
        
        self.cameraButton.snp.makeConstraints {
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(0)
            $0.centerX.equalTo(self.view.safeAreaLayoutGuide.snp.centerX)
            $0.left.equalTo(self.view.safeAreaLayoutGuide.snp.left).offset(20)
            $0.right.equalTo(self.view.safeAreaLayoutGuide.snp.right).offset(-20)
            $0.height.equalTo(45)
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

// MARK: Alert Dialog 생성
extension MainViewController {
    func makeAlertDialog(title: String, message: String, _ isAlert : Bool = true) {
        // alert : 가운데에서 출력되는 Dialog. 취소/동의 같이 2개 이하를 선택할 경우 사용. 간단명료 해야함.
        let alert = isAlert ? UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        // actionSheet : 밑에서 올라오는 Dialog. 3개 이상을 선택할 경우 사용
        : UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        // destructive : title 글씨가 빨갛게 변함
        // cancel : 글자 진하게
        // defaule : X
        let alertLogoutBtn = UIAlertAction(title: "로그아웃", style: .destructive) { (action) in
            print("[SUCCESS] Dialog Success Button Click!")
            self.authlogout()
        }
        
        let alertSuccessBtn = UIAlertAction(title: "개발자 확인", style: .default) { (action) in
            print("[SUCCESS] Dialog Success Button Click!")
            let blogUrl = NSURL(string: "https://github.com/RoomDentist")
            let blogSafariView: SFSafariViewController = SFSafariViewController(url: blogUrl as! URL)
            self.present(blogSafariView, animated: true, completion: nil)
        }
        
        let alertDeleteBtn = UIAlertAction(title: "취소", style: .cancel) { (action) in
            print("[SUCCESS] Dialog Cancel Button Click!")
            self.dismiss(animated: true)
        }
        
        // Dialog에 버튼 추가
        if(isAlert) {
            alert.addAction(alertLogoutBtn)
            alert.addAction(alertSuccessBtn)
            alert.addAction(alertDeleteBtn)
        }
        else {
            alert.addAction(alertLogoutBtn)
            alert.addAction(alertSuccessBtn)
            alert.addAction(alertDeleteBtn)
        }
        
        // 화면에 출력
        self.present(alert, animated: true, completion: nil)
    }
}

extension MainViewController {
    func authlogout() {
        do {
            try Auth.auth().signOut()
        } catch let error {
            print("Error: ", error.localizedDescription)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    func refreshCount() {
        DateModel.checkFileMetadates(uid: userData.uid, date: DateModels.date, completion: {
            self.count = $0
            self.ResultView.reloadData()
        })
    }
}

extension MainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("보여질 개수는? : \(self.count)")
        return self.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.identifier, for: indexPath) as? ResultCollectionView else { return UICollectionViewCell() }
    
//        cell.resultImageView.image = DateModels.downloadPhoto(uid: userData.uid, date: DateModels.date, fileName: "19")
        DateModel.downloadPhoto(uid: userData.uid, date: DateModels.date, fileName: "\(indexPath.row + 1)") { image in
            DispatchQueue.main.async {
                cell.resultImageView.image = image
            }
        }
        
        DateModel.checkDatabase(uid: userData.uid, date: DateModels.date) { results in
            DispatchQueue.main.async {
                cell.resultLabel.text = "충치 개수 : \(results[indexPath.row].cavity)개\n아말감 개수 : \(results[indexPath.row].amalgam)개\n금니 개수 : \(results[indexPath.row].gold)개"
            }
        }
        
        return cell
    }
}

extension MainViewController: UICollectionViewDelegate {
    // 선택했을 때 사용하는 것
}
