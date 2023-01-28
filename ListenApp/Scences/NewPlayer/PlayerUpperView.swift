//
//  PlayerUpperView.swift
//  ListenApp
//
//  Created by 곽지혁 on 2023/01/27.
//

import UIKit
import DSWaveformImage

class PlayerUpperView : UIView {
    let playerController = PlayerController.playerController
    var timer : Timer?
    
    private var slider : UISlider = {
        let slider = UISlider()
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
    
    
    lazy var leftView = UIView()
    lazy var rightView = UIView()
    lazy var imageView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = playerController.audio!.waveImage
        imageView.contentMode = .scaleAspectFill

        return imageView
    }()
    
    lazy var contentStackView : UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    
    lazy var scrollView : UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceHorizontal = true
        scrollView.showsHorizontalScrollIndicator = false
        
        scrollView.backgroundColor = .systemGray5
        
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
        currentTimeLabel.text = playerController.player.currentTime.toString()
        DurationLabel.text = playerController.player.duration.toString()
        timerLabel.text = playerController.player.currentTime.toStringContainMilisec()
        slider.minimumValue = 0
        slider.maximumValue = Float(playerController.player.duration)
        slider.value = Float(playerController.player.currentTime)
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
    
    // 0.01초마다 업데이트 시간 label들과 scrollView위치이동
    @objc func updatePlayTime() {
        currentTimeLabel.text = playerController.player.currentTime.toString()
        timerLabel.text = playerController.player.currentTime.toStringContainMilisec()
        slider.value = Float(playerController.player.currentTime)
        
        let nx = playerController.player.currentTime * 5
        scrollView.contentOffset = CGPointMake(nx, 0);
    }
}


// 스크롤 동작 인식
extension PlayerUpperView : UIScrollViewDelegate {
    // 드래그 시작할 때 재생중이라면 플레이어 잠시 멈춤
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if playerController.status == .play {
            playerController.intermitPlayer()
        }
    }
    
    // 드래그 끝날 때 끄는 동작 없고 플레이어 잠시 멈춤이라면 재생
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false && playerController.status == .intermit {
            playerController.playPlayer()
        }
    }
    
    //드래그에 따라 시간 이동
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let timer = timer { if timer.isValid { return }}
        
        let x = Double(scrollView.contentOffset.x)
        playerController.changePlayerTime(changedTime : TimeInterval(x / 5))
    }
    
    // 끄는 동작 끝날 때 플레이어 잠시 멈춤이라면 재생
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if playerController.status == .intermit {
            playerController.playPlayer()
        }
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
        
        
        scrollView.addSubview(contentStackView)
        
        scrollView.snp.makeConstraints{
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(upperControllerSV.snp.bottom).offset(20)
            $0.bottom.equalTo(timerLabel.snp.top).offset(-20)
        }
        
        contentStackView.snp.makeConstraints{
            $0.top.bottom.leading.trailing.height.equalTo(scrollView)
        }
        
        [leftView, imageView, rightView].forEach{
            contentStackView.addArrangedSubview($0)
        }
        
        
        leftView.backgroundColor = .systemGray6
        
        leftView.snp.makeConstraints{
            $0.height.equalToSuperview()
            $0.width.equalTo(scrollView).multipliedBy(0.5)
        }
        
//        imageView.snp.makeConstraints{
//            $0.height.equalToSuperview()
//            $0.width.equalTo(scrollView)
//        }
        
        rightView.snp.makeConstraints{
            $0.height.equalToSuperview()
            $0.width.equalTo(scrollView).multipliedBy(0.5)
        }
        
        
        
        currentIndicator.snp.makeConstraints{
            $0.bottom.top.equalTo(scrollView)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(1)
        }
        
        timerLabel.snp.makeConstraints{
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.width.equalTo(197)
            $0.height.equalTo(60)
        }
    }
}


