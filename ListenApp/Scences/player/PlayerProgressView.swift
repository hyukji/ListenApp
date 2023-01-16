//
//  PlayerProgressView.swift
//  ListenTo
//
//  Created by 곽지혁 on 2023/01/11.
//

import UIKit

class PlayerProgressView : UIView {
    var timer : Timer?
    
    lazy var progressView : UIProgressView = {
        let bar = UIProgressView()
        
        bar.trackTintColor = .lightGray
        bar.progressTintColor = .tintColor
        bar.transform = CGAffineTransform(scaleX: 1, y: 1.5)
        
        bar.progress = 0.4
        
        return bar
    }()
    
    lazy var currentTimeLabel : UILabel = {
        let label = UILabel()
        label.text = TimeIntervalToString(playerController.player.currentTime)
        label.font = .systemFont(ofSize: 10)
        label.textColor = .tintColor
        
        return label
    }()

    
    lazy var DurationLabel : UILabel = {
        let label = UILabel()
        label.text = TimeIntervalToString(playerController.player.duration)
        label.font = .systemFont(ofSize: 10)
        label.textColor = .lightGray
        
        return label
    }()
    
    override init(frame: CGRect) {
        super .init(frame: frame)
        setLayout()
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updatePlayTime), userInfo: nil, repeats: true)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("deinit")
        
    }
    
    @objc func updatePlayTime() {
        currentTimeLabel.text = TimeIntervalToString(playerController.player.currentTime)
        progressView.progress = Float(playerController.player.currentTime / playerController.player.duration)
    }
    
    func TimeIntervalToString(_ time:TimeInterval) -> String {
        let min = Int(time/60)
        let sec = Int(time.truncatingRemainder(dividingBy: 60))
        let strTime = String(format: "%02d:%02d", min, sec)
        return strTime
    }
    
    
}


extension PlayerProgressView {
    private func setLayout() {
        [progressView, currentTimeLabel, DurationLabel].forEach{
            addSubview($0)
        }
        
        currentTimeLabel.snp.makeConstraints{
            $0.leading.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        DurationLabel.snp.makeConstraints{
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        progressView.snp.makeConstraints{
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(currentTimeLabel.snp.top).offset(-5)
        }
        
        
        
    }
    
    
}
