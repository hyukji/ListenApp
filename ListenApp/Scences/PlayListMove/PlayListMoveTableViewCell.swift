//
//  PlayListMoveTableViewCell.swift
//  ListenApp
//
//  Created by 곽지혁 on 2023/01/25.
//

import UIKit


class PlayListMoveTableViewCell : UITableViewCell {
    
    lazy var imgViewContainer : UIView = {
        let container = UIView()
        
        return container
    }()
    
    lazy var fileImgView : UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .label
        
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "MusicBasic") ?? UIImage()
        
        return imageView
    }()
    
    lazy var folderImgView : UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .label
        
        imageView.contentMode = .scaleAspectFit
        let imageConfig = UIImage.SymbolConfiguration(font: .systemFont(ofSize: 20, weight: .light), scale: .default)
        imageView.image =  UIImage(systemName: "folder", withConfiguration: imageConfig)
        
        return imageView
    }()
    
    private lazy var titleLabel : UILabel = {
        let label = UILabel()
        label.text = "Test1"
        label.font = .systemFont(ofSize: 20, weight: .regular)
        label.textColor = .label
        
        return label
    }()
    
    private lazy var timeLabel : UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .secondaryLabel
        
        return label
    }()
    
    private lazy var stackView : UIStackView = {
        let view = UIStackView()
        
        view.axis = .vertical
        view.distribution = .fill
        view.alignment = .leading
        
        return view
    }()
    
    private lazy var rightIconButton : UIButton = {
        let button = UIButton()
        
        return button
    }()
    
    
    var isCanMoveFolder = true

    func setLayout(item : DocumentItem, duration : TimeInterval) {
        self.selectionStyle = .default
        
        [imgViewContainer, rightIconButton, stackView].forEach{
            contentView.addSubview($0)
        }
        imgViewContainer.addSubview(folderImgView)
        imgViewContainer.addSubview(fileImgView)
        
        let buttonImgConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        
        if item.type == .file {
            imgViewContainer.layer.borderWidth = 1
            imgViewContainer.layer.borderColor = UIColor.lightGray.cgColor
            
            folderImgView.isHidden = true
            fileImgView.isHidden = false
            
            stackView.arrangedSubviews.forEach{
                stackView.removeArrangedSubview($0)
            }
            stackView.addArrangedSubview(titleLabel)
            stackView.addArrangedSubview(timeLabel)
            
            titleLabel.textColor = .secondaryLabel
            timeLabel.text = duration.toString()
        }
        else {
            imgViewContainer.layer.borderWidth = 0
            
            folderImgView.isHidden = false
            fileImgView.isHidden = true
            
            stackView.arrangedSubviews.forEach{
                stackView.removeArrangedSubview($0)
            }
            stackView.addArrangedSubview(titleLabel)
            
            titleLabel.textColor = isCanMoveFolder ? .label : . secondaryLabel
            folderImgView.tintColor = isCanMoveFolder ? .label : . secondaryLabel
            
            let image = UIImage(systemName: "chevron.right", withConfiguration: buttonImgConfig)
            rightIconButton.setImage(image, for: .normal)
        }
        
        titleLabel.text = item.title
        
        imgViewContainer.snp.makeConstraints{
            $0.top.bottom.equalToSuperview().inset(10)
            $0.leading.equalToSuperview().offset(20)
            $0.width.equalTo(imgViewContainer.snp.height)
        }
        
        folderImgView.snp.makeConstraints{
//            $0.height.width.equalToSuperview()
            $0.height.width.equalToSuperview().multipliedBy(0.9)
            $0.centerX.centerY.equalToSuperview()
        }
        
        fileImgView.snp.makeConstraints{
//            $0.height.width.equalToSuperview()
            $0.height.width.equalToSuperview().multipliedBy(0.3)
            $0.centerX.centerY.equalToSuperview()
        }
        
        rightIconButton.snp.makeConstraints{
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(30)
        }
        
        stackView.snp.makeConstraints{
            $0.leading.equalTo(imgViewContainer.snp.trailing).offset(10)
            $0.trailing.equalTo(rightIconButton.snp.leading).offset(-10)
            $0.top.equalTo(imgViewContainer).inset(5)
            $0.bottom.equalTo(imgViewContainer).inset(5)
        }
        
    }
    
}


