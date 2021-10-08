//
//  ViewController.swift
//  RoomDentist
//
//  Created by LDH on 2021/07/22.
//

import Foundation
import UIKit
import SnapKit
import Kingfisher
import TextFieldEffects
import Firebase

class LoginViewController: UIViewController {
    
    var tokens = [NSObjectProtocol]()
    
    lazy var mainLogoImage: UIImageView = {
        let mainLogoImage = UIImageView()
        mainLogoImage.contentMode = .scaleAspectFill
        mainLogoImage.image = .init(named: "FullRoomDentist.png")
        return mainLogoImage
    }()
    
    lazy var EmailTextField: TextFieldEffects = {
        let EmailTextField = MadokaTextField()
        EmailTextField.placeholderColor = UIColor(named: "Brown")!
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
    
    lazy var PwTextField: TextFieldEffects = {
        let PwTextField = MadokaTextField()
        PwTextField.placeholderColor = UIColor(named: "Brown")!
        PwTextField.placeholder = "비밀번호"
        PwTextField.borderColor = .systemOrange
        PwTextField.textColor = .black
        PwTextField.placeholderFontScale = CGFloat(1)
        PwTextField.autocapitalizationType = .none
        PwTextField.autocorrectionType = .no
        PwTextField.isSecureTextEntry = true
        PwTextField.delegate = self
        return PwTextField
    }()
    
    lazy var FindPwButton: UIButton = {
        let FindPwButton = UIButton()
        FindPwButton.backgroundColor = UIColor(named: "SkyBlue")
        FindPwButton.setTitleColor(UIColor(named: "Brown"), for: .normal)
        FindPwButton.setTitle("비밀번호 찾기", for: .normal)
        FindPwButton.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        return FindPwButton
    }()
    
    lazy var loginButton: UIButton = {
        let loginButton = UIButton()
        loginButton.isEnabled = false
        loginButton.layer.cornerRadius = 10
        loginButton.backgroundColor = .systemGray6
        loginButton.setTitleColor(.systemGray, for: .disabled)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.setTitle("로그인", for: .normal)
        loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        return loginButton
    }()
    
    lazy var joinButton: UIButton = {
        let joinButton = UIButton()
        joinButton.layer.cornerRadius = 10
        joinButton.backgroundColor = .systemOrange
        joinButton.setTitle("회원가입", for: .normal)
        joinButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        return joinButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reloadUser() // 사용자 정보 불러오고 없으면 ConfigureUI() 실행
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)

        loginButton.addTarget(self, action: #selector(moveMainView), for: .touchUpInside)
        joinButton.addTarget(self, action: #selector(moveJoinView), for: .touchUpInside)
        FindPwButton.addTarget(self, action: #selector(moveResetIDView), for: .touchUpInside)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        tokens.forEach { NotificationCenter.default.removeObserver($0) }
    }
    
    override func viewWillAppear(_ animated: Bool) { // 화면이 표시되기 직전에 사용
        super.viewWillAppear(animated)

        // 화면에 표시되기 직전에 옵저버가 추가, 미리 뷰 로드전에 하면 오류가 생김
        var token = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: OperationQueue.main) { [weak self] (noti) in
            if let frameValue = noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardFrame = frameValue.cgRectValue

                self?.view.frame.origin.y = -keyboardFrame.size.height

                UIView.animate(withDuration: 0.3, animations: {
                    self?.view.layoutIfNeeded()
                }, completion: { finished in
                    UIView.setAnimationsEnabled(true)
                })
            }
        } // 정말 잘 쓰이는 코드, 필히 알고있을 것.
        tokens.append(token)

        token = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: OperationQueue.main, using: { [weak self] (noti) in
            self?.view.frame.origin.y = 0

            UIView.animate(withDuration: 0.3) {
                self?.view.layoutIfNeeded()
            }
        })
        tokens.append(token)
    }
    
//    MARK: Action
    @objc func moveJoinView() {
        performSegue(withIdentifier: "JoinSegue", sender: nil)
    }
    
    @objc func moveResetIDView() {
        performSegue(withIdentifier: "ResetSegue", sender: nil)
    }
    
