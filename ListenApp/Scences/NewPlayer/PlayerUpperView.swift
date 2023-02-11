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
    var audio = PlayerController.playerController.audio!
    var timer : Timer?
    
    let changedAmountPerSec = 65.0
    let waveImageSize = 500
    
    var nowImageIdx = 0
    var maxImageIdx = 0
    
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
        scrollView.decelerationRate = .fast
        
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
        slider.addTarget(self, action: #selector(onSliderValChanged(slider:event:)), for: .valueChanged)
    }
    
    func configureWaveImgView() {
        print(audio.waveAnalysis.count)
        print(audio.duration, audio.duration * 65)
        nowImageIdx = Int(audio.currentTime * changedAmountPerSec / Double(waveImageSize))
        maxImageIdx = audio.waveAnalysis.count / waveImageSize
        
        var waveImageIdxList : [Int] = []

        if maxImageIdx < 3 {
            waveImageIdxList = [-2]
        }
        else{
            switch nowImageIdx{
            case 0:
                waveImageIdxList = [0, 1, 2]
            case maxImageIdx:
                waveImageIdxList = [maxImageIdx - 2, maxImageIdx - 1, maxImageIdx]
            default:
                waveImageIdxList = [nowImageIdx - 1, nowImageIdx, nowImageIdx + 1]
            }
        }
        
        print("idx \(nowImageIdx), maxidx \(maxImageIdx)")
        print(waveImageIdxList)
        
        setImgOnScrollSV(waveImageIdxList: [-1, -1])
        setImgOnScrollSV(waveImageIdxList: waveImageIdxList)
    }
}



// draw and set Image for scrollView
extension PlayerUpperView {
    // int 배열에 맞추어 waveImage 생성 후 scrollStackView에 추가
    func setImgOnScrollSV(waveImageIdxList : [Int]) {
        waveImageIdxList.forEach{
            switch $0{
            case -1:
                scrollStackView.addArrangedSubview(drawEmptyIamge())
            case -2:
                scrollStackView.addArrangedSubview(drawEntireWaveImage())
            default:
                scrollStackView.appendWaveImg(view: drawWaveImage(idx : $0))
            }
        }
        scrollStackView.checkSubViews()
    }
    
    // int에 맞추어 waveAnalysis의 구간을 설정해 draw
    func drawEntireWaveImage() -> UIImageView {
        let waveImgView = UIImageView()
        waveImgView.contentMode = .scaleToFill
        
        let waveformImageDrawer = WaveformImageDrawer()
        let target = audio.waveAnalysis
        let width = target.count
        let height = Int(UIScreen.main.bounds.size.height) - 345
        
        let image = waveformImageDrawer.waveformImage(from: target, with: .init(
            size : CGSize(width: width, height: height),
            style: .striped(.init(color: .label)),
            dampening: nil,
            scale: 1,
            verticalScalingFactor: 0.5 )
        )
        waveImgView.image = image ?? UIImage()
        waveImgView.tag = -2
        return waveImgView
    }
    
    // int에 맞추어 waveAnalysis의 구간을 설정해 draw
    func drawWaveImage(idx : Int) -> UIImageView {
        let waveImgView = UIImageView()
        waveImgView.contentMode = .scaleToFill
        
        let waveformImageDrawer = WaveformImageDrawer()
        let target = Array(audio.waveAnalysis[idx*waveImageSize..<(idx+1)*waveImageSize])
        print("draw \(idx) target \(idx*waveImageSize) .. \((idx+1)*waveImageSize)")
        let scale = 1
        let width = target.count / scale
        let height = Int(UIScreen.main.bounds.size.height) - 345
        
        let image = waveformImageDrawer.waveformImage(from: target, with: .init(
            size : CGSize(width: width, height: height),
            style: .striped(.init(color: .label)),
            dampening: nil,
            scale: CGFloat(scale),
            verticalScalingFactor: 0.5 )
        )
        waveImgView.image = image ?? UIImage()
        waveImgView.tag = idx
        return waveImgView
    }
    
