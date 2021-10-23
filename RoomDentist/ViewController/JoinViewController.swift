//
//  JoinViewController.swift
//  RoomDentist
//
//  Created by LDH on 2021/07/23.
//

import UIKit
import Firebase
import SafariServices
import SwiftUI

class JoinViewController: UIViewController {
    
    let db = Database.database().reference()
    let storage = Storage.storage().reference().child("users")
    var checkJoinParam: Bool = false
    var checkButtonParam: Bool = false
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()
    
    lazy var innerView: UIView = {
        let innerView = UIView()
        return innerView
    }()
    
    lazy var profileImage: UIImage = {
        let profileImage = UIImage()
        return profileImage
    }()
    
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = "방구석 Dentist 회원가입"
        titleLabel.textColor = UIColor(named: "Brown")!
        titleLabel.font = UIFont(name: "GmarketSansBold", size: CGFloat(17))
        return titleLabel
    }()
    
    // MARK: 회원 가입 필수 정보 구현
    lazy var NameTextBox: UIImageView = {
        let EmailTextBox = UIImageView()
        EmailTextBox.image = UIImage(named: "Box.png")
        return EmailTextBox
    }()
    
    lazy var NameTextField: UITextField = {
        let NameTextField = UITextField()
        NameTextField.placeholder = "이름"
        NameTextField.setPlaceholderColor(UIColor(named: "Brown")!)
        NameTextField.textColor = UIColor(named: "Brown")!
        NameTextField.font = UIFont(name: "GmarketSansBold", size: CGFloat(17))
        NameTextField.autocapitalizationType = .none
        NameTextField.autocorrectionType = .no
        NameTextField.delegate = self
        return NameTextField
    }()
    
    lazy var EmailTextBox: UIImageView = {
        let EmailTextBox = UIImageView()
        EmailTextBox.image = UIImage(named: "Box.png")
        return EmailTextBox
    }()
    
    lazy var EmailTextField: UITextField = {
        let EmailTextField = UITextField()
        EmailTextField.placeholder = "Email"
        EmailTextField.setPlaceholderColor(UIColor(named: "Brown")!)
        EmailTextField.keyboardType = .emailAddress
        EmailTextField.textColor = UIColor(named: "Brown")!
        EmailTextField.font = UIFont(name: "GmarketSansBold", size: CGFloat(17))
        EmailTextField.autocapitalizationType = .none
        EmailTextField.autocorrectionType = .no
        EmailTextField.delegate = self
        return EmailTextField
    }()
    
    lazy var SendEmailButton: UIButton = {
        let SendEmailButton = UIButton()
        SendEmailButton.isEnabled = false
        SendEmailButton.setTitleColor(UIColor(named: "Brown"), for: .normal)
        SendEmailButton.setTitle("이메일 인증", for: .normal)
        SendEmailButton.titleLabel?.font = UIFont(name: "GmarketSansMedium", size: CGFloat(13))
        SendEmailButton.addTarget(self, action: #selector(sendEmailCheck), for: .touchUpInside)
        return SendEmailButton
    }()
    
    lazy var PwTextBox: UIImageView = {
        let EmailTextBox = UIImageView()
        EmailTextBox.image = UIImage(named: "Box.png")
        return EmailTextBox
    }()
    
    lazy var PwTextField: UITextField = {
        let PwTextField = UITextField()
        PwTextField.placeholder = "비밀번호"
        PwTextField.setPlaceholderColor(UIColor(named: "Brown")!)
        PwTextField.textColor = UIColor(named: "Brown")!
        PwTextField.font = UIFont(name: "GmarketSansBold", size: CGFloat(17))
        PwTextField.autocapitalizationType = .none
        PwTextField.autocorrectionType = .no
        PwTextField.isSecureTextEntry = true
        PwTextField.delegate = self
        return PwTextField
    }()
    
    lazy var PwTextRepeatBox: UIImageView = {
        let EmailTextBox = UIImageView()
        EmailTextBox.image = UIImage(named: "Box.png")
        return EmailTextBox
    }()
    
    lazy var PwTextFieldRepeat: UITextField = {
        let PwTextFieldRepeat = UITextField()
        PwTextFieldRepeat.placeholder = "비밀번호 재입력"
        PwTextFieldRepeat.setPlaceholderColor(UIColor(named: "Brown")!)
        PwTextFieldRepeat.textColor = UIColor(named: "Brown")!
        PwTextFieldRepeat.font = UIFont(name: "GmarketSansBold", size: CGFloat(17))
        PwTextFieldRepeat.autocapitalizationType = .none
        PwTextFieldRepeat.autocorrectionType = .no
        PwTextFieldRepeat.isSecureTextEntry = true
        PwTextFieldRepeat.delegate = self
        return PwTextFieldRepeat
    }()
    
    lazy var BirthText: UILabel = {
        let BirthText = UILabel()
        BirthText.text = "생일"
        BirthText.textColor = UIColor(named: "Brown")!
        BirthText.font = UIFont(name: "GmarketSansBold", size: CGFloat(17))
        return BirthText
    }()
    
    lazy var BirthTextField: UITextField = {
        let BirthTextField = UITextField()
        BirthTextField.text = ""
        return BirthTextField
    }()
    
    lazy var genderText: UILabel = {
        let genderText = UILabel()
        genderText.text = "성별"
        genderText.textColor = UIColor(named: "Brown")!
        genderText.font = UIFont(name: "GmarketSansBold", size: CGFloat(17))
        return genderText
    }()
    
    lazy var genderTextField: UITextField = {
        let genderTextField = UITextField()
        genderTextField.text = "남성"
        return genderTextField
    }()
    
    lazy var genderSegment: UISegmentedControl = {
        var genderSegment = UISegmentedControl()
        let items = ["남성", "여성"]
        genderSegment = UISegmentedControl(items: items)
        genderSegment.translatesAutoresizingMaskIntoConstraints = false
        genderSegment.selectedSegmentTintColor = .systemOrange
        return genderSegment
    }()
    
    lazy var BirthTextFieldPicker: UIDatePicker = {
        let BirthTextFieldPicker = UIDatePicker()
        BirthTextFieldPicker.datePickerMode = .date
        BirthTextFieldPicker.timeZone = NSTimeZone.local
        BirthTextFieldPicker.locale = Locale(identifier: "ko_KR")
        BirthTextFieldPicker.layer.cornerRadius = 10
        BirthTextFieldPicker.addTarget(self, action: #selector(onDidChangeDate(sender:)), for: .valueChanged)
        return BirthTextFieldPicker
    }()
    
    lazy var PwLabel: UILabel = {
        let PwLabel = UILabel()
        PwLabel.text = "비밀번호가 일치하지 않습니다"
        PwLabel.textColor = .systemRed
        PwLabel.font = UIFont(name: "GmarketSansMedium", size: CGFloat(13))
        return PwLabel
    }()
    
    // MARK: 약관 구현
    lazy var termsofUseButton: UIButton = {
        let termsofUseButton = UIButton()
        termsofUseButton.setBackgroundImage(UIImage(systemName: "checkmark.square"), for: .normal)
        termsofUseButton.setBackgroundImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
        termsofUseButton.tintColor = UIColor(named: "RoomYellow")
        termsofUseButton.addTarget(self, action: #selector(BtnEvent), for: .touchUpInside)
        return termsofUseButton
    }()
    
    lazy var termsofUseLabel: UIButton = {
        let termsofUseLabel = UIButton()
        termsofUseLabel.setTitle("서비스 이용약관 동의 (필수)", for: .normal)
        termsofUseLabel.setTitleColor(UIColor(named: "Brown"), for: .normal)
        termsofUseLabel.addTarget(self, action: #selector(termsofUseUrl), for: .touchUpInside)
        termsofUseLabel.titleLabel?.font = UIFont(name: "GmarketSansMedium", size: CGFloat(17))
        return termsofUseLabel
    }()
    
    lazy var privacyPolicyButton: UIButton = {
        let privacyPolicyButton = UIButton()
        privacyPolicyButton.setBackgroundImage(UIImage(systemName: "checkmark.square"), for: .normal)
        privacyPolicyButton.setBackgroundImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
        privacyPolicyButton.tintColor = UIColor(named: "RoomYellow")
        privacyPolicyButton.addTarget(self, action: #selector(BtnEvent), for: .touchUpInside)
        return privacyPolicyButton
    }()
    
    lazy var privacyPolicyLabel: UIButton = {
        let privacyPolicyLabel = UIButton()
        privacyPolicyLabel.setTitle("개인정보 수집 및 이용 동의 (필수)", for: .normal)
        privacyPolicyLabel.setTitleColor(UIColor(named: "Brown"), for: .normal)
        privacyPolicyLabel.titleLabel?.font = UIFont(name: "GmarketSansMedium", size: CGFloat(17))
        privacyPolicyLabel.addTarget(self, action: #selector(privacyPolicyUrl), for: .touchUpInside)
        return privacyPolicyLabel
    }()
    
    lazy var overAgeButton: UIButton = {
        let overAgeButton = UIButton()
        overAgeButton.setBackgroundImage(UIImage(systemName: "checkmark.square"), for: .normal)
        overAgeButton.setBackgroundImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
        overAgeButton.tintColor = UIColor(named: "RoomYellow")
        overAgeButton.addTarget(self, action: #selector(BtnEvent), for: .touchUpInside)
        return overAgeButton
    }()
    
    lazy var overAgeLabel: UIButton = {
        let overAgeLabel = UIButton()
        overAgeLabel.setTitle("만 14세 이상입니다 (필수)", for: .normal)
        overAgeLabel.setTitleColor(UIColor(named: "Brown"), for: .normal)
        overAgeLabel.titleLabel?.font = UIFont(name: "GmarketSansMedium", size: CGFloat(17))
        return overAgeLabel
    }()
    
    // MARK: 프로필 사진 업로드 및 회원 가입 버튼 구현
    lazy var profileButton: UIButton = {
        let profileButton = UIButton()
        profileButton.layer.cornerRadius = 10
        profileButton.setTitle("프로필 사진 가져오기", for: .normal)
        profileButton.isEnabled = true
        profileButton.backgroundColor = .systemYellow
        profileButton.setTitleColor(.white, for: .normal)
        profileButton.titleLabel?.font = UIFont(name: "GmarketSansBold", size: CGFloat(17))
        profileButton.addTarget(self, action: #selector(uploadPhoto), for: .touchUpInside)
        return profileButton
    }()
    
    lazy var joinButton: UIButton = {
        let joinButton = UIButton()
        joinButton.layer.cornerRadius = 10
        joinButton.setTitle("회원가입", for: .normal)
        joinButton.isEnabled = false
        joinButton.backgroundColor = .systemGray6
        joinButton.setTitleColor(.systemGray, for: .disabled)
        joinButton.setTitleColor(.white, for: .normal)
        joinButton.titleLabel?.font = UIFont(name: "GmarketSansBold", size: CGFloat(17))
        joinButton.addTarget(self, action: #selector(createUser), for: .touchUpInside)
        return joinButton
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func createUser() {
        checkSign()
    }
    
    @objc func termsofUseUrl() {
        let Url = NSURL(string: "https://tunahouse97.notion.site/RoomDentist-c9736ff77a234c1d984b4bb25d4ef57e")
        let safariView: SFSafariViewController = SFSafariViewController(url: Url! as URL)
        self.present(safariView, animated: true, completion: nil)
    }
    
    @objc func privacyPolicyUrl() {
        let Url = NSURL(string: "https://tunahouse97.notion.site/RoomDentist-23d1a9e7655e41a99ac94dcc74d97ac9")
        let safariView: SFSafariViewController = SFSafariViewController(url: Url! as URL)
        self.present(safariView, animated: true, completion: nil)
    }
    
    @objc func BtnEvent(_ sender: UIButton) {
        sender.isSelected.toggle()
        if termsofUseButton.isSelected && privacyPolicyButton.isSelected && overAgeButton.isSelected {
            checkButtonParam = true
        } else {
            checkButtonParam = false
        }
    }
    
    func configureUI() {
        view.addSubview(self.scrollView)
        scrollView.addSubview(self.innerView)
        
        self.innerView.addSubview(self.titleLabel)
        
        self.innerView.addSubview(self.NameTextBox)
        self.innerView.addSubview(self.NameTextField)
        self.innerView.addSubview(self.EmailTextBox)
        self.innerView.addSubview(self.EmailTextField)
        self.innerView.addSubview(self.SendEmailButton)
        self.innerView.addSubview(self.PwTextBox)
        self.innerView.addSubview(self.PwTextField)
        self.innerView.addSubview(self.PwTextRepeatBox)
        self.innerView.addSubview(self.PwTextFieldRepeat)
        self.innerView.addSubview(self.PwLabel)
        self.innerView.addSubview(self.BirthText)
        self.innerView.addSubview(self.BirthTextFieldPicker)
        self.innerView.addSubview(self.genderText)
        self.innerView.addSubview(self.genderSegment)
        
        self.innerView.addSubview(self.termsofUseButton)
        self.innerView.addSubview(self.termsofUseLabel)
        self.innerView.addSubview(self.privacyPolicyButton)
        self.innerView.addSubview(self.privacyPolicyLabel)
        self.innerView.addSubview(self.overAgeButton)
        self.innerView.addSubview(self.overAgeLabel)
        
        self.innerView.addSubview(self.profileButton)
        self.innerView.addSubview(self.joinButton)
        
        self.scrollView.snp.makeConstraints {
            $0.top.left.right.bottom.equalTo(self.view)
        }
        
        self.innerView.snp.makeConstraints {
            $0.top.left.right.bottom.equalTo(self.scrollView)
            $0.height.equalTo(self.NameTextBox.snp.height).multipliedBy(12)
            $0.width.equalTo(self.scrollView)
        }
        
        self.titleLabel.snp.makeConstraints {
            $0.top.equalTo(self.scrollView.snp.top).offset(20)
            $0.centerX.equalTo(self.innerView.snp.centerX)
        }
        
        self.NameTextBox.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.centerX.equalTo(self.innerView.snp.centerX)
            $0.left.equalTo(self.innerView.snp.left).inset(20)
            $0.right.equalTo(self.innerView.snp.right).inset(20)
        }
        
        self.NameTextField.snp.makeConstraints {
            $0.centerX.equalTo(self.NameTextBox.snp.centerX)
            $0.centerY.equalTo(self.NameTextBox.snp.centerY)
            $0.left.equalTo(self.innerView.snp.left).inset(40)
            $0.right.equalTo(self.innerView.snp.right).inset(40)
        }
        
        self.EmailTextBox.snp.makeConstraints {
            $0.top.equalTo(NameTextBox.snp.bottom).offset(10)
            $0.centerX.equalTo(self.innerView.snp.centerX)
            $0.left.equalTo(self.innerView.snp.left).inset(20)
            $0.right.equalTo(self.innerView.snp.right).inset(20)
            $0.height.equalTo(60)
        }
        
        self.EmailTextField.snp.makeConstraints {
            $0.centerX.equalTo(self.EmailTextBox.snp.centerX)
            $0.centerY.equalTo(self.EmailTextBox.snp.centerY)
            $0.left.equalTo(self.innerView.snp.left).inset(40)
            $0.right.equalTo(self.innerView.snp.right).inset(40)
        }
        
        self.SendEmailButton.snp.makeConstraints {
            $0.top.equalTo(self.EmailTextBox.snp.bottom).offset(10)
            $0.right.equalTo(self.innerView.snp.right).inset(20)
        }
        
        self.PwTextBox.snp.makeConstraints {
            $0.top.equalTo(self.SendEmailButton.snp.bottom).offset(10)
            $0.centerX.equalTo(self.innerView.snp.centerX)
            $0.left.equalTo(self.innerView.snp.left).inset(20)
            $0.right.equalTo(self.innerView.snp.right).inset(20)
        }

        self.PwTextField.snp.makeConstraints {
            $0.centerX.equalTo(self.PwTextBox.snp.centerX)
            $0.centerY.equalTo(self.PwTextBox.snp.centerY)
            $0.left.equalTo(self.innerView.snp.left).inset(40)
            $0.right.equalTo(self.innerView.snp.right).inset(40)
        }
        
        self.PwTextRepeatBox.snp.makeConstraints {
            $0.top.equalTo(PwTextBox.snp.bottom).offset(10)
            $0.centerX.equalTo(self.innerView.snp.centerX)
            $0.left.equalTo(self.innerView.snp.left).inset(20)
            $0.right.equalTo(self.innerView.snp.right).inset(20)
        }
        
        self.PwTextFieldRepeat.snp.makeConstraints {
            $0.centerX.equalTo(self.PwTextRepeatBox.snp.centerX)
            $0.centerY.equalTo(self.PwTextRepeatBox.snp.centerY)
            $0.left.equalTo(self.innerView.snp.left).inset(40)
            $0.right.equalTo(self.innerView.snp.right).inset(40)
        }
        
        self.PwLabel.snp.makeConstraints {
            $0.top.equalTo(self.PwTextRepeatBox.snp.bottom).offset(10)
            $0.right.equalTo(self.innerView.snp.right).offset(-20)
        }
        
        self.BirthText.snp.makeConstraints {
            $0.top.equalTo(self.PwLabel.snp.bottom).offset(20)
            $0.left.equalTo(self.innerView.snp.left).offset(20)
            $0.right.equalTo(self.BirthTextFieldPicker.snp.left).offset(-20)
        }
        
        self.BirthTextFieldPicker.snp.makeConstraints {
            $0.top.equalTo(self.PwLabel.snp.bottom).offset(13)
            $0.left.equalTo(self.BirthText.snp.right).offset(20)
        }
        
        self.genderText.snp.makeConstraints {
            $0.top.equalTo(self.PwLabel.snp.bottom).offset(20)
            $0.left.equalTo(self.BirthTextFieldPicker.snp.right).offset(20)
            $0.right.equalTo(self.genderSegment.snp.left).offset(-20)
        }
        
        self.genderSegment.snp.makeConstraints {
            $0.top.equalTo(self.PwLabel.snp.bottom).offset(13)
            $0.left.equalTo(self.genderText.snp.right).offset(20)
        }
        
        // MARK: 약관 구현
        self.termsofUseButton.snp.makeConstraints {
            $0.top.equalTo(self.genderSegment.snp.bottom).offset(30)
            $0.left.equalTo(self.innerView.snp.left).inset(20)
            $0.width.height.size.equalTo(30)
        }
        
        self.termsofUseLabel.snp.makeConstraints {
            $0.left.equalTo(self.termsofUseButton.snp.right).offset(10)
            $0.centerY.equalTo(self.termsofUseButton.snp.centerY)
        }
        
        self.privacyPolicyButton.snp.makeConstraints {
            $0.top.equalTo(self.termsofUseButton.snp.bottom).offset(15)
            $0.left.equalTo(self.innerView.snp.left).inset(20)
            $0.width.height.size.equalTo(30)
        }
        
        self.privacyPolicyLabel.snp.makeConstraints {
            $0.left.equalTo(self.privacyPolicyButton.snp.right).offset(10)
            $0.centerY.equalTo(self.privacyPolicyButton.snp.centerY)
        }
        
        self.overAgeButton.snp.makeConstraints {
            $0.top.equalTo(self.privacyPolicyButton.snp.bottom).offset(15)
            $0.left.equalTo(self.innerView.snp.left).inset(20)
            $0.width.height.size.equalTo(30)
        }
        
        self.overAgeLabel.snp.makeConstraints {
            $0.left.equalTo(self.overAgeButton.snp.right).offset(10)
            $0.centerY.equalTo(self.overAgeButton.snp.centerY)
        }
        
        // MARK: 프로필 사진 업로드 및 회원 가입 버튼 구현
        self.profileButton.snp.makeConstraints {
            $0.top.equalTo(self.overAgeButton.snp.bottom).offset(30)
            $0.centerX.equalTo(self.innerView.snp.centerX)
            $0.left.equalTo(self.innerView.snp.left).offset(20)
            $0.right.equalTo(self.innerView.snp.right).offset(-20)
            $0.height.equalTo(45)
        }
        
        self.joinButton.snp.makeConstraints {
            $0.top.equalTo(self.profileButton.snp.bottom).offset(10)
            $0.centerX.equalTo(self.innerView.snp.centerX)
            $0.left.equalTo(self.innerView.snp.left).offset(20)
            $0.right.equalTo(self.innerView.snp.right).offset(-20)
            $0.height.equalTo(45)
        }
    }
}

extension JoinViewController {
    @objc func onDidChangeDate(sender: UIDatePicker){
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        
        let selectedDate: String = dateFormatter.string(from: sender.date)
        self.BirthTextField.text = selectedDate
    }
    
    @objc func uploadPhoto() {
        print("눌림")
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self //3
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }
    
    @objc func sendEmailCheck() {
        // code -> 추후 이메일 인증 구현 시
    }
    
    func segmentValueUpdate() {
        let check = genderSegment.selectedSegmentIndex
        if check == 0 {
            self.genderText.text = "남성"
        } else {
            self.genderText.text = "여성"
        }
    }
}

extension JoinViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            profileImage = pickedImage
            if checkJoinParam {
                joinButton.isEnabled = true
                joinButton.backgroundColor = .systemOrange
            } else {
                joinButton.isEnabled = false
                joinButton.backgroundColor = .systemGray6
            }
        }
        dismiss(animated: true, completion: nil)
    }
        
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension JoinViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        view.endEditing(true)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if string.count > 0 && textField != NameTextField { // 입력 모드
            guard string.rangeOfCharacter(from: charSet) == nil else {
                return false
            } // nil이 아니면 통과, 맞으면 입력 안되서 허용된 문자만 입력됨
        }
        let NameTextField = NSMutableString(string: self.NameTextField.text ?? "")
        let EmailTextField = NSMutableString(string: self.EmailTextField.text ?? "")
        let PwTextField = NSMutableString(string: self.PwTextField.text ?? "")
        let PwTextFieldRepeat = NSMutableString(string: self.PwTextFieldRepeat.text ?? "")
        
        switch textField {
        case self.NameTextField:
            NameTextField.replaceCharacters(in: range, with: string)
        case self.EmailTextField:
            EmailTextField.replaceCharacters(in: range, with: string)
        case self.PwTextField:
            PwTextField.replaceCharacters(in: range, with: string)
        case self.PwTextFieldRepeat:
            PwTextFieldRepeat.replaceCharacters(in: range, with: string)
        default:
            break
        }
        
        let checkNameEmail: Bool = NameTextField.length > 2 && EmailTextField.length > 2
        let checkPassword: Bool = PwTextField == PwTextFieldRepeat
        let checkLength: Bool = PwTextField.length > 0 && PwTextFieldRepeat.length > 0
        
        if checkPassword && checkLength {
            PwLabel.text = "비밀번호가 일치합니다"
            PwLabel.textColor = UIColor(named: "Brown")
            PwLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        } else {
            PwLabel.text = "비밀번호가 일치하지 않습니다"
            PwLabel.textColor = .systemRed
            PwLabel.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        }
        
        // MARK: checkJoinParam 확인
        if checkPassword && checkLength && checkNameEmail {
            checkJoinParam = true
        } else {
            checkJoinParam = false
        }
        
        // MARK: 이미지가 있는지도 확인
        if checkPassword && checkLength && checkNameEmail && profileImage.size.width != 0 {
            joinButton.isEnabled = true
            joinButton.backgroundColor = .systemOrange
        } else {
            joinButton.isEnabled = false
            joinButton.backgroundColor = .systemGray6
        }
        
        return true
    }
}

// MARK: API통신 부분
extension JoinViewController {
    func showDangerAlert(message:String){
        let alert = UIAlertController(title: "회원가입 실패",message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: UIAlertAction.Style.default))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showAlert(message:String){
        let alert = UIAlertController(title: "회원가입",message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func checkSign() {
        view.endEditing(true)
        
        Auth.auth().createUser(withEmail: EmailTextField.text!, password: PwTextField.text!) { [weak self] authResult, error in
            if error != nil{
                if let ErrorCode = AuthErrorCode(rawValue: (error?._code)!) {
                    switch ErrorCode {
                    case AuthErrorCode.operationNotAllowed:
                        self?.showDangerAlert(message: "유효하지 않은 접근 입니다")
                    case AuthErrorCode.emailAlreadyInUse:
                        self?.showDangerAlert(message: "이미 가입한 회원 입니다")
                    case AuthErrorCode.invalidEmail:
                        self?.showDangerAlert(message: "유효하지 않은 이메일 입니다")
                    case AuthErrorCode.weakPassword:
                        self?.showDangerAlert(message: "비밀번호는 6자리 이상이어야해요")
                    default:
                        print(ErrorCode)
                    }
                }
            } else {                
                self?.showAlert(message: "회원가입 성공")
                self?.saveUserData()
                self?.saveUserProfileImage(img: self!.profileImage)
                print("회원가입 성공")
            }
        }
    }
    
    func saveUserData() {
        segmentValueUpdate()
        let uid = Auth.auth().currentUser?.uid
        let dataMap = [
            "username": NameTextField.text,
            "email": EmailTextField.text,
            "birth": BirthTextField.text,
            "gender": genderText.text
        ]
        db.child("users").child(uid!).setValue(dataMap)
    }
    
    // MARK: saveUserProfileImage
    func saveUserProfileImage(img: UIImage) {
        var data = Data()
        data = img.jpegData(compressionQuality: 1)!
        let filePath = Auth.auth().currentUser?.uid
        let metaData = StorageMetadata()
        metaData.contentType = "image/png"
        storage.child(filePath!).child("ProfileImage.png").putData(data, metadata: metaData) { (metaData, error) in if let error = error {
                print(error.localizedDescription)
                return
            } else {
                print("업로드 성공")
            }
        }
    }
}
