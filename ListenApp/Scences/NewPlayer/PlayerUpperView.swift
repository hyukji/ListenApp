////
////  PlayerUpperView.swift
////  ListenApp
////
////  Created by 곽지혁 on 2023/01/27.
////
//
//import UIKit
//
//
//class PlayerUpperView : UIView {
//    let playerController = PlayerController.playerController
//    var audio = PlayerController.playerController.audio!
//    var timer : Timer?
//
//    let changedAmountPerSec = PlayerController.playerController.changedAmountPerSec
//    let waveImageSize = 1000
//    let sectionCount = PlayerController.playerController.audio!.sectionStart.count
//    let windowWidth = UIScreen.main.bounds.size.width
//
//    var nowSectionIdx = 0
//    var leftSectionIdx = 0
//    var rightSectionIdx = 0
//
//    var repeatTerm = 0.5
//
//    private var slider : UISlider = {
//        let slider = UISlider()
//        slider.tintColor = .tintColor
////        slider.transform = CGAffineTransform(scaleX: 1, y: 1.5)
//        slider.setThumbImage(UIImage(), for: .normal)
//
//        return slider
//    }()
//
//    lazy var currentTimeLabel : UILabel = {
//        let label = UILabel()
//        label.font = .systemFont(ofSize: 10)
//        label.textColor = .tintColor
//
//        return label
//    }()
//
//    lazy var DurationLabel : UILabel = {
//        let label = UILabel()
//        label.font = .systemFont(ofSize: 10)
//        label.textColor = .lightGray
//
//        return label
//    }()
//
//    private lazy var sliderContainer = UIView()
//
//    let Abutton = UIButton()
//    let backToAbutton = UIButton()
//    let Bbutton = UIButton()
//    let trashButton = UIButton()
//
//    lazy var upperControllerSV : UIStackView = {
//        let stackView = UIStackView()
//
//        stackView.axis = .horizontal
//        stackView.alignment = .center
//        stackView.distribution = .fillEqually
//
//        stackView.tintColor = .label
//
//        let imageConfig = UIImage.SymbolConfiguration(font: .systemFont(ofSize: 20), scale: .default)
//
//        Abutton.setImage(UIImage(systemName: "a.square", withConfiguration: imageConfig), for: .normal)
//        backToAbutton.setImage(UIImage(systemName: "chevron.backward.2", withConfiguration: imageConfig), for: .normal)
//        trashButton.setImage(UIImage(systemName: "trash.circle", withConfiguration: imageConfig), for: .normal)
//        Bbutton.setImage(UIImage(systemName: "b.square", withConfiguration: imageConfig), for: .normal)
//
//        Abutton.addTarget(self, action: #selector(tapAButton), for: .touchUpInside)
//        backToAbutton.addTarget(self, action: #selector(tapBackToAButton), for: .touchUpInside)
//        Bbutton.addTarget(self, action: #selector(tapBButton), for: .touchUpInside)
//        trashButton.addTarget(self, action: #selector(taptrashButton), for: .touchUpInside)
//
//        if playerController.shouldABRepeat {
//            if (playerController.positionA != nil && playerController.positionB != nil) {
//                setUpperControllerSVButton(status: .ABboth)
//            }
//            else {
//                playerController.shouldABRepeat = false
//                setUpperControllerSVButton(status : .none)
//                print("!!!!!!!!!!!!!!!!!!!!!!!!!! shouldABrepeat이 true인데 a,b 좌표 없음 !!!!!!!!!!!!!!!!!!!!!!")
//            }
//        } else if (playerController.positionA != nil) {
//            // a 만 설정되어 있다면
//            setUpperControllerSVButton(status: .onlyA)
//        } else {
//            setUpperControllerSVButton(status : .none)
//        }
//
//        [Abutton, backToAbutton, trashButton, Bbutton].forEach{
//            stackView.addArrangedSubview($0)
//        }
//
//        return stackView
//    }()
//
//    lazy var scrollStackView : MyWaveImgStackView = {
//        let stackView = MyWaveImgStackView()
//        stackView.axis = .horizontal
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//
//        return stackView
//    }()
//
//    lazy var scrollView : UIScrollView = {
//        let scrollView = UIScrollView()
//        scrollView.delegate = self
//        scrollView.translatesAutoresizingMaskIntoConstraints = false
//        scrollView.alwaysBounceHorizontal = true
//        scrollView.showsHorizontalScrollIndicator = false
//
////        scrollView.backgroundColor = .systemGray5
//        scrollView.decelerationRate = .fast
//
//        return scrollView
//    }()
//
//    lazy var currentIndicator : UIView = {
//        let view = UIView()
//        view.backgroundColor = .tintColor
//
//        return view
//    }()
//
//    lazy var timerLabel : UILabel = {
//        let lbl = UILabel()
//        lbl.text = "00:00.00"
//        lbl.textColor = .label
//        lbl.font = .systemFont(ofSize: 45, weight: .semibold)
//
//        return lbl
//    }()
//
//
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//
//        setLayout()
//        configureWaveImgView()
//        configureTimeAndView()
//        addNotificationObserver(){
//            self.playerController.playPlayer()
//        }
//        repeatTerm = getRepeatTerm()
//        print("repeatTerm", repeatTerm)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    deinit {
//        NotificationCenter.default.removeObserver(self)
//    }
//
//
//    func configureTimeAndView() {
//        currentTimeLabel.text = playerController.player.currentTime.toString()
//        DurationLabel.text = playerController.player.duration.toString()
//        timerLabel.text = playerController.player.currentTime.toStringContainMilisec()
//        slider.minimumValue = 0
//        slider.maximumValue = Float(playerController.player.duration)
//        slider.value = Float(playerController.player.currentTime)
//        slider.addTarget(self, action: #selector(onSliderValChanged(slider:event:)), for: .valueChanged)
//    }
//
//    func getSectionidx(target : Int) -> Int {
//        let sectionStartArr = audio.sectionStart
//
//        var idx = 0
//        while idx < sectionStartArr.count-1 {
//            if target < sectionStartArr[idx+1] {
//                break
//            }
//            idx += 1
//        }
//        return idx
//    }
//
//
//    private func getRepeatTerm() -> Double {
//        let terms = [0.0, 0.5, 1.0, 2.0, 3.0, 5.0, 10.0, 15.0]
//        let repeatTermSelected = AdminUserDefault.shared.settingSelected["repeatTerm"] ?? 0
//
//        return terms[repeatTermSelected]
//    }
//
//
//    // 처음 ScrollStackView 만들때
//    func configureWaveImgView() {
//        let current = Int(playerController.player.currentTime * changedAmountPerSec)
//
//        leftSectionIdx = getSectionidx(target : current - Int(windowWidth/2) - 100)
//        rightSectionIdx = getSectionidx(target : current + Int(windowWidth/2) + 100)
//
//        setImgOnScrollSV(waveImageIdxList: Array(leftSectionIdx...rightSectionIdx))
//        setScrollViewX(time : playerController.player.currentTime)
//    }
//
//
//    // scrollView의 x좌표 설정, currentLoc - leftSectionStart - 화면가로/2
//    func setScrollViewX(time : TimeInterval) {
//        let currentLoc = time < 0.0 ? 0 : time * changedAmountPerSec
//        var nx = currentLoc
//
//        if leftSectionIdx != 0 {
//            let startLoc = audio.sectionStart[leftSectionIdx]
//            nx -= Double(startLoc + Int(windowWidth/2))
//        }
//
//        scrollView.contentOffset = CGPointMake(nx, 0)
//    }
//
//}
//
//
//// draw and set Image for scrollView
//extension PlayerUpperView {
//    // int 배열에 맞추어 waveImage 생성 후 scrollStackView에 추가
//    func setImgOnScrollSV(waveImageIdxList : [Int]) {
//        waveImageIdxList.forEach{
//            scrollStackView.appendWaveImg(
//                view: drawWaveImage(idx : $0, status: .basicWave),
//                subView: drawWaveImage(idx : $0, status: .nowWave)
//            )
//        }
//    }
//
//    // int에 맞추어 waveAnalysis의 구간을 설정해 draw
//    func drawWaveImage(idx : Int, status : waveCategory) -> UIImageView {
//        let waveImgView = UIImageView()
////        waveImgView.contentMode = .scaleToFill
//
//        let waveformImageDrawer = MyWaveformImageDrawer()
//        let height = Int(self.frame.size.height) - 185
////        let height = Int(UIScreen.main.bounds.size.height - (superview!.safeAreaInsets.top + superview!.safeAreaInsets.bottom)) - 195 - 185 + 1
//        print("height : ", height, superview?.safeAreaInsets.top)
//        var width = 0
//        let scale = 1
//
//        var target : Range = 0..<1
//
//        // 처음과 마지막 waveImgView에는 화면 반크기의 빈 이미지 추가
//        switch idx {
//        case 0:
//            target = 0..<audio.sectionStart[idx+1]
//            width = target.count + Int(windowWidth/2)
//            waveformImageDrawer.leftOffset = Int(windowWidth/2)
//        case sectionCount - 1:
//            target = audio.sectionStart[idx]..<audio.waveAnalysis.count
//            width = target.count + Int(windowWidth/2)
//        default:
//            target = audio.sectionStart[idx]..<audio.sectionStart[idx+1]
//            width = target.count
//        }
//
//        // 구간 색깔 선정
//        let sectionColor : UIColor = {
//            // 현재 재생중인 구간 색
//            switch status {
//            case .basicWave:
//                return UIColor(rgb: 0xfde9c5)
//            case .nowWave:
//                return UIColor(rgb: 0xFFD384)
//            case .repeatWave:
//                return UIColor(rgb: 0xFBA5A9)
//            }
//        }()
//
//        let image = waveformImageDrawer.waveformImage(from: target, with: .init(
//            size : CGSize(width: width, height: height),
//            sectionColor : sectionColor,
//            dampening: nil,
//            scale: CGFloat(scale),
//            verticalScalingFactor: 0.5,
//            sectionIdx : idx)
//        )
//        waveImgView.image = image ?? UIImage()
//        waveImgView.tag = idx
//        return waveImgView
//    }
//
//}
//
//
//// timer observer functions
//extension PlayerUpperView {
//    // playerController 에서 status가 변할 때마다 noti를 보낸다.
//    func addNotificationObserver(completion : @escaping () -> Void) {
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(adminTimer),
//            name: Notification.Name("playerStatusChanged"),
//            object: nil
//        )
//
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(updateScrollStackViewForWaveRepeat),
//            name: Notification.Name("tapWaveRepeatButton"),
//            object: nil
//        )
//
//        completion()
//    }
//
//    // waveRepeat 버튼 눌렸을 때 호출
//    @objc func updateScrollStackViewForWaveRepeat() {
//        // 구간 처음으로 시간 이동
//        if playerController.shouldSectionRepeat == true {
//            if let timer = timer { if timer.isValid { timer.invalidate() }}
//            if playerController.status != .autoIntermit {
//                playerController.autoIntermittPlayer(intermitCategory: .WaveRepeatIntermit)
//                playerController.changePlayerTime(changedTime: Double(playerController.positionSectionStart!) / changedAmountPerSec)
//            }
//        }
//
//        // nowSection의 색깔 선정
//        scrollStackView.changeWaveImage(WaveIdx: nowSectionIdx, view: drawWaveImage(idx: nowSectionIdx, status: .repeatWave))
//    }
//
//    // ScrollStackView 재구성
//    @objc func resetScrollStackView() {
//        scrollStackView.removeFullySubviews()
//        configureWaveImgView()
//    }
//
//    // noti를 받으면 status에 따라 timer에 0.01단위의 schedule을 설정
//    @objc func adminTimer() {
//        switch playerController.status {
//        case .play:
//            if let timer = timer { if timer.isValid { return } }
//            self.timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updatePlayTime), userInfo: nil, repeats: true)
//        case .autoIntermit, .ABrepeatIntermit, .WaveRepeatIntermit:
//            playerController.playPlayer()
//        default:
//            if let timer = timer { if timer.isValid { timer.invalidate() } }
//            updatePlayTime()
//        }
//    }
//
//
//    // 시간 라벨들 업데이트 함수
//    private func updateTimeLabel(time : TimeInterval) {
//        currentTimeLabel.text = time.toString()
//        timerLabel.text = time.toStringContainMilisec()
//        slider.value = Float(time)
//    }
//
//    // 주어진 time을 바탕으로 left,right idx를 비롯해 scrollView의 stack 관리
//    private func updateScrollStackView(time : TimeInterval){
//        let leftStart = leftSectionIdx == 0 ? 0 : audio.sectionStart[leftSectionIdx]
//        let rightEnd = rightSectionIdx == sectionCount-1 ? audio.waveAnalysis.count : audio.sectionStart[rightSectionIdx+1]
//
//        let target = Int(time * changedAmountPerSec)
//        let windowStart = target - Int(windowWidth/2) - 100
//        let windowEnd = target + Int(windowWidth/2) + 100
//
//        if target < leftStart || rightEnd < target {
//            resetScrollStackView()
//        }
//        else {
//            var nx = scrollView.contentOffset.x
//            while true {
//                let leftStart = leftSectionIdx == 0 ? 0 : audio.sectionStart[leftSectionIdx]
//                let leftEnd = leftSectionIdx == sectionCount-1 ? audio.waveAnalysis.count : audio.sectionStart[leftSectionIdx+1]
//
//                // 왼쪽에 waveImg추가
//                if windowStart < leftStart && leftSectionIdx != 0 {
//                    leftSectionIdx -= 1
//                    nx += scrollStackView.appendLeftWaveImg(
//                        view: drawWaveImage(idx : leftSectionIdx, status: .basicWave),
//                        subView: drawWaveImage(idx : leftSectionIdx, status: .nowWave)
//                    )
//                }
//                // 왼쪽의 waveImg 제거
//                else if leftEnd < windowStart && leftSectionIdx != sectionCount-1 {
//                    nx -= scrollStackView.popLeftWaveImg()
//                    leftSectionIdx += 1
//                }
//                else {
//                    break
//                }
//            }
//
//            while true {
//                let rightStart = rightSectionIdx == 0 ? 0 : audio.sectionStart[rightSectionIdx]
//                let rightEnd = rightSectionIdx == sectionCount-1 ? audio.waveAnalysis.count : audio.sectionStart[rightSectionIdx+1]
//
//                // 오른쪽 waveImg 제거
//                if windowEnd < rightStart && rightSectionIdx != 0 {
//                    scrollStackView.popWaveImg()
//                    rightSectionIdx -= 1
//                }
//                // 오른쪽 이미지 추가
//                else if rightEnd < windowEnd && rightSectionIdx != sectionCount-1 {
//                    rightSectionIdx += 1
//                    scrollStackView.appendWaveImg(
//                        view: drawWaveImage(idx : rightSectionIdx, status: .basicWave),
//                        subView: drawWaveImage(idx : rightSectionIdx, status: .nowWave)
//                    )
//                }
//                else { break }
//            }
//
//            // scrollView x좌표 업데이트
//            if scrollView.contentOffset.x != nx {
//                scrollView.contentOffset.x = nx
//            }
//
//        }
//    }
//
//
//    // 반복 시 설정한 대기 시간만큼 지연후 재생
//    private func changeTimeForRepeat(time : TimeInterval, intermitCategory : PlayerStatus) {
//        if let timer = timer { if timer.isValid { timer.invalidate() }}
//        print("changeTimeForRepeat")
//        if playerController.status != intermitCategory {
//            playerController.autoIntermittPlayer(intermitCategory: intermitCategory)
//            playerController.player.currentTime = time
//            updatePlayTime()
//            print("enddddddddd")
//
//            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + repeatTerm) {
//                // 지연 후에 아직 intermit이라면
//                print("cehck ", self.playerController.status)
//                if self.playerController.status == intermitCategory {
//                    print("action")
//                    self.playerController.changePlayerTime(changedTime: time)
//                }
//            }
//        }
//    }
//
//
//    // player currentTime에 맞추어 시간 label들 관리 및 scrollView 위치이동
//    @objc func updatePlayTime() {
//        let targetAnalysis = playerController.player.currentTime * changedAmountPerSec
//
//        // ab 반복
//        if playerController.shouldABRepeat == true && (targetAnalysis < Double(playerController.positionA!) || Double(playerController.positionB!) < targetAnalysis) {
//            changeTimeForRepeat(time : Double(self.playerController.positionA!) / self.changedAmountPerSec, intermitCategory: .ABrepeatIntermit)
//            return
//        }
//
//        // wave 반복
//        if playerController.shouldSectionRepeat == true && (targetAnalysis < Double(playerController.positionSectionStart!) || Double(playerController.positionSectionEnd!) < targetAnalysis) {
//            changeTimeForRepeat(time : Double(playerController.positionSectionStart!) / changedAmountPerSec, intermitCategory: .WaveRepeatIntermit)
//            return
//        }
//
//        // label들 시간 업데이트
//        updateTimeLabel(time: playerController.player.currentTime)
//
//        // 현재 시각에 따른 scrollStackView 관리
//        updateScrollStackView(time: playerController.player.currentTime)
//
//        // time에 맞추어 scrollView 좌표 업데이트
//        setScrollViewX(time : playerController.player.currentTime)
//
//        // nowSectionIdx에 맞추어 waveImage color 바꾸기
//        let newSectionIdx = getSectionidx(target: Int(targetAnalysis))
//        if nowSectionIdx != newSectionIdx {
//            let originSectionIdx = nowSectionIdx
//            nowSectionIdx = newSectionIdx
//            scrollStackView.changeWithSubArr(WaveIdx: originSectionIdx)
//            scrollStackView.changeWithSubArr(WaveIdx: nowSectionIdx)
//
//
//            audio.currentTime = playerController.player.currentTime
//            CoreDataFunc.shared.updateCurrentTime(audio: audio)
//        }
//
//    }
//}
//
//
//// slider 동작 인식
//extension PlayerUpperView {
//    @objc func onSliderValChanged(slider: UISlider, event: UIEvent) {
//        if let touchEvent = event.allTouches?.first {
//            switch touchEvent.phase {
//            case .began:
//                // 슬라이더 드래그 시작할 때 재생중이라면 플레이어 잠시 멈춤
//                if playerController.status == .play {
//                    playerController.intermitPlayer()
//                }
//            case .moved:
//                // 슬라이더 드래그 중에 value에 맞추어 player 시간 업데이트
//                playerController.changePlayerTime(changedTime : Double(slider.value))
//            case .ended:
//                // 슬라이더 드래그 끝날 때 플레이어 잠시 멈춤이라면 재생
//                playerController.changePlayerTime(changedTime : Double(slider.value))
//
//                if playerController.status == .intermit {
//                    playerController.playPlayer()
//                }
//            default:
//                break
//            }
//        }
//    }
//}
//
//
////// 스크롤 동작 인식
//extension PlayerUpperView : UIScrollViewDelegate {
//    // 드래그 시작할 때 재생중이라면 플레이어 잠시 멈춤
//    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        if playerController.status == .play {
//            playerController.intermitPlayer()
//        }
//    }
//
//    // 드래그에 위치에 따라 시간 라벨들 업데이트 및 waveStackView 업데이트
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if let timer = timer { if timer.isValid { return }}
//
//        let leftStart = leftSectionIdx == 0 ? 0 : audio.sectionStart[leftSectionIdx]
//        let nx = scrollView.contentOffset.x
//        var target = Double(leftStart) + nx
//        if leftSectionIdx != 0 { target += Double(Int(windowWidth/2)) }
//
//        if target <= 0 { target = 0.0 }
//        else if Double(audio.waveAnalysis.count) <= target { target = Double(audio.waveAnalysis.count) }
//
//        updateTimeLabel(time: target/changedAmountPerSec)
//        updateScrollStackView(time: target/changedAmountPerSec)
//    }
//
//    // 드래그 끝날 때 끄는 동작 없다면 플레이어 시간 업데이트
//    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        if decelerate == false {
//            let leftStart = leftSectionIdx == 0 ? 0 : audio.sectionStart[leftSectionIdx]
//            let nx = scrollView.contentOffset.x
//            var target = Double(leftStart) + nx
//            if leftSectionIdx != 0 { target += Double(Int(windowWidth/2)) }
//
//            playerController.changePlayerTime(changedTime : target/changedAmountPerSec)
//
////             잠시 멈춤이라면 재생
//            if playerController.status == .intermit {
//                playerController.playPlayer()
//            }
//
//        }
//    }
//
//    // 끄는 동작 끝날 때 플레이어 시간 업데이트
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        let leftStart = leftSectionIdx == 0 ? 0 : audio.sectionStart[leftSectionIdx]
//        let nx = scrollView.contentOffset.x
//        var target = Double(leftStart) + nx
//        if leftSectionIdx != 0 { target += Double(Int(windowWidth/2)) }
//
//        playerController.changePlayerTime(changedTime : target/changedAmountPerSec)
//
////         잠시 멈춤이라면 재생
//        if playerController.status == .intermit {
//            playerController.playPlayer()
//        }
//    }
//}
//
//
//// repeat button functions
//extension PlayerUpperView {
//    private func setUpperControllerSVButton(status : ABbuttonStatus) {
//        switch status {
//        case .none:
//            Abutton.tintColor = .label
//            Bbutton.tintColor = .label
//
//            Abutton.isEnabled = true
//            backToAbutton.isEnabled = false
//            Bbutton.isEnabled = false
//            trashButton.isEnabled = false
//        case .onlyA:
//            Abutton.tintColor = .red
//            Bbutton.tintColor = .label
//
//            Abutton.isEnabled = true
//            backToAbutton.isEnabled = true
//            Bbutton.isEnabled = true
//            trashButton.isEnabled = true
//        case .ABboth:
//            Abutton.tintColor = .red
//            Bbutton.tintColor = .blue
//
//            Abutton.isEnabled = false
//            backToAbutton.isEnabled = true
//            trashButton.isEnabled = true
//            Bbutton.isEnabled = true
//        }
//    }
//
//    @objc private func tapAButton() {
//        if playerController.positionA == nil {
//            // A위치 설정
//            let leftStart = leftSectionIdx == 0 ? 0 : audio.sectionStart[leftSectionIdx]
//            let nx = scrollView.contentOffset.x
//            var target = Double(leftStart) + nx
//            if leftSectionIdx != 0 { target += Double(Int(windowWidth/2)) }
//            playerController.positionA = Int(target)
//
//            setUpperControllerSVButton(status: .onlyA)
//        } else {
//            // A 위치 설정 해제
//            playerController.positionA = nil
//
//            setUpperControllerSVButton(status: .none)
//        }
//
//        // wave image업데이트
//        resetScrollStackView()
//    }
//
//    @objc private func tapBackToAButton() {
//        if playerController.positionA != nil {
//            playerController.autoIntermittPlayer(intermitCategory : .autoIntermit)
//            playerController.changePlayerTime(changedTime: Double(playerController.positionA!) / changedAmountPerSec)
//        }
//    }
//
//    @objc private func taptrashButton() {
//        playerController.shouldABRepeat = false
//        playerController.positionA = nil
//        playerController.positionB = nil
//
//        setUpperControllerSVButton(status: .none)
//
//        resetScrollStackView()
//    }
//
//
//    @objc private func tapBButton() {
//        // B 위치 설정
//        if playerController.positionB == nil {
//            let leftStart = leftSectionIdx == 0 ? 0 : audio.sectionStart[leftSectionIdx]
//            let nx = scrollView.contentOffset.x
//            var target = Double(leftStart) + nx
//            if leftSectionIdx != 0 { target += Double(Int(windowWidth/2)) }
//
//            playerController.positionB = Int(target)
//
//            playerController.shouldABRepeat = true
//
//            setUpperControllerSVButton(status: .ABboth)
//        } else {
//            playerController.positionB = nil
//
//            playerController.shouldABRepeat = false
//
//            setUpperControllerSVButton(status: .onlyA)
//        }
//
//        // wave image업데이트
//        resetScrollStackView()
//
//    }
//}
//
//
//
//// PlayerUpperView UI
//extension PlayerUpperView {
//    private func setLayout() {
//
//        [sliderContainer, upperControllerSV, scrollView, currentIndicator, timerLabel].forEach{
//            addSubview($0)
//        }
//
//        [slider, currentTimeLabel, DurationLabel].forEach{
//            sliderContainer.addSubview($0)
//        }
//
//        sliderContainer.snp.makeConstraints{
//            $0.leading.trailing.equalToSuperview().inset(20)
//            $0.top.equalToSuperview().inset(15)
//            $0.height.equalTo(30)
//        }
//        slider.snp.makeConstraints{
//            $0.leading.trailing.equalToSuperview()
//            $0.top.equalTo(sliderContainer).offset(10)
//        }
//        currentTimeLabel.snp.makeConstraints{
//            $0.leading.equalToSuperview()
//            $0.top.equalTo(slider.snp.bottom).offset(5)
//        }
//        DurationLabel.snp.makeConstraints{
//            $0.trailing.equalToSuperview()
//            $0.top.equalTo(slider.snp.bottom).offset(5)
//        }
//
//        upperControllerSV.snp.makeConstraints{
//            $0.top.equalTo(sliderContainer.snp.bottom).offset(15)
//            $0.leading.trailing.equalToSuperview().inset(20)
//            $0.height.equalTo(30)
//        }
//
//        scrollView.addSubview(scrollStackView)
//        scrollView.snp.makeConstraints{
//            $0.leading.trailing.equalToSuperview()
//            $0.top.equalTo(upperControllerSV.snp.bottom).offset(15)
//            $0.bottom.equalTo(timerLabel.snp.top).offset(-20)
//        }
//        scrollStackView.snp.makeConstraints{
//            $0.top.bottom.leading.trailing.height.equalTo(scrollView)
//        }
//
//        currentIndicator.snp.makeConstraints{
//            $0.top.equalTo(scrollView).inset(7)
//            $0.bottom.equalTo(scrollView).inset(20)
//            $0.centerX.equalToSuperview()
//            $0.width.equalTo(2)
//        }
//
//        timerLabel.snp.makeConstraints{
//            $0.centerX.equalToSuperview()
//            $0.bottom.equalToSuperview()
//            $0.width.equalTo(197)
//            $0.height.equalTo(60)
//        }
//    }
//}