    // 전체 width의 절반에 맞추어 빈 이미지 생성
    func drawEmptyIamge() -> UIImageView {
        let waveImgView = UIImageView()
        waveImgView.contentMode = .scaleToFill
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        
        let width = Int(UIScreen.main.bounds.size.width / 2)
        let height = Int(UIScreen.main.bounds.size.height) - 345
        let size = CGSize(width: width, height: height)
        
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        
        let image =  renderer.image { renderContext in
            let context = renderContext.cgContext
            context.setFillColor(UIColor.systemGray6.cgColor)
            context.fill(CGRect(origin: CGPoint.zero, size: size))
        }
        
        waveImgView.image = image
        waveImgView.tag = -1
        return waveImgView
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
    
    
    // 시간 라벨들 업데이트 함수
    private func updateTimeLabel(time : TimeInterval) {
        currentTimeLabel.text = time.toString()
        timerLabel.text = time.toStringContainMilisec()
        slider.value = Float(time)
    }
    
    // scrollView의 x좌표 이동시 scrollStackView의 waveimage 관리
    private func updateScrollStackView(newImageIdx : Int, nx : Double){
        if newImageIdx != nowImageIdx {
            // 패치 저장된 내용 사용하기
            if abs(newImageIdx - nowImageIdx) < 3 && newImageIdx < nowImageIdx {
                print("previou")
                print("nowImageIdx \(nowImageIdx) newImageIdx \(newImageIdx)")
                audio.currentTime = playerController.player.currentTime
                prefetchPrevious(newImageIdx : newImageIdx)
//                print("ori \(targetAnalysis) new \(nx)")
            }
            else if abs(newImageIdx - nowImageIdx) < 3 && newImageIdx > nowImageIdx {
                print("next")
                print("nowImageIdx \(nowImageIdx) newImageIdx \(newImageIdx)")
                audio.currentTime = playerController.player.currentTime
                prefetchNext(newImageIdx : newImageIdx)
//                print("ori \(targetAnalysis) new \(nx)")
            }
            // slider or 새로 오디오 재생
            else {
                print("reset")
                print("nowImageIdx \(nowImageIdx) newImageIdx \(newImageIdx)")
                scrollStackView.removeFullySubviews()
                audio.currentTime = playerController.player.currentTime
                configureWaveImgView()
//                print("ori \(targetAnalysis) new \(nx)")
            }
            
            nowImageIdx = newImageIdx
        }
    }
    
    // player currentTime에 맞추어 시간 label들 관리 및 scrollView 위치이동
    @objc func updatePlayTime() {
        updateTimeLabel(time: playerController.player.currentTime)
        
        let targetAnalysis = Double(playerController.player.currentTime * changedAmountPerSec)
        let newImageIdx = Int(targetAnalysis / Double(waveImageSize))
        let nx = (newImageIdx == 0) ? targetAnalysis : (targetAnalysis - Double(waveImageSize * newImageIdx) + Double(waveImageSize) + 4.0)
        
        // nx에 따른 scrollStackView 관리
        updateScrollStackView(newImageIdx: newImageIdx, nx: nx)
        
        // scrollView 좌표 업데이트
        scrollView.contentOffset = CGPointMake(nx, 0)
        
    }
    
    func prefetchPrevious(newImageIdx : Int) {
        if newImageIdx == 0 && nowImageIdx == 1 { return }
        
        let diff = abs(newImageIdx - nowImageIdx)
        for i in 0..<diff {
            print("i \(i) newImageIdx \(newImageIdx)")
            scrollStackView.popWaveImg()
            scrollStackView.appendLeftWaveImg(view : drawWaveImage(idx: scrollStackView.firstViewTag() - 1 ))
        }
        
        print("prefetchPrevious")
        scrollStackView.arrangedSubviews.forEach{
            print($0.tag)
        }
    }
        
    func prefetchNext(newImageIdx : Int) {
        print("prefetch")
        if newImageIdx == 1 { return }
        print("isnot 1")
        let diff = abs(newImageIdx - nowImageIdx)
        for i in 0..<diff {
            print("i \(i) newImageIdx \(newImageIdx)")
            scrollStackView.popLeftWaveImg()
            scrollStackView.appendWaveImg(view : drawWaveImage(idx: scrollStackView.lastViewTag() + 1 ))
        }
        
        print("prefetchNext")
        scrollStackView.arrangedSubviews.forEach{
            print($0.tag, $0.intrinsicContentSize)
        }
    }
    
}


// slider 동작 인식
extension PlayerUpperView {
    @objc func onSliderValChanged(slider: UISlider, event: UIEvent) {
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .began:
                // 슬라이더 드래그 시작할 때 재생중이라면 플레이어 잠시 멈춤
                if playerController.status == .play {
                    playerController.intermitPlayer()
                }
            case .moved:
                // 슬라이더 드래그 중에 value에 맞추어 player 시간 업데이트
                if let timer = timer { if timer.isValid { return }}
//                playerController.changePlayerTime(changedTime : Double(slider.value))
            case .ended:
                // 슬라이더 드래그 끝날 때 플레이어 잠시 멈춤이라면 재생
                if let timer = timer { if timer.isValid { return }}
                playerController.changePlayerTime(changedTime : Double(slider.value))
                if playerController.status == .intermit {
                    playerController.playPlayer()
                }
            default:
                break
            }
        }
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
    
