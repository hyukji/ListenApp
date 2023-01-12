//
//  SettingTableViewCell.swift
//  ListenTo
//
//  Created by 곽지혁 on 2023/01/11.
//


import UIKit

class SettingTableViewCell : UITableViewCell {
    
    private lazy var leftimgView : UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .label
        
        return imageView
    }()
    
    
    private lazy var titleLabel : UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .light)
        label.textColor = .label
        
        return label
    }()
    
    private lazy var rightimgView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = .secondaryLabel
        
        return imageView
    }()
    
    func setLayout(img : String, title : String) {
        leftimgView.image = UIImage(systemName: img)
        titleLabel.text = title
        
        
        [leftimgView, titleLabel, rightimgView].forEach{
            addSubview($0)
        }
        
        leftimgView.snp.makeConstraints{
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
        }
        
        titleLabel.snp.makeConstraints{
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(leftimgView.snp.trailing).offset(20)
        }
        
        rightimgView.snp.makeConstraints{
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(20)
        }
    }
    
    
}
