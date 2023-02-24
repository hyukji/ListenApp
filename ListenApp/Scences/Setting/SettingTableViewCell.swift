//
//  SettingTableViewCell.swift
//  ListenTo
//
//  Created by 곽지혁 on 2023/01/11.
//


import UIKit

class SettingTableViewCell : UITableViewCell {
    var cellData : SettingCategory?
    
    private lazy var leftimgView : UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .label
        
        return imageView
    }()
    
    
    private lazy var titleLabel : UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .label
        
        return label
    }()
    
    private lazy var chevronImgView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = .secondaryLabel
        
        return imageView
    }()
    
    
//    lazy var controlSwitch: UISwitch = {
//        let swicth: UISwitch = UISwitch()
//
//        swicth.isOn = false
//
//        // Set the event to be called when switching On / Off of Switch.
////        swicth.addTarget(self, action: #selector(onClickSwitch(sender:)), for: UIControlEvents.valueChanged)
//        return swicth
//    }()
    
    private lazy var accessoryLabel : UILabel = {
        let label = UILabel()
        label.text = "미정"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        
        return label
    }()
    
    
    
    func setLayout(data : SettingCategory) {
        cellData = data
        leftimgView.image = UIImage(systemName: data.icon)
        titleLabel.text = data.text
        
        
        [leftimgView, titleLabel].forEach{
            addSubview($0)
        }
        
        leftimgView.snp.makeConstraints{
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(15)
        }
        
        titleLabel.snp.makeConstraints{
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(leftimgView.snp.trailing).offset(15)
        }
        
        switch data.type {
        case .another:
            addSubview(chevronImgView)
            chevronImgView.snp.makeConstraints{
                $0.centerY.equalToSuperview()
                $0.trailing.equalToSuperview().inset(15)
            }
        case .subSetting:
            [accessoryLabel, chevronImgView].forEach{
                addSubview($0)
            }

            chevronImgView.snp.makeConstraints{
                $0.centerY.equalToSuperview()
                $0.trailing.equalToSuperview().inset(15)
            }

            let subSettingData = AdminUserDefault.settingData[data.name] ?? []
            let selectedNum = AdminUserDefault.settingSelected[data.name] ?? 0
            print(subSettingData, selectedNum)
            accessoryLabel.text = subSettingData[selectedNum]
            accessoryLabel.snp.makeConstraints{
                $0.centerY.equalToSuperview()
                $0.trailing.equalTo(chevronImgView.snp.leading).offset(-10)
            }
        }
        
    }
    
    
}
