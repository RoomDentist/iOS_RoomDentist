//
//  JoinViewController.swift
//  RoomDentist
//
//  Created by LDH on 2021/07/23.
//

import UIKit
import TextFieldEffects
import Firebase

class JoinViewController: UIViewController {
    
    let db = Database.database().reference()
    let storage = Storage.storage().reference().child("users")
    var checkJoinParam: Bool = false
    
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
    
    lazy var NameTextField: TextFieldEffects = {
        let NameTextField = MadokaTextField()
        NameTextField.placeholderColor = UIColor(named: "Brown")!
        NameTextField.placeholder = "이름"
        NameTextField.borderColor = .systemOrange
        NameTextField.textColor = .black
        NameTextField.font = UIFont(name: "GmarketSansBold", size: CGFloat(17))
        NameTextField.placeholderFontScale = CGFloat(1)
        NameTextField.autocapitalizationType = .none
        NameTextField.autocorrectionType = .no
        NameTextField.delegate = self
        return NameTextField
    }()
    
    lazy var EmailTextField: TextFieldEffects = {
        let EmailTextField = MadokaTextField()
        EmailTextField.placeholderColor = UIColor(named: "Brown")!
        EmailTextField.keyboardType = .emailAddress
        EmailTextField.placeholder = "이메일"
        EmailTextField.keyboardType = .emailAddress
        EmailTextField.borderColor = .systemOrange
        EmailTextField.textColor = .black
        EmailTextField.font = UIFont(name: "GmarketSansBold", size: CGFloat(17))
        EmailTextField.placeholderFontScale = CGFloat(1)
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
        return SendEmailButton
    }()
    
    lazy var PwTextField: TextFieldEffects = {
        let PwTextField = MadokaTextField()
        PwTextField.placeholderColor = UIColor(named: "Brown")!
        PwTextField.placeholder = "비밀번호"
        PwTextField.borderColor = .systemOrange
        PwTextField.textColor = .black
        PwTextField.font = UIFont(name: "GmarketSansBold", size: CGFloat(17))
        PwTextField.placeholderFontScale = CGFloat(1)
        PwTextField.autocapitalizationType = .none
        PwTextField.autocorrectionType = .no
        PwTextField.isSecureTextEntry = true
        PwTextField.delegate = self
        return PwTextField
    }()
    
