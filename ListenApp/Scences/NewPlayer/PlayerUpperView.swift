//
//  PlayerUpperView.swift
//  ListenApp
//
//  Created by 곽지혁 on 2023/01/27.
//

import UIKit

class PlayerUpperView : UIView {
    let playerController = PlayerController.playerController
    var timer : Timer?
    
    private var slider : UISlider = {
        let slider = UISlider()
        
        slider.value = 50
        
        slider.tintColor = .tintColor
//        slider.transform = CGAffineTransform(scaleX: 1, y: 1.5)
        slider.setThumbImage(UIImage(), for: .normal)
        
        return slider
    }()
    
    lazy var currentTimeLabel : UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10)
        label.textColor = .tintColor
        
        return label
    }()

    lazy var DurationLabel : UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10)
        label.textColor = .lightGray
        
        return label
    }()
    
    private lazy var sliderContainer = UIView()
    
    lazy var upperControllerSV : UIStackView = {
        let stackView = UIStackView()
        
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        
        stackView.tintColor = .label
        
        let waveRepeatButton = UIButton()
        let speedButton = UIButton()
        let abRepeatButton = UIButton()
        
        let repeatImageConfig = UIImage.SymbolConfiguration(font: .systemFont(ofSize: 25), scale: .default)
        let speedTitle = UILabel()
        
        waveRepeatButton.setImage(UIImage(systemName: "repeat.1", withConfiguration: repeatImageConfig), for: .normal)
        abRepeatButton.setImage(UIImage(systemName: "repeat", withConfiguration: repeatImageConfig), for: .normal)
        speedButton.setTitle("1.0x", for: .normal)
        speedButton.setTitleColor(.label, for: .normal)
        speedButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .regular)
        
        [waveRepeatButton, speedButton, abRepeatButton].forEach{
            stackView.addArrangedSubview($0)
        }
        
        
        return stackView
    }()
    
    
    lazy var scrollView : UIScrollView = {
        let scrollView = UIScrollView()
//
//        scrollView.delegate = self
//        scrollView.translatesAutoresizingMaskIntoConstraints = false
//        scrollView.alwaysBounceHorizontal = true
//        scrollView.showsHorizontalScrollIndicator = false
//
        scrollView.backgroundColor = .brown
        return scrollView
    }()
    
    lazy var currentIndicator : UIView = {
        let view = UIView()
        view.backgroundColor = .tintColor
        
        return view
    }()
    
    lazy var timerLabel : UILabel = {
        let lbl = UILabel()
        lbl.text = "00:00.00"
        lbl.textColor = .label
        lbl.font = .systemFont(ofSize: 45, weight: .semibold)
        
        return lbl
    }()
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setLayout()
        configureTimeAndView()
        addNotificationObserver()
        adminTimer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    func configureTimeAndView() {
        currentTimeLabel.text = TimeIntervalToString(playerController.player.currentTime)
        DurationLabel.text = TimeIntervalToString(playerController.player.duration)
        timerLabel.text = TimerLabelString(playerController.player.currentTime)
        slider.minimumValue = 0
        slider.maximumValue = Float(playerController.player.duration)
        slider.value = Float(playerController.player.currentTime)
    }
    
    func TimeIntervalToString(_ time:TimeInterval) -> String {
        let min = Int(time/60)
        let sec = Int(time.truncatingRemainder(dividingBy: 60))
        let strTime = String(format: "%02d:%02d", min, sec)
        return strTime
    }
    
    func TimerLabelString(_ time:TimeInterval) -> String {
        let min = Int(time/60)
        let sec = Int(time.truncatingRemainder(dividingBy: 60))
        let micro = (Int((time*100).truncatingRemainder(dividingBy: 100)))
        let strTime = String(format: "%02d:%02d.%02d", min, sec, micro)
        return strTime
    }
    
    
}

// timer observer functions
extension PlayerUpperView {
    // playerController 에서 status가 변할 때마다 noti를 보낸다.
    func addNotificationObserver() {
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(adminTimer),
            name: Notification.Name("playerStatusChanged"),
            object: nil
        )
    }
    
    // noti를 받으면 status에 따라 timer에 0.01단위의 schedule을 설정
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
    
    // 0.01초마다 업데이트
    @objc func updatePlayTime() {
        currentTimeLabel.text = TimeIntervalToString(playerController.player.currentTime)
        timerLabel.text = TimerLabelString(playerController.player.currentTime)
        slider.value = Float(playerController.player.currentTime)
    }
}


// PlayerUpperView UI
extension PlayerUpperView {
    private func setLayout() {
        
        [sliderContainer, upperControllerSV, scrollView, currentIndicator, timerLabel].forEach{
            addSubview($0)
        }
        
        
        [slider, currentTimeLabel, DurationLabel].forEach{
            sliderContainer.addSubview($0)
        }
        
        sliderContainer.snp.makeConstraints{
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalToSuperview().inset(15)
            $0.height.equalTo(30)
        }
        slider.snp.makeConstraints{
            $0.leading.trailing.equalToSuperview()
            $0.centerY.equalTo(sliderContainer)
        }
        currentTimeLabel.snp.makeConstraints{
            $0.leading.equalToSuperview()
            $0.top.equalTo(slider.snp.bottom).offset(5)
        }
        DurationLabel.snp.makeConstraints{
            $0.trailing.equalToSuperview()
            $0.top.equalTo(slider.snp.bottom).offset(5)
        }

        upperControllerSV.snp.makeConstraints{
            $0.top.equalTo(sliderContainer.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        scrollView.snp.makeConstraints{
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(upperControllerSV.snp.bottom).offset(20)
            $0.bottom.equalTo(timerLabel.snp.top).offset(-20)
        }
        
        currentIndicator.snp.makeConstraints{
            $0.bottom.top.equalTo(scrollView)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(1)
        }
        
        timerLabel.snp.makeConstraints{
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.width.equalTo(195)
            $0.height.equalTo(60)
        }
    }
}


