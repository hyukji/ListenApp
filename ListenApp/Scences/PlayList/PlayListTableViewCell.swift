//
//  PlayListTableViewCell.swift
//  ListenTo
//
//  Created by 곽지혁 on 2023/01/10.
//

import UIKit
import SnapKit

class PlayListTableViewCell : UITableViewCell {
    
    lazy var imgView : UIImageView = {
        let imageView = UIImageView()
        
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
        
        view.addArrangedSubview(titleLabel)
        view.addArrangedSubview(timeLabel)
        
        return view
    }()
    
    private lazy var rightIconButton : UIButton = {
        let button = UIButton()
        
        return button
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if isEditing {
            self.rightIconButton.isHidden = true
        } else {
            self.rightIconButton.isHidden = false
        }

    }
    
    func setLayout(item : DocumentItem, duration : TimeInterval) {
        self.selectionStyle = .default
        
        [imgView, rightIconButton, stackView].forEach{
            contentView.addSubview($0)
        }
        
        
        let buttonImgConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        if item.type == .file {
            imgView.contentMode = .scaleAspectFit
            imgView.layer.borderWidth = 1
            imgView.layer.borderColor = UIColor.lightGray.cgColor
            imgView.image = UIImage(named: "MusicBasic") ?? UIImage()
            
            timeLabel.isHidden = false
            timeLabel.text = duration.toString()
            
            let image = UIImage(systemName: "play", withConfiguration: buttonImgConfig)
            rightIconButton.setImage(image, for: .normal)
        }
        else {
            imgView.layer.borderWidth = 0
            imgView.tintColor = .label
            imgView.contentMode = .scaleAspectFit
            imgView.image =  UIImage(systemName: "folder")
            
            timeLabel.isHidden = true
            
            let image = UIImage(systemName: "chevron.right", withConfiguration: buttonImgConfig)
            rightIconButton.setImage(image, for: .normal)
        }
        
        titleLabel.text = item.title
        
        imgView.snp.makeConstraints{
            $0.top.bottom.equalToSuperview().inset(10)
            $0.leading.equalToSuperview().offset(20)
            $0.width.equalTo(imgView.snp.height)
        }
        
        rightIconButton.snp.makeConstraints{
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(30)
        }
        
        stackView.snp.makeConstraints{
            $0.leading.equalTo(imgView.snp.trailing).offset(10)
            $0.trailing.equalTo(rightIconButton.snp.leading).offset(-10)
            $0.top.equalTo(imgView).inset(5)
            $0.bottom.equalTo(imgView).inset(5)
        }
        
    }
    
}
