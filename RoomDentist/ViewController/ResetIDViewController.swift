//
//  ResetIDViewController.swift
//  RoomDentist
//
//  Created by LDH on 2021/09/27.
//

import UIKit
import TextFieldEffects
import Firebase

class ResetIDViewController: UIViewController {

    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = "방구석 Dentist 비밀번호 찾기"
        titleLabel.tintColor = UIColor(named: "Brown")!
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        return titleLabel
    }()
    
    lazy var EmailTextField: TextFieldEffects = {
        let EmailTextField = MadokaTextField()
        EmailTextField.placeholderColor = UIColor(named: "Brown")!
        EmailTextField.keyboardType = .emailAddress
        EmailTextField.placeholder = "이메일"
        EmailTextField.keyboardType = .emailAddress
        EmailTextField.borderColor = .systemOrange
        EmailTextField.textColor = .black
        EmailTextField.placeholderFontScale = CGFloat(1)
        EmailTextField.autocapitalizationType = .none
        EmailTextField.autocorrectionType = .no
        EmailTextField.delegate = self
        return EmailTextField
    }()
    
    lazy var findButton: UIButton = {
        let findButton = UIButton()
        findButton.layer.cornerRadius = 10
        findButton.setTitle("비밀번호 찾기", for: .normal)
        findButton.isEnabled = false
        findButton.backgroundColor = .systemGray6
        findButton.setTitleColor(.systemGray, for: .disabled)
        findButton.setTitleColor(.white, for: .normal)
        findButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        return findButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        findButton.addTarget(self, action: #selector(findPW), for: .touchUpInside)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func findPW() {
        view.endEditing(true)
        sendPasswordReset(withEmail: EmailTextField.text!)
    }
    
    func configureUI() {
        self.view.addSubview(self.titleLabel)
        self.view.addSubview(self.EmailTextField)
        self.view.addSubview(self.findButton)
        
        self.titleLabel.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(20)
            $0.centerX.equalTo(self.view.safeAreaLayoutGuide.snp.centerX)
        }
        
        self.EmailTextField.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.centerX.equalTo(self.view.safeAreaLayoutGuide.snp.centerX)
            $0.left.equalTo(self.view.safeAreaLayoutGuide.snp.left).offset(20)
            $0.right.equalTo(self.view.safeAreaLayoutGuide.snp.right).offset(-20)
            $0.height.equalTo(60)
        }
        
        self.findButton.snp.makeConstraints {
            $0.top.equalTo(self.EmailTextField.snp.bottom).offset(30)
            $0.centerX.equalTo(self.view.safeAreaLayoutGuide.snp.centerX)
            $0.left.equalTo(self.view.safeAreaLayoutGuide.snp.left).offset(20)
            $0.right.equalTo(self.view.safeAreaLayoutGuide.snp.right).offset(-20)
            $0.height.equalTo(45)
        }
    }
}

extension ResetIDViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        view.endEditing(true)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if string.count > 0 { // 입력 모드
            guard string.rangeOfCharacter(from: charSet) == nil else {
                return false
            } // nil이 아니면 통과, 맞으면 입력 안되서 허용된 문자만 입력됨
        }
        let EmailTextField = NSMutableString(string: self.EmailTextField.text ?? "")
        
        EmailTextField.replaceCharacters(in: range, with: string)
        
        if EmailTextField.length > 2 {
            findButton.isEnabled = true
            findButton.backgroundColor = .systemYellow
        } else {
            findButton.isEnabled = false
            findButton.backgroundColor = .systemGray6
        }
        
        return true
    }
}

extension ResetIDViewController {
    func showDangerAlert(message:String){
        let alert = UIAlertController(title: "비밀번호 초기화",message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: UIAlertAction.Style.default))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showAlert(message: String){
        let alert = UIAlertController(title: "비밀번호 초기화",message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func sendPasswordReset(withEmail email: String, _ callback: ((Error?) -> ())? = nil){
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if error != nil{
                if let ErrorCode = AuthErrorCode(rawValue: (error?._code)!) {
//                    print(error?.localizedDescription)
                    switch ErrorCode {
                    case .userNotFound:
                        self.showDangerAlert(message: "해당 이메일을 가진 사용자가 없습니다")
                    case .invalidEmail:
                        self.showDangerAlert(message: "이메일 주소의 형식이 잘못되었습니다")
                    default:
                        self.showDangerAlert(message: "오류발생, 관리자에게 문의하십시오")
                    }
                }
            } else {
                self.showAlert(message: "비밀번호 초기화 메일 전송 완료")
            }
        }
    }
}
