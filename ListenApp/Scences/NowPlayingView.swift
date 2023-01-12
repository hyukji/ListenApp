//
//  NowPlayingView.swift
//  ListenTo
//
//  Created by 곽지혁 on 2023/01/10.
//

import UIKit


class NowPlayingView : UIView {
    
    private lazy var imageView : UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "play.fill"))
        imageView.tintColor = .white
        
        return imageView
    }()
    
    private lazy var contentView : UIView = {
        let view = UIView()
        view.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        return view
    }()
    
    private lazy var titleLabel : UILabel = {
        let label = UILabel()
        
        label.text = "Title111111111111111111"
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .white
        
        return label
    }()
    
    
    override init(frame: CGRect) {
        super .init(frame: frame)
        
        setLayout()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
}
    



extension NowPlayingView {
    
    private func setLayout() {
        
        self.backgroundColor = .tintColor
        self.layer.cornerRadius = 20
        
        [imageView, contentView, titleLabel].forEach{
            addSubview($0)
        }

        imageView.snp.makeConstraints{
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
        }

        contentView.snp.makeConstraints{
            $0.top.bottom.equalToSuperview()
            $0.leading.equalTo(imageView.snp.trailing).offset(10)
            $0.trailing.equalToSuperview().inset(15)
        }

        titleLabel.snp.makeConstraints{
            $0.centerY.equalTo(contentView)
            $0.width.lessThanOrEqualTo(contentView.snp.width)
            $0.centerX.equalTo(contentView.snp.centerX)
        }
        
    }
}

