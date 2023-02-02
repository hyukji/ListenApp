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
    let audio = PlayerController.playerController.audio!
    var timer : Timer?
    
    let changedAmountPerSec = 65.0
    let waveImageSize = 500
    
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
        
        let repeatImageConfig = UIImage.SymbolConfiguration(font: .systemFont(ofSize: 20), scale: .default)
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
    
    lazy var scrollStackView : UIStackView = {
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
        configureWaveImgView()
        configureTimeAndView()
        addNotificationObserver(){
            self.playerController.playPlayer()
        }
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
    
    func configureWaveImgView() {
        let idx = Int(audio.currentTime * changedAmountPerSec / Double(waveImageSize))
        let maxIdx = audio.waveAnalysis.count / waveImageSize
        var waveImageIdxList : [Int] = []
        
        if maxIdx < 1 {
            waveImageIdxList = [-1, 0]
        }
        else{
            switch idx{
            case 0:
                waveImageIdxList = [-1, 0, 1]
            case maxIdx:
                waveImageIdxList = [maxIdx - 1, maxIdx, -1]
            default:
                waveImageIdxList = [idx - 1, idx, idx + 1]
            }
        }
        print("idx \(idx), maxidx \(maxIdx)")
        print(waveImageIdxList)
        
        setImgOnScrollSV(waveImageIdxList: waveImageIdxList)
    }
}



// draw and set Image for scrollView
extension PlayerUpperView {
    // int 배열에 맞추어 waveImage 생성 후 scrollStackView에 추가
    func setImgOnScrollSV(waveImageIdxList : [Int]) {
        waveImageIdxList.forEach{
            let waveImgView = UIImageView()
            waveImgView.contentMode = .scaleToFill
            switch $0{
            case -1:
                waveImgView.image = drawEmptyIamge()
            default:
                waveImgView.image = drawWaveImage(idx : $0)
            }
            scrollStackView.addArrangedSubview(waveImgView)
        }
    }
    
    // int에 맞추어 waveAnalysis의 구간을 설정해 draw
    func drawWaveImage(idx : Int) -> UIImage {
        let waveformImageDrawer = WaveformImageDrawer()
        let target = Array(audio.waveAnalysis[idx*waveImageSize...(idx+1)*waveImageSize])
        let width = target.count
        let height = Int(UIScreen.main.bounds.size.height) - 345
        
        let image = waveformImageDrawer.waveformImage(from: target, with: .init(
            size : CGSize(width: width, height: height),
            style: .striped(.init(color: .label)),
            dampening: nil,
            scale: 1,
            verticalScalingFactor: 0.5 )
        )
        return image ?? UIImage()
    }
    
    // 전체 width의 절반에 맞추어 빈 이미지 생성
    func drawEmptyIamge() -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        
        let width = Int(UIScreen.main.bounds.size.width / 2)
        let height = Int(UIScreen.main.bounds.size.height) - 345
        let size = CGSize(width: width, height: height)
        
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        
        return renderer.image { renderContext in
            let context = renderContext.cgContext
            context.setFillColor(UIColor.systemGray6.cgColor)
            context.fill(CGRect(origin: CGPoint.zero, size: size))
        }
    }
    
}


// timer observer functions
extension PlayerUpperView {
    // playerController 에서 status가 변할 때마다 noti를 보낸다.
    func addNotificationObserver(completion : @escaping () -> Void) {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(adminTimer),
            name: Notification.Name("playerStatusChanged"),
            object: nil
        )
        completion()
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
        
        let nx = playerController.player.currentTime * changedAmountPerSec
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
        playerController.changePlayerTime(changedTime : TimeInterval(x / changedAmountPerSec))
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
            $0.top.equalTo(sliderContainer).offset(10)
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
            $0.top.equalTo(sliderContainer.snp.bottom).offset(15)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(30)
        }
        
        
        scrollView.addSubview(scrollStackView)
        scrollView.snp.makeConstraints{
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(upperControllerSV.snp.bottom).offset(20)
            $0.bottom.equalTo(timerLabel.snp.top).offset(-20)
        }
        scrollStackView.snp.makeConstraints{
            $0.top.bottom.leading.trailing.height.equalTo(scrollView)
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
