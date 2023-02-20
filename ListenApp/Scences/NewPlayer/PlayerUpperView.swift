//
//  PlayerUpperView.swift
//  ListenApp
//
//  Created by 곽지혁 on 2023/01/27.
//

import UIKit
//import DSWaveformImage

class PlayerUpperView : UIView {
    let playerController = PlayerController.playerController
    var audio = PlayerController.playerController.audio!
    var timer : Timer?
    
    let changedAmountPerSec = PlayerController.playerController.changedAmountPerSec
    let waveImageSize = 1000
    
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
    
    let Abutton = UIButton()
    let backToAbutton = UIButton()
    let Bbutton = UIButton()
    let trashButton = UIButton()
    
    lazy var upperControllerSV : UIStackView = {
        let stackView = UIStackView()
        
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        
        stackView.tintColor = .label
        
        let waveRepeatButton = UIButton()
        let speedButton = UIButton()
        
        let repeatImageConfig = UIImage.SymbolConfiguration(font: .systemFont(ofSize: 20), scale: .default)
        let speedTitle = UILabel()
        
        Abutton.setImage(UIImage(systemName: "a.square", withConfiguration: repeatImageConfig), for: .normal)
        backToAbutton.setImage(UIImage(systemName: "chevron.backward.2", withConfiguration: repeatImageConfig), for: .normal)
        trashButton.setImage(UIImage(systemName: "trash.circle", withConfiguration: repeatImageConfig), for: .normal)
        Bbutton.setImage(UIImage(systemName: "b.square", withConfiguration: repeatImageConfig), for: .normal)
        
        Abutton.addTarget(self, action: #selector(tapAButton), for: .touchUpInside)
        backToAbutton.addTarget(self, action: #selector(tapBackToAButton), for: .touchUpInside)
        Bbutton.addTarget(self, action: #selector(tapBButton), for: .touchUpInside)
        trashButton.addTarget(self, action: #selector(taptrashButton), for: .touchUpInside)
        
        backToAbutton.isEnabled = false
        Bbutton.isEnabled = false
        trashButton.isEnabled = false
        
        speedButton.setTitle("1.0x", for: .normal)
        speedButton.setTitleColor(.label, for: .normal)
        speedButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .regular)
        
        [Abutton, backToAbutton, trashButton, Bbutton].forEach{
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
        
//        scrollView.backgroundColor = .systemGray5
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
        
        
        setImgOnScrollSV(waveImageIdxList: [-1, -1])
        setImgOnScrollSV(waveImageIdxList: waveImageIdxList)
    }
}

// repeat button functions
extension PlayerUpperView {
    
    @objc private func tapAButton() {
        if playerController.positionA == nil {
            // A위치 설정
            let x = Int(scrollView.contentOffset.x)
            if nowImageIdx == 0 {
                playerController.positionA = x
            } else {
                let totalWidth = Int(waveImageSize * (nowImageIdx-1)) + x
                playerController.positionA = totalWidth
            }
            
            Abutton.tintColor = .red
            // backToA, B 클릭 가능하게
            backToAbutton.isEnabled = true
            Bbutton.isEnabled = true
            trashButton.isEnabled = true
        } else {
            // A 위치 설정 해제
            playerController.positionA = nil
            Abutton.tintColor = .label
            // backToA, B 클릭 불가능하게
            backToAbutton.isEnabled = false
            Bbutton.isEnabled = false
            trashButton.isEnabled = false
        }
        
        // wave image업데이트
        resetScrollStackView()
    }
    
    @objc private func tapBackToAButton() {
        if playerController.positionA != nil {
            playerController.changePlayerTime(changedTime: Double(playerController.positionA!) / changedAmountPerSec)
        }
        
        // wave image업데이트
        resetScrollStackView()
    }
    
    @objc private func taptrashButton() {
        playerController.shouldABRepeat = false
        playerController.positionA = nil
        playerController.positionB = nil
        
        Abutton.tintColor = .label
        Bbutton.tintColor = .label
        
        Abutton.isEnabled = true
        backToAbutton.isEnabled = false
        Bbutton.isEnabled = false
        trashButton.isEnabled = false
        
        resetScrollStackView()
    }
    
    
    @objc private func tapBButton() {
        // B 위치 설정
        if playerController.positionB == nil {
            let x = Int(scrollView.contentOffset.x)
            if nowImageIdx == 0 { playerController.positionB = x }
            else {
                let totalWidth = Int(waveImageSize * (nowImageIdx-1)) + x
                playerController.positionB = totalWidth
            }
            
            Bbutton.tintColor = .blue
            
            // 시간 설정
            playerController.player.currentTime = Double(playerController.positionA!) / changedAmountPerSec
            playerController.shouldABRepeat = true
            
            Abutton.isEnabled = false
        } else {
            playerController.positionB = nil
            Bbutton.tintColor = .label
            
            playerController.shouldABRepeat = false
            
            Abutton.isEnabled = false
            Bbutton.isEnabled = true
            backToAbutton.isEnabled = true
            trashButton.isEnabled = true
        }
        
        // wave image업데이트
        resetScrollStackView()
        
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
//            case -2:
//                scrollStackView.addArrangedSubview(drawEntireWaveImage())
            default:
                scrollStackView.appendWaveImg(view: drawWaveImage(idx : $0))
            }
        }
    }
    
    // int에 맞추어 waveAnalysis의 구간을 설정해 draw
//    func drawEntireWaveImage() -> UIImageView {
//        let waveImgView = UIImageView()
//        waveImgView.contentMode = .scaleToFill
//
//        let waveformImageDrawer = WaveformImageDrawer()
//        let target = audio.waveAnalysis
//        let width = target.count
//        let height = Int(UIScreen.main.bounds.size.height) - 345
//
//        let image = waveformImageDrawer.waveformImage(from: target, with: .init(
//            size : CGSize(width: width, height: height),
//            style: .striped(.init(color: .label)),
//            dampening: nil,
//            scale: 1,
//            verticalScalingFactor: 0.5 )
//        )
//        waveImgView.image = image ?? UIImage()
//        waveImgView.tag = -2
//        return waveImgView
//    }
    
    // int에 맞추어 waveAnalysis의 구간을 설정해 draw
    func drawWaveImage(idx : Int) -> UIImageView {
        let waveImgView = UIImageView()
        waveImgView.contentMode = .scaleToFill
        
        let waveformImageDrawer = MyWaveformImageDrawer()
        
        let height = Int(UIScreen.main.bounds.size.height) - 345
        let scale = 1
        
        // target범위가 waveAnalysis 분석 개수 넘지 않도록
        var target = idx*waveImageSize..<(idx+1)*waveImageSize
        if audio.waveAnalysis.count < target.lowerBound {
            print(audio.waveAnalysis.count, target.lowerBound, target.upperBound, "dont make")
            return waveImgView
        } else if audio.waveAnalysis.count < target.upperBound {
            target = idx*waveImageSize..<audio.waveAnalysis.count
            print(audio.waveAnalysis.count, target.lowerBound, target.upperBound, "partically made")
        }
        let width = target.count
        
        let image = waveformImageDrawer.waveformImage(from: target, with: .init(
            size : CGSize(width: width, height: height),
            backgroundColor: UIColor.systemGray5,
            stripeConfig: .init(color: .label, width: 1, spacing: 4),
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
        
        let waveformImageDrawer = MyWaveformImageDrawer()
        
        let width = Int(UIScreen.main.bounds.size.width / 2)
        let height = Int(UIScreen.main.bounds.size.height) - 345
        let scale = 1
        
        let image = waveformImageDrawer.drawEmptyImage(with: .init(
            size : CGSize(width: width, height: height),
            backgroundColor: UIColor.systemGray5,
            stripeConfig: .init(color: .label, width: 1, spacing: 5),
            dampening: nil,
            scale: CGFloat(scale),
            verticalScalingFactor: 0.5 )
        )
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
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(resetScrollStackView),
            name: Notification.Name("playerScrollViewReset"),
            object: nil
        )
        
        completion()
    }
    
    // ScrollStackView 재구성
    @objc func resetScrollStackView() {
        scrollStackView.removeFullySubviews()
        audio.currentTime = playerController.player.currentTime
        configureWaveImgView()
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
    
    // scrollView의 x좌표 변화가 생겼을 때 scrollStackView의 waveimage 관리
    private func updateScrollStackView(newImageIdx : Int, nx : Double){
        if newImageIdx != nowImageIdx {
            // 패치 저장된 내용 사용하기
            if abs(newImageIdx - nowImageIdx) < 3 && newImageIdx < nowImageIdx {
                audio.currentTime = playerController.player.currentTime
                prefetchPrevious(newImageIdx : newImageIdx)
            }
            else if abs(newImageIdx - nowImageIdx) < 3 && newImageIdx > nowImageIdx {
                audio.currentTime = playerController.player.currentTime
                prefetchNext(newImageIdx : newImageIdx)
            }
            // slider or 새로 오디오 재생
            else {
                resetScrollStackView()
            }
            
            nowImageIdx = newImageIdx
        }
    }
    
    // player currentTime에 맞추어 시간 label들 관리 및 scrollView 위치이동
    @objc func updatePlayTime() {
        // 끝까지 다 재생되었다면
        if audio.duration - 0.02 <= playerController.player.currentTime {
            playerController.rePlayPlayer()
            return
        }
        
        let targetAnalysis = Double(playerController.player.currentTime * changedAmountPerSec)
        
        // ab반복 여부 체크
        if playerController.shouldABRepeat == true && (Int(targetAnalysis) + 2 < playerController.positionA! || playerController.positionB! < Int(targetAnalysis)) {
            if let timer = timer {
                if timer.isValid { timer.invalidate() }
            }
            playerController.changePlayerTime(changedTime: Double(playerController.positionA!) / changedAmountPerSec)
        }
        
        // wave 반복 여부 체크
        if playerController.shouldSectionRepeat == true && (Int(targetAnalysis) + 2 < playerController.positionSectionStart! || playerController.positionSectionEnd! < Int(targetAnalysis)) {
            if let timer = timer {
                if timer.isValid { timer.invalidate() }
            }
            playerController.changePlayerTime(changedTime: Double(playerController.positionSectionStart!) / changedAmountPerSec)
        }
        
        
        let newImageIdx = Int(targetAnalysis / Double(waveImageSize))
        let nx = (newImageIdx == 0) ? targetAnalysis : (targetAnalysis - Double(waveImageSize * newImageIdx) + Double(waveImageSize))
        
        // label들 시간 업데이트
        updateTimeLabel(time: playerController.player.currentTime)
        
        // nx에 따른 scrollStackView 관리
        updateScrollStackView(newImageIdx: newImageIdx, nx: nx)
        
        // scrollView 좌표 업데이트
        scrollView.contentOffset = CGPointMake(nx, 0)
        
    }
    
    func prefetchPrevious(newImageIdx : Int) {
        if newImageIdx == 0 && nowImageIdx == 1 { return }
        
        let diff = abs(newImageIdx - nowImageIdx)
        for _ in 0..<diff {
            scrollStackView.popWaveImg()
            scrollStackView.appendLeftWaveImg(view : drawWaveImage(idx: scrollStackView.firstViewTag() - 1 ))
        }
    }
        
    func prefetchNext(newImageIdx : Int) {
        if newImageIdx == 1 { return }
        let diff = abs(newImageIdx - nowImageIdx)
        for _ in 0..<diff {
            scrollStackView.popLeftWaveImg()
            scrollStackView.appendWaveImg(view : drawWaveImage(idx: scrollStackView.lastViewTag() + 1 ))
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
            
            // 잠시 멈춤이라면 재생
            if playerController.status == .intermit {
                playerController.playPlayer()
            }
            
        }
    }
    
    // 끄는 동작 끝날 때 플레이어 시간 업데이트
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let x = Double(scrollView.contentOffset.x)
        if nowImageIdx == 0 { playerController.changePlayerTime(changedTime : TimeInterval(x / changedAmountPerSec))}
        else {
            let totalWidth = Double(waveImageSize * (nowImageIdx-1)) + x
            playerController.changePlayerTime(changedTime : TimeInterval(totalWidth / changedAmountPerSec))
        }
        
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
            $0.top.equalTo(scrollView).inset(14)
            $0.bottom.equalTo(scrollView).inset(14)
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