    @objc func moveMainView() {
        checkSign()
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
        
    func configureUI() {
        self.view.addSubview(self.mainLogoImage)
        self.view.addSubview(self.EmailTextField)
        self.view.addSubview(self.PwTextField)
        self.view.addSubview(self.FindPwButton)
        self.view.addSubview(self.loginButton)
        self.view.addSubview(self.joinButton)
        
        self.mainLogoImage.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(50)
            $0.centerX.equalTo(self.view.safeAreaLayoutGuide.snp.centerX)
            $0.size.height.equalTo(self.view.safeAreaLayoutGuide.snp.height).multipliedBy(0.30)
        }
        
        self.EmailTextField.snp.makeConstraints {
            $0.top.equalTo(self.mainLogoImage.snp.bottom).offset(100)
            $0.centerX.equalTo(self.view.safeAreaLayoutGuide.snp.centerX)
            $0.left.equalTo(self.view.safeAreaLayoutGuide.snp.left).offset(20)
            $0.right.equalTo(self.view.safeAreaLayoutGuide.snp.right).offset(-20)
            $0.height.equalTo(60)
        }
        
        self.PwTextField.snp.makeConstraints {
            $0.top.equalTo(self.EmailTextField.snp.bottom).offset(10)
            $0.centerX.equalTo(self.view.safeAreaLayoutGuide.snp.centerX)
            $0.left.equalTo(self.view.safeAreaLayoutGuide.snp.left).offset(20)
            $0.right.equalTo(self.view.safeAreaLayoutGuide.snp.right).offset(-20)
            $0.height.equalTo(60)
        }
        
        self.FindPwButton.snp.makeConstraints {
            $0.top.equalTo(self.PwTextField.snp.bottom).offset(0)
            $0.right.equalTo(self.view.safeAreaLayoutGuide.snp.right).offset(-20)
        }
        
        self.loginButton.snp.makeConstraints {
            $0.bottom.equalTo(self.joinButton.snp.top).offset(-10)
            $0.centerX.equalTo(self.view.safeAreaLayoutGuide.snp.centerX)
            $0.left.equalTo(self.view.safeAreaLayoutGuide.snp.left).offset(20)
            $0.right.equalTo(self.view.safeAreaLayoutGuide.snp.right).offset(-20)
            $0.height.equalTo(45)
        }
        
        self.joinButton.snp.makeConstraints {
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(0)
            $0.centerX.equalTo(self.view.safeAreaLayoutGuide.snp.centerX)
            $0.left.equalTo(self.view.safeAreaLayoutGuide.snp.left).offset(20)
            $0.right.equalTo(self.view.safeAreaLayoutGuide.snp.right).offset(-20)
            $0.height.equalTo(45)
        }
    }
}

extension LoginViewController {
    func showAlert(message:String){
        let alert = UIAlertController(title: "로그인 실패",message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: UIAlertAction.Style.default))
        self.present(alert, animated: true, completion: nil)
    }
    
    func checkSign() {
        view.endEditing(true)
        
        Auth.auth().signIn(withEmail: EmailTextField.text!, password: PwTextField.text!) { [weak self] authResult, error in
            if error != nil {
                if let ErrorCode = AuthErrorCode(rawValue: (error?._code)!) {
                    switch ErrorCode {
                    case AuthErrorCode.operationNotAllowed:
                        self?.showAlert(message: "유효하지 않은 접근 입니다")
                    case AuthErrorCode.userDisabled:
                        self?.showAlert(message: "정지된 계정입니다. 관리자에게 문의해주세요")
                    case AuthErrorCode.invalidEmail:
                        self?.showAlert(message: "이메일을 다시한번 확인해 주세요")
                    case AuthErrorCode.wrongPassword:
                        self?.showAlert(message: "비밀번호가 틀렸습니다.")
                    default:
                        self?.showAlert(message: "이메일 또는 비밀번호를 다시한번 확인해 주세요")
                    }
                }
            } else{
                print("로그인 성공")
                self?.performSegue(withIdentifier: "MainSegue", sender: nil)
            }
        }
    }
    
    // MARK: 사용자 데이터 다시 가져오기
    func reloadUser(_ callback: ((Error?) -> ())? = nil){
        let status = Auth.auth().currentUser?.reload(completion: { (error) in
            if error != nil{
                self.configureUI()
                self.showAlert(message: "사용자 정보가 만료되었습니다. 다시 로그인해주세요")
            } else {
                self.performSegue(withIdentifier: "MainSegue", sender: nil)
            }
        })
        if status == nil {
            self.configureUI()
        }
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // MARK: return 키 누르면 실행 (아이디 + 비밀번호 4자리 이상 입력시 활성화, 로그인도)
        
        let IdCount = EmailTextField.text?.count ?? 0
        let PwCount = PwTextField.text?.count ?? 0
        
        if IdCount > 4 && PwCount > 4 {
            textField.resignFirstResponder()
            checkSign()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if string.count > 0 { // 입력 모드
            guard string.rangeOfCharacter(from: charSet) == nil else {
                return false
            } // nil이 아니면 통과, 맞으면 입력 안되서 허용된 문자만 입력됨
        }
        
        let IdFinalText = NSMutableString(string: EmailTextField.text ?? "") // 텍스트 문자열로 미리 초기화
        let PwFinalText = NSMutableString(string: PwTextField.text ?? "") // 텍스트 문자열로 미리 초기화
        
        if textField == EmailTextField {
            IdFinalText.replaceCharacters(in: range, with: string)
        } else {
            PwFinalText.replaceCharacters(in: range, with: string)
        }
        print("\(IdFinalText) \(PwFinalText)")
        if IdFinalText.length > 4 && PwFinalText.length > 4 {
            loginButton.isEnabled = true
            loginButton.backgroundColor = .systemYellow
        } else {
            loginButton.isEnabled = false
            loginButton.backgroundColor = .systemGray6
        }
        
        return true
    }
}


#if DEBUG
import SwiftUI

@available(iOS 13, *)
struct ProfileVCPreview: PreviewProvider {
    static var previews: some View {
        // Assuming your storyboard file name is "Main"
        Group {
            UIStoryboard(name: "Login", bundle: nil).instantiateViewController(identifier: "LoginViewController").toPreview().previewDevice("iPhone 12 Pro")
        }
    }
}
#endif