    lazy var PwTextFieldRepeat: TextFieldEffects = {
        let PwTextFieldRepeat = MadokaTextField()
        PwTextFieldRepeat.placeholderColor = UIColor(named: "Brown")!
        PwTextFieldRepeat.placeholder = "비밀번호 재입력"
        PwTextFieldRepeat.borderColor = .systemOrange
        PwTextFieldRepeat.textColor = .black
        PwTextFieldRepeat.font = UIFont(name: "GmarketSansBold", size: CGFloat(17))
        PwTextFieldRepeat.placeholderFontScale = CGFloat(1)
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
    
    lazy var profileButton: UIButton = {
        let profileButton = UIButton()
        profileButton.layer.cornerRadius = 10
        profileButton.setTitle("프로필 사진 가져오기", for: .normal)
        profileButton.isEnabled = true
        profileButton.backgroundColor = .systemYellow
        profileButton.setTitleColor(.white, for: .normal)
        profileButton.titleLabel?.font = UIFont(name: "GmarketSansBold", size: CGFloat(17))
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
        return joinButton
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        joinButton.addTarget(self, action: #selector(createUser), for: .touchUpInside)
        profileButton.addTarget(self, action: #selector(uploadPhoto), for: .touchUpInside)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func createUser() {
        checkSign()
    }

    func configureUI() {
        self.view.addSubview(self.titleLabel)
        self.view.addSubview(self.NameTextField)
        self.view.addSubview(self.EmailTextField)
        self.view.addSubview(self.SendEmailButton)
        self.view.addSubview(self.PwTextField)
        self.view.addSubview(self.PwTextFieldRepeat)
        self.view.addSubview(self.PwLabel)
        self.view.addSubview(self.BirthText)
        self.view.addSubview(self.BirthTextFieldPicker)
        self.view.addSubview(self.genderText)
        self.view.addSubview(self.genderSegment)
        self.view.addSubview(self.profileButton)
        self.view.addSubview(self.joinButton)
        
        self.titleLabel.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(20)
            $0.centerX.equalTo(self.view.safeAreaLayoutGuide.snp.centerX)
        }
        
        self.NameTextField.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(50)
            $0.centerX.equalTo(self.view.safeAreaLayoutGuide.snp.centerX)
            $0.left.equalTo(self.view.safeAreaLayoutGuide.snp.left).offset(20)
            $0.right.equalTo(self.view.safeAreaLayoutGuide.snp.right).offset(-20)
            $0.height.equalTo(60)
        }
        
        self.EmailTextField.snp.makeConstraints {
            $0.top.equalTo(NameTextField.snp.bottom).offset(10)
            $0.centerX.equalTo(self.view.safeAreaLayoutGuide.snp.centerX)
            $0.left.equalTo(self.view.safeAreaLayoutGuide.snp.left).offset(20)
            $0.right.equalTo(self.view.safeAreaLayoutGuide.snp.right).offset(-20)
            $0.height.equalTo(60)
        }
        
        self.SendEmailButton.snp.makeConstraints {
            $0.top.equalTo(self.EmailTextField.snp.bottom).offset(0)
            $0.right.equalTo(self.view.safeAreaLayoutGuide.snp.right).offset(-20)
        }

        self.PwTextField.snp.makeConstraints {
            $0.top.equalTo(self.SendEmailButton.snp.bottom).offset(20)
            $0.centerX.equalTo(self.view.safeAreaLayoutGuide.snp.centerX)
            $0.left.equalTo(self.view.safeAreaLayoutGuide.snp.left).offset(20)
            $0.right.equalTo(self.view.safeAreaLayoutGuide.snp.right).offset(-20)
            $0.height.equalTo(60)
        }
        
        self.PwTextFieldRepeat.snp.makeConstraints {
            $0.top.equalTo(self.PwTextField.snp.bottom).offset(10)
            $0.centerX.equalTo(self.view.safeAreaLayoutGuide.snp.centerX)
            $0.left.equalTo(self.view.safeAreaLayoutGuide.snp.left).offset(20)
            $0.right.equalTo(self.view.safeAreaLayoutGuide.snp.right).offset(-20)
            $0.height.equalTo(60)
        }
        
        self.PwLabel.snp.makeConstraints {
            $0.top.equalTo(self.PwTextFieldRepeat.snp.bottom).offset(0)
            $0.right.equalTo(self.view.safeAreaLayoutGuide.snp.right).offset(-20)
        }
        
        self.BirthText.snp.makeConstraints {
            $0.top.equalTo(self.PwLabel.snp.bottom).offset(17)
            $0.left.equalTo(self.view.safeAreaLayoutGuide.snp.left).offset(20)
            $0.right.equalTo(self.BirthTextFieldPicker.snp.left).offset(-20)
        }
        
        self.BirthTextFieldPicker.snp.makeConstraints {
            $0.top.equalTo(self.PwLabel.snp.bottom).offset(10)
            $0.left.equalTo(self.BirthText.snp.right).offset(20)
        }
        
        self.genderText.snp.makeConstraints {
            $0.top.equalTo(self.PwLabel.snp.bottom).offset(17)
            $0.left.equalTo(self.BirthTextFieldPicker.snp.right).offset(20)
            $0.right.equalTo(self.genderSegment.snp.left).offset(-20)
        }
        
        self.genderSegment.snp.makeConstraints {
            $0.top.equalTo(self.PwLabel.snp.bottom).offset(10)
            $0.left.equalTo(self.genderText.snp.right).offset(20)
        }
        
        self.profileButton.snp.makeConstraints {
            $0.top.equalTo(self.genderSegment.snp.bottom).offset(30)
            $0.centerX.equalTo(self.view.safeAreaLayoutGuide.snp.centerX)
            $0.left.equalTo(self.view.safeAreaLayoutGuide.snp.left).offset(20)
            $0.right.equalTo(self.view.safeAreaLayoutGuide.snp.right).offset(-20)
            $0.height.equalTo(45)
        }
        
        self.joinButton.snp.makeConstraints {
            $0.top.equalTo(self.profileButton.snp.bottom).offset(10)
            $0.centerX.equalTo(self.view.safeAreaLayoutGuide.snp.centerX)
            $0.left.equalTo(self.view.safeAreaLayoutGuide.snp.left).offset(20)
            $0.right.equalTo(self.view.safeAreaLayoutGuide.snp.right).offset(-20)
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
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self //3
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }
    
    func segmentValueUpdate() {
        var check = genderSegment.selectedSegmentIndex
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
            } else{
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

#if DEBUG
import SwiftUI

@available(iOS 13, *)
struct ProfileVCPreview1: PreviewProvider {
    static var previews: some View {
        Group {
            UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "JoinViewController").toPreview().previewDevice("iPhone 12 Pro")
        }
    }
}
#endif
