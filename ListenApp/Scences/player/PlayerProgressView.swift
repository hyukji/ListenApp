//
//  PlayerProgressView.swift
//  ListenTo
//
//  Created by 곽지혁 on 2023/01/11.
//

import UIKit

class PlayerProgressView : UIView {
    
    lazy var progressView : UIProgressView = {
        let bar = UIProgressView()
        
        bar.trackTintColor = .lightGray
        bar.progressTintColor = .tintColor
        bar.transform = CGAffineTransform(scaleX: 1, y: 1.5)
        
        bar.progress = 0.4
        
        return bar
    }()
    
    lazy var nowTimeLabel : UILabel = {
        let label = UILabel()
        label.text = "00.49"
        label.font = .systemFont(ofSize: 10)
        label.textColor = .tintColor
        
        return label
    }()

    
    lazy var totalTimeLabel : UILabel = {
        let label = UILabel()
        label.text = "02.40"
        label.font = .systemFont(ofSize: 10)
        label.textColor = .lightGray
        
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


extension PlayerProgressView {
    private func setLayout() {
        [progressView, nowTimeLabel, totalTimeLabel].forEach{
            addSubview($0)
        }
        
        nowTimeLabel.snp.makeConstraints{
            $0.leading.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        totalTimeLabel.snp.makeConstraints{
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        progressView.snp.makeConstraints{
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(nowTimeLabel.snp.top).offset(-5)
        }
        
        
        
    }
    
    
}
