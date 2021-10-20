//
//  ImageViewController.swift
//  RoomDentist
//
//  Created by LDH on 2021/10/16.
//

import UIKit

class ImageViewController: UIViewController {
    
    lazy var resultImage: UIImageView = {
        var resultImage = UIImageView()
        resultImage.layer.cornerRadius = 10
        resultImage.contentMode = .scaleAspectFit
        resultImage.layer.masksToBounds = true
        
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(doPinch(_:)))
        self.view.addGestureRecognizer(pinch) // 핀치 제스처 등록
        
        // UIPanGestureRecognizer는 target(ViewController)에서 drag가 감지되면 action을 실행한다.
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(drag(_:)))
        self.view.addGestureRecognizer(panGesture)
        return resultImage
    }()
    
    lazy var exitButton: UIButton = {
        let exitButton = UIButton()
        exitButton.layer.cornerRadius = 10
        exitButton.backgroundColor = UIColor(named: "SignatureBlack")
        exitButton.setTitleColor(.white, for: .normal)
        exitButton.setTitle("뒤로 가기", for: .normal)
        exitButton.titleLabel?.font = UIFont(name: "GmarketSansBold", size: CGFloat(17))
        exitButton.addTarget(self, action: #selector(prevPageEvent), for: .touchUpInside)
        return exitButton
    }()
    
    var image = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.resultImage.image = image
        configureUI()
    }

    func configureUI() {
        self.view.addSubview(self.resultImage)
        self.view.addSubview(self.exitButton)
        
        self.resultImage.snp.makeConstraints {
            $0.left.right.top.bottom.equalTo(self.view).inset(0)
        }
        
        self.exitButton.snp.makeConstraints {
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).inset(0)
            $0.right.equalTo(self.view.safeAreaLayoutGuide.snp.right).inset(20)
            $0.left.equalTo(self.view.safeAreaLayoutGuide.snp.left).inset(20)
            $0.height.equalTo(45)
        }
    }
}

extension ImageViewController {
    @objc func prevPageEvent() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func doPinch(_ pinch: UIPinchGestureRecognizer) {
        resultImage.transform = resultImage.transform.scaledBy(x: pinch.scale, y: pinch.scale)
        pinch.scale = 1
    }
    
    @objc func drag(_ sender: UIPanGestureRecognizer) {
        // self는 여기서 ViewController이므로 self.view ViewController가 기존에가지고 있는 view이다.
        let transition = sender.translation(in: self.view) // translation에 움직인 위치를 저장한다.
        let changedX = resultImage.center.x + transition.x
        let changedY = resultImage.center.y + transition.y
        resultImage.center = CGPoint(x: changedX, y: changedY)
        sender.setTranslation(.zero, in: self.view) // 0으로 움직인 값을 초기화 시켜준다.
    }
}
