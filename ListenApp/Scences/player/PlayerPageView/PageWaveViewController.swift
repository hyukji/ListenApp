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
    let ImagelengthPerSec = 10.0
    
    private let waveformImageDrawer = WaveformImageDrawer()
    private let audioURL = playerController.getDocumentFileURL()
    
    lazy var currentTimeLabel : UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 25, weight: .semibold)
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
        
        imageView.frame.size.width = playerController.player.duration * ImagelengthPerSec
        
        return imageView
    }()
    
    lazy var scrollView : UIScrollView = {
        let leftView = UIView()
        let rightView = UIView()
        let scrollView = UIScrollView()
        
        leftView.backgroundColor = .systemBackground
        rightView.backgroundColor = .systemBackground
        
        let size = CGSize(width: (view.frame.size.width - 40) / 2, height: view.frame.size.height)
        leftView.frame.size = size
        rightView.frame.size = size
        
        scrollView.delegate = self
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceHorizontal = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentSize.width = imageView.frame.size.width + view.frame.size.width
        
        scrollView.addSubview(leftView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(rightView)

        
        return scrollView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setWaveImage()
        addNotificationObserver()
        setLayout()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        updatePlayTime()
        adminTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        guard let timer = timer else { return }
        if timer.isValid { timer.invalidate() }
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
            if let timer = timer {
                if timer.isValid { return }
            }
            self.timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updatePlayTime), userInfo: nil, repeats: true)
        } else {
            updatePlayTime()
            if let timer = timer {
                if timer.isValid { timer.invalidate() }
            }
        }
    }
    
    @objc func updatePlayTime() {
        currentTimeLabel.text = TimeIntervalToString(playerController.player.currentTime)
        let nx = playerController.player.currentTime * 5
        scrollView.contentOffset = CGPointMake(nx, 0);
        
        // 화면 중심 맞추기
    }
}

extension PageWaveViewController : UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if playerController.status == .play {
            playerController.intermitPlayer()
        }
        print("begin")
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false && playerController.status == .intermit {
            playerController.playPlayer()
        }
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let timer = timer { if timer.isValid { return }}
        
        let x = Double(scrollView.contentOffset.x)
        playerController.changePlayerTime(changedTime : TimeInterval(x / 5))
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