    // 드래그에 위치에 따라 시간 라벨들 업데이트 및 waveStackView 업데이트
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let timer = timer { if timer.isValid { return }}
        
        var x = Double(scrollView.contentOffset.x)
        var newImageIdx = nowImageIdx
        let waveSize = Double(waveImageSize)
        
        print("x", x)
        if nowImageIdx == 0 {
            updateTimeLabel(time: TimeInterval(x / changedAmountPerSec))
            
            if x > waveSize {
                newImageIdx += 1
            }
        }
        else {
            let totalWidth = Double(waveImageSize * (nowImageIdx-1)) + x
            updateTimeLabel(time: TimeInterval(totalWidth / changedAmountPerSec))
            
            if x < waveSize {
                x += waveSize
                newImageIdx -= 1
            }
            else if x > waveSize * 2 {
                x -= waveSize
                newImageIdx += 1
            }
        }
        print("nx", x)
        updateScrollStackView(newImageIdx: newImageIdx, nx: x)
    }
    
    // 드래그 끝날 때 끄는 동작 없다면 플레이어 시간 업데이트
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false {
            let x = Double(scrollView.contentOffset.x)
            if nowImageIdx == 0 { playerController.changePlayerTime(changedTime : TimeInterval(x / changedAmountPerSec)) }
            else {
                let totalWidth = Double(waveImageSize * (nowImageIdx-1)) + x
                playerController.changePlayerTime(changedTime : TimeInterval(totalWidth / changedAmountPerSec))
            }
            
            updatePlayTime()
            
            // 잠시 멈춤이라면 재생
            if playerController.status == .intermit {
                playerController.playPlayer()
            }
            
        }
    }
    
    // 끄는 동작 끝날 때 플레이어 시간 업데이트
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let x = Double(scrollView.contentOffset.x)
        if nowImageIdx == 0 { playerController.changePlayerTime(changedTime : TimeInterval(x / changedAmountPerSec)) }
        else {
            let totalWidth = Double(waveImageSize * (nowImageIdx-1)) + x
            playerController.changePlayerTime(changedTime : TimeInterval(totalWidth / changedAmountPerSec))
        }
        
        updatePlayTime()
        
        // 잠시 멈춤이라면 재생
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
