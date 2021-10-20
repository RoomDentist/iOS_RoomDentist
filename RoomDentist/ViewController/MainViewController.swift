//
//  MainViewController.swift
//  RoomDentist
//
//  Created by LDH on 2021/07/23.
//

import UIKit
import Firebase
import SafariServices
import MessageUI

class MainViewController: UIViewController {
    let db = Database.database().reference()
    let storage = Storage.storage().reference()
    var userData = UserModel()
    let identifier = "ResultCollectionView"
    var DateModels = DateModel()
    var count = 0 // 서버에서 받아오는 사진 개수
    var imageArray: [UIImage] = [UIImage(named: "RoomDentist.png")!]
    
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
//        logoImage.contentEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20);
        logoImage.translatesAutoresizingMaskIntoConstraints = true
        logoImage.semanticContentAttribute = .forceRightToLeft
        logoImage.setBackgroundImage(UIImage(named: "Logo.png"), for: .normal)
        logoImage.addTarget(self, action: #selector(logout), for: .touchUpInside)
        return logoImage
    }()
    
    lazy var calendarImage: UIButton = {
        let calendarImage = UIButton()
        calendarImage.translatesAutoresizingMaskIntoConstraints = true
        calendarImage.semanticContentAttribute = .forceRightToLeft
        calendarImage.setBackgroundImage(UIImage(named: "Calendar.png"), for: .normal)
        calendarImage.addTarget(self, action: #selector(calendarEvent), for: .touchUpInside)
        return calendarImage
    }()
    
    lazy var locationImage: UIButton = {
        let locationImage = UIButton()
        locationImage.translatesAutoresizingMaskIntoConstraints = true
        locationImage.semanticContentAttribute = .forceRightToLeft
        locationImage.setBackgroundImage(UIImage(named: "Location.png"), for: .normal)
        locationImage.addTarget(self, action: #selector(locationEvent), for: .touchUpInside)
        return locationImage
    }()
    
    lazy var userDataView: UIImageView = {
        let userDataView = UIImageView()
        userDataView.image = UIImage(named: "YellowBox.png")
        return userDataView
    }()
    
    lazy var userDataText: UILabel = {
        let userDataText = UILabel()
        userDataText.text = "\(userData.name)(\(userData.gender)) / 만 \(userData.age)세"
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
    
    lazy var noticeLabel: UILabel = {
        let noticeLabel = UILabel()
        noticeLabel.text = "사진 업로드 후 반응이 없다면\n날짜 버튼을 눌러 새로고침 하세요"
        noticeLabel.numberOfLines = 2
        noticeLabel.textAlignment = .center
        noticeLabel.textColor = .black
        noticeLabel.font = UIFont(name: "GmarketSansMedium", size: CGFloat(15))
        return noticeLabel
    }()
    
    lazy var cameraButton: UIButton = {
        let cameraButton = UIButton()
        cameraButton.layer.cornerRadius = 10
        cameraButton.backgroundColor = UIColor(named: "SignatureBlack")
        cameraButton.setTitleColor(.white, for: .normal)
        cameraButton.setTitle("구강 촬영하기", for: .normal)
        cameraButton.titleLabel?.font = UIFont(name: "GmarketSansBold", size: CGFloat(17))
        cameraButton.addTarget(self, action: #selector(cameraButtonEvent), for: .touchUpInside)
        return cameraButton
    }()
    
    lazy var photoLibraryButton: UIButton = {
        let photoLibraryButton = UIButton()
        photoLibraryButton.layer.cornerRadius = 10
        photoLibraryButton.backgroundColor = UIColor(named: "SignatureBlack")
        photoLibraryButton.setTitleColor(.white, for: .normal)
        photoLibraryButton.setTitle("앨범에서 가져오기", for: .normal)
        photoLibraryButton.titleLabel?.font = UIFont(name: "GmarketSansBold", size: CGFloat(17))
        photoLibraryButton.addTarget(self, action: #selector(photoLibraryButtonEvent), for: .touchUpInside)
        return photoLibraryButton
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
    
    // MARK: 로그아웃 및 개발자 확인 구현
    @objc func logout() {
        makeAlertDialog(title: "설정", message: "원하는 메뉴를 선택하세요")
    }
    
    // MARK: 캘린더 버튼 클릭 구현
    @objc func calendarEvent() {
        // code
    }
    
    // MARK: 지도 버튼 클릭 구현
    @objc func locationEvent() {
        let naverMapUrl = NSURL(string: "nmap://search?query=%EC%B9%98%EA%B3%BC")
        let appStoreURL = URL(string: "http://itunes.apple.com/app/id311867728?mt=8")!
        let kakaoMapUrl = NSURL(string: "kakaomap://search?q=%EC%B9%98%EA%B3%BC")
        if UIApplication.shared.canOpenURL(kakaoMapUrl! as URL) {
            UIApplication.shared.open(kakaoMapUrl! as URL)
        } else if UIApplication.shared.canOpenURL(naverMapUrl! as URL) {
            UIApplication.shared.open(naverMapUrl! as URL)
        } else {
            UIApplication.shared.open(appStoreURL)
        }
    }
    
    // MARK: 날짜 버튼 클릭 시 화면 새로고침
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
    
    @objc func photoLibraryButtonEvent() {
        print("앨범열기")
        // MARK: imagePicker 실행
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }

    // MARK: configureUI
    func configureUI() {
        self.view.addSubview(self.profileImage)
        self.view.addSubview(self.userDataView)
        self.view.addSubview(self.userDataText)
        self.view.addSubview(self.logoImage)
        self.view.addSubview(self.calendarImage)
        self.view.addSubview(self.locationImage)
        self.view.addSubview(self.dateBox)
        self.view.addSubview(self.dateBoxText)
        self.view.addSubview(self.backButton)
        self.view.addSubview(self.forwardButton)
        self.view.addSubview(self.ResultView)
        self.view.addSubview(self.noticeLabel)
        self.view.addSubview(self.cameraButton)
        self.view.addSubview(self.photoLibraryButton)
        
        self.profileImage.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(10)
            $0.height.width.size.equalTo(200)
            $0.left.equalTo(self.view.safeAreaLayoutGuide.snp.left).offset(50)
        }
        
        self.logoImage.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(0)
            $0.height.width.size.equalTo(80)
            $0.right.equalTo(self.view.safeAreaLayoutGuide.snp.right).offset(0)
        }
        
        self.calendarImage.snp.makeConstraints {
            $0.top.equalTo(self.logoImage.snp.bottom).offset(0)
            $0.height.width.size.equalTo(50)
            $0.centerX.equalTo(self.logoImage.snp.centerX)
        }
        
        self.locationImage.snp.makeConstraints {
            $0.top.equalTo(self.calendarImage.snp.bottom).offset(15)
            $0.height.width.size.equalTo(50)
            $0.centerX.equalTo(self.logoImage.snp.centerX)
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
        
        self.noticeLabel.snp.makeConstraints {
            $0.centerY.equalTo(self.ResultView.snp.centerY)
            $0.centerX.equalTo(self.ResultView.snp.centerX)
        }
        
        self.cameraButton.snp.makeConstraints {
            $0.bottom.equalTo(self.view).inset(20)
            $0.left.equalTo(self.view.safeAreaLayoutGuide.snp.left).inset(20)
            $0.width.equalTo(self.view.safeAreaLayoutGuide.snp.width).multipliedBy(0.5).offset(-25)
            $0.height.equalTo(45)
        }
        
        self.photoLibraryButton.snp.makeConstraints {
            $0.bottom.equalTo(self.view).inset(20)
            $0.right.equalTo(self.view.safeAreaLayoutGuide.snp.right).inset(20)
            $0.width.equalTo(self.view.safeAreaLayoutGuide.snp.width).multipliedBy(0.5).offset(-25) // 사이즈 계산 : 전체 화면 / 2 - 양여백 20씩 - 중간 여백 10
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
            let birthMonth = calendar.dateComponents([.month], from: date)
        
            let nowDate = Date()
            let nowYear = calendar.dateComponents([.year], from: nowDate)
            let nowMonth = calendar.dateComponents([.month], from: nowDate)
            
            if nowMonth.month! - birthMonth.month! > 0 {
                self.userData.age = Int(nowYear.year! - birthYear.year!)
            } else {
                self.userData.age = Int(nowYear.year! - birthYear.year!) - 1
            }
            
            self.userDataText.text = "\(self.userData.name)(\(self.userData.gender)) / 만 \(self.userData.age)세"
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
extension MainViewController: MFMailComposeViewControllerDelegate {
    func makeAlertDialog(title: String, message: String, _ isAlert : Bool = true) {
        // alert : 가운데에서 출력되는 Dialog. 취소/동의 같이 2개 이하를 선택할 경우 사용. 간단명료 해야함.
        let alert = isAlert ? UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        // actionSheet : 밑에서 올라오는 Dialog. 3개 이상을 선택할 경우 사용
        : UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        // destructive : title 글씨가 빨갛게 변함
        // cancel : 글자 진하게
        // defaule : X
        let alertLogoutBtn = UIAlertAction(title: "로그아웃", style: .destructive) { (action) in
            self.authlogout()
        }
        
        let alertSuccessBtn = UIAlertAction(title: "개발자 확인", style: .default) { (action) in
            let blogUrl = NSURL(string: "https://github.com/RoomDentist")
            let blogSafariView: SFSafariViewController = SFSafariViewController(url: blogUrl! as URL)
            self.present(blogSafariView, animated: true, completion: nil)
        }
        
        let alertEmailBtn = UIAlertAction(title: "문의 하기", style: .default) { (action) in
            if MFMailComposeViewController.canSendMail() {
                let compseVC = MFMailComposeViewController()
                compseVC.mailComposeDelegate = self
                compseVC.setToRecipients(["roomdentist_work@tunahouse97.com"])
                compseVC.setSubject("RoomDentist 문의하기")
                compseVC.setMessageBody("\(self.userData.email)\n", isHTML: false)
                self.present(compseVC, animated: true, completion: nil)
            }
            else {
                let sendMailErrorAlert = UIAlertController(title: "메일을 전송 실패", message: "아이폰 이메일 설정을 확인하고 다시 시도해주세요.", preferredStyle: .alert)
                let confirmAction = UIAlertAction(title: "확인", style: .default) {
                    (action) in
                    print("확인")
                }
                sendMailErrorAlert.addAction(confirmAction)
                self.present(sendMailErrorAlert, animated: true, completion: nil)
            }
        }
        
        let alertDeleteBtn = UIAlertAction(title: "취소", style: .cancel) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        
        // Dialog에 버튼 추가
        if(isAlert) {
            alert.addAction(alertLogoutBtn)
            alert.addAction(alertSuccessBtn)
            alert.addAction(alertEmailBtn)
            alert.addAction(alertDeleteBtn)
        }
        else {
            alert.addAction(alertLogoutBtn)
            alert.addAction(alertSuccessBtn)
            alert.addAction(alertEmailBtn)
            alert.addAction(alertDeleteBtn)
        }
        
        // 화면에 출력
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: 이메일 전송 에러 처리
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            controller.dismiss(animated: true, completion: nil)
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
        DataModel.checkFileMetadates(uid: userData.uid, date: DateModels.date, completion: {
            self.count = $0
            self.ResultView.reloadData()
        })
    }
}

// MARK: UICollectionViewDataSource
extension MainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("보여질 개수는? : \(self.count)")
        if self.count > 0 {
            self.noticeLabel.textColor = .clear
        } else {
            self.noticeLabel.textColor = .black
        }
        return self.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.identifier, for: indexPath) as? ResultCollectionView else { return UICollectionViewCell() }

        DataModel.downloadPhoto(uid: userData.uid, date: DateModels.date, imageCount: indexPath.row + 1) { image in
            DispatchQueue.main.async {
                cell.resultImageView.image = image
            }
        }
        
        DataModel.checkDatabase(uid: userData.uid, date: DateModels.date) { results in
            DispatchQueue.main.async {
                cell.resultLabel.text = "충치 개수 : \(results[indexPath.row].cavity)개\n\n아말감 개수 : \(results[indexPath.row].amalgam)개\n\n금니 개수 : \(results[indexPath.row].gold)개"
            }
        }
        
        return cell
    }
}

// MARK: 선택했을 때 사용하는 것
extension MainViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let VC = storyboard?.instantiateViewController(identifier: "ImageViewController") as? ImageViewController else { return }
        
        DataModel.downloadPhoto(uid: userData.uid, date: DateModels.date, imageCount: indexPath.row + 1) { image in
            DispatchQueue.main.async {
                VC.image = image
                self.navigationController?.pushViewController(VC, animated: true)
            }
        }
    }
    
}

// MARK: imagePicker Delegate
extension MainViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            DataModel.saveUserImage(date: DateModels.date, img: pickedImage, imageCount: self.count)
        } else {
            dismiss(animated: true, completion: nil)
        }
        dismiss(animated: true, completion: nil)
    }
        
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
