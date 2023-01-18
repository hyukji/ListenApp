//
//  PageWaveViewController.swift
//  ListenApp
//
//  Created by 곽지혁 on 2023/01/18.
//

import UIKit
import DSWaveformImage

class PageWaveViewController : UIViewController {
    var timer : Timer?
    
    private let waveformImageDrawer = WaveformImageDrawer()
    private let audioURL = playerController.getDocumentFileURL()
    
    lazy var currentTimeLabel : UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .label
        
        return label
    }()
    
    lazy var currentIndicator : UIView = {
        let view = UIView()
        view.backgroundColor = .label
        
        return view
    }()
    
    lazy var imageView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "MusicBasic")
        imageView.contentMode = .scaleToFill
        
        imageView.frame.size = CGSize(width: playerController.player.duration * 5, height: 300)
        
        return imageView
    }()
    
    lazy var scrollView : UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceHorizontal = true
        scrollView.showsHorizontalScrollIndicator = false
        
        scrollView.contentSize.width = imageView.frame.size.width
        scrollView.addSubview(imageView)
        
        return scrollView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setWaveImage()
        addNotificationObserver()
        configureTimer()
        adminTimer()
        
        setLayout()

    }
    
    func setWaveImage() {
        waveformImageDrawer.waveformImage(
            fromAudioAt: audioURL, with: .init(
                size: imageView.frame.size,
                style: .striped(.init(color: view.tintColor)),
                dampening: nil,
                verticalScalingFactor: 0.5)
        ) { image in
            // need to jump back to main queue
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        }
    }
    
    func TimeIntervalToString(_ time:TimeInterval) -> String {
        let min = Int(time/60)
        let sec = Int(time.truncatingRemainder(dividingBy: 60))
        let strTime = String(format: "%02d:%02d", min, sec)
        return strTime
    }
    
    func addNotificationObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(adminTimer),
            name: Notification.Name("playerStatusChanged"),
            object: nil
        )
    }
    
    @objc func adminTimer() {
        if playerController.status == .play {
            timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updatePlayTime), userInfo: nil, repeats: true)
        } else {
            updatePlayTime()
            guard let timer = timer else { return }
            if timer.isValid { timer.invalidate() }
        }
    }
    
    func configureTimer() {
        currentTimeLabel.text = TimeIntervalToString(playerController.player.currentTime)
        // 화면 중심 맞추기
    }
    
    @objc func updatePlayTime() {
        currentTimeLabel.text = TimeIntervalToString(playerController.player.currentTime)
        
        // 화면 중심 맞추기
    }
}


extension PageWaveViewController {
    func setLayout(){
        
        [currentTimeLabel, scrollView, currentIndicator].forEach{
            view.addSubview($0)
        }
        currentTimeLabel.snp.makeConstraints{
            $0.bottom.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
        
        scrollView.snp.makeConstraints{
            $0.bottom.equalTo(currentTimeLabel.snp.top).offset(-10)
            $0.top.leading.trailing.equalToSuperview()
        }
        
        currentIndicator.snp.makeConstraints{
            $0.bottom.top.equalTo(scrollView)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(2)
        }
        
    }
}
