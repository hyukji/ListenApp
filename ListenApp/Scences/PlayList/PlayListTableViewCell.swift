//
//  PlayListTableViewCell.swift
//  ListenTo
//
//  Created by 곽지혁 on 2023/01/10.
//

import UIKit

class PlayListTableViewCell : UITableViewCell {
    
    private lazy var imgView : UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        
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
        label.text = "30:21"
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
    
    private lazy var playButton : UIButton = {
        let button = UIButton()
        
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        let image = UIImage(systemName: "play", withConfiguration: imageConfig)
        button.setImage(image, for: .normal)
        
//      button.addTarget(self, action: #selector(tapPlayBtn), for: .touchUpInside)
        
        return button
    }()
    
    
    func setLayout(audio : NowAudio) {
        [imgView, playButton, stackView].forEach{
            addSubview($0)
        }
        
        imgView.image = audio.mainImage
        titleLabel.text = audio.title
        
        imgView.snp.makeConstraints{
            $0.top.bottom.equalToSuperview().inset(10)
            $0.leading.equalToSuperview().offset(20)
            $0.width.equalTo(imgView.snp.height)
        }
        
        playButton.snp.makeConstraints{
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(30)
        }
        
        stackView.snp.makeConstraints{
            $0.leading.equalTo(imgView.snp.trailing).offset(10)
            $0.trailing.equalTo(playButton.snp.leading)
            $0.top.equalTo(imgView).inset(5)
            $0.bottom.equalTo(imgView).inset(5)
        }
    }
    
    
}


