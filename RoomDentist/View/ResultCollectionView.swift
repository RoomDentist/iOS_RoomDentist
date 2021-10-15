//
//  ResultView.swift
//  RoomDentist
//
//  Created by LDH on 2021/10/09.
//

import Foundation
import UIKit
import Firebase

class ResultCollectionView: UICollectionViewCell {
    lazy var resultImageView: UIImageView = {
        let resultImageView = UIImageView()
        resultImageView.layer.cornerRadius = 10
        resultImageView.contentMode = .scaleAspectFill
        resultImageView.layer.masksToBounds = true
        return resultImageView
    }()
    
    lazy var resultLabel: UILabel = {
        let resultLabel = UILabel()
        resultLabel.text = "충치 개수 : 7개\n아말감 개수 : 7개\n금니 개수 : 7개"
        resultLabel.numberOfLines = 3
        resultLabel.textColor = .black
        resultLabel.font = UIFont(name: "GmarketSansMedium", size: CGFloat(17))
        return resultLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureUI()
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureUI() {
        self.addSubview(self.resultImageView)
        self.addSubview(self.resultLabel)
        
        self.resultImageView.snp.makeConstraints {
            $0.top.equalTo(self.snp.top).offset(0)
            $0.size.width.height.equalTo(200)
            $0.left.equalTo(self.snp.left).offset(0)
        }
        
        self.resultLabel.snp.makeConstraints {
            $0.centerY.equalTo(self.resultImageView.snp.centerY).offset(0)
            $0.left.equalTo(self.resultImageView.snp.right).offset(20)
        }
    }
}
