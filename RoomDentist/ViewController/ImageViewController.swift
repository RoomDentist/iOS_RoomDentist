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
        resultImage.contentMode = .scaleAspectFill
        resultImage.layer.masksToBounds = true
        return resultImage
    }()
    
    var image = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.resultImage.image = image
        configureUI()
    }
    
    func configureUI() {
        self.view.addSubview(self.resultImage)
        
        self.resultImage.snp.makeConstraints {
            $0.left.right.top.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(0)
        }
    }
}
