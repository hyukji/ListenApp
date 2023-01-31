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
    
    let playerController = PlayerController.playerController
//    private let waveformImageDrawer = WaveformImageDrawer()
    
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
        
        return imageView
    }()
    

    lazy var leftView : UIView = {
        let view = UIView()

        return view
    }()

    lazy var rightView : UIView = {
        let view = UIView()

        return view
    }()

    lazy var contentStackView : UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
//        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        
        return stackView
    }()
    
    lazy var scrollView : UIScrollView = {
        let scrollView = UIScrollView()
        
        scrollView.delegate = self
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceHorizontal = true
        scrollView.showsHorizontalScrollIndicator = false
        
        return scrollView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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


// 스크롤 동작 인식
extension PageWaveViewController : UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if playerController.status == .play {
            playerController.intermitPlayer()
        }
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
        
        
        scrollView.addSubview(contentStackView)
        contentStackView.addArrangedSubview(leftView)
        contentStackView.addArrangedSubview(imageView)
        contentStackView.addArrangedSubview(rightView)
        
        
        currentTimeLabel.snp.makeConstraints{
            $0.bottom.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
        
        scrollView.snp.makeConstraints{
            $0.bottom.equalTo(currentTimeLabel.snp.top).offset(-10)
            $0.top.leading.trailing.equalToSuperview()
        }
        
        leftView.snp.makeConstraints{
            $0.height.equalToSuperview()
            $0.width.equalTo(scrollView).multipliedBy(0.5)
        }
        imageView.snp.makeConstraints{
            $0.height.equalToSuperview()
//            $0.width.equalTo(playerController.player.duration * ImagelengthPerSec)
        }
        rightView.snp.makeConstraints{
            $0.height.equalToSuperview()
            $0.width.equalTo(scrollView).multipliedBy(0.5)
        }
        
        contentStackView.snp.makeConstraints{
            $0.top.bottom.leading.trailing.height.equalTo(scrollView)
        }
        
        currentIndicator.snp.makeConstraints{
            $0.bottom.top.equalTo(scrollView)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(2)
        }
        
    }
}
