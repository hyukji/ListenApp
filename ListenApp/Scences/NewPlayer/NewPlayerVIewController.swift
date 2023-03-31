//
//  NewPlayerVIewController.swift
//  ListenApp
//
//  Created by 곽지혁 on 2023/01/27.
//

import UIKit
import AVFAudio

enum ABbuttonStatus {
    case none
    case onlyA
    case ABboth
}

enum waveCategory {
    case basicWave
    case nowWave
    case repeatWave
}

class NewPlayerVIewController : UIViewController {
    let playerController = PlayerController.playerController
    var audio = PlayerController.playerController.audio!
    var timer : Timer?
    
    let changedAmountPerSec = PlayerController.playerController.changedAmountPerSec
    let sectionCount = PlayerController.playerController.audio!.sectionStart.count
    
    let waveImageSize = 1000
    let windowWidth = UIScreen.main.bounds.size.width
    var waveHeight = 0
    
    var nowSectionIdx = 0
    var leftSectionIdx = 0
    var rightSectionIdx = 0
    
    var repeatTerm = 0.5
    
    private lazy var playerLowerView = PlayerLowerView()
    
    
    private lazy var sliderContainer = UIView()
    
    private var slider : UISlider = {
        let slider = UISlider()
        slider.tintColor = .tintColor
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
        
        let imageConfig = UIImage.SymbolConfiguration(font: .systemFont(ofSize: 20), scale: .default)
        
        Abutton.setImage(UIImage(systemName: "a.square", withConfiguration: imageConfig), for: .normal)
        backToAbutton.setImage(UIImage(systemName: "chevron.backward.2", withConfiguration: imageConfig), for: .normal)
        trashButton.setImage(UIImage(systemName: "trash.circle", withConfiguration: imageConfig), for: .normal)
        Bbutton.setImage(UIImage(systemName: "b.square", withConfiguration: imageConfig), for: .normal)
        
        Abutton.addTarget(self, action: #selector(tapAButton), for: .touchUpInside)
        backToAbutton.addTarget(self, action: #selector(tapBackToAButton), for: .touchUpInside)
        Bbutton.addTarget(self, action: #selector(tapBButton), for: .touchUpInside)
        trashButton.addTarget(self, action: #selector(taptrashButton), for: .touchUpInside)
        
        if playerController.shouldABRepeat {
            if (playerController.positionA != nil && playerController.positionB != nil) {
                // ab 반복중이었다면
                setUpperControllerSVButton(status: .ABboth)
            }
            else {
                playerController.shouldABRepeat = false
                setUpperControllerSVButton(status : .none)
                print("!!!!!!!!!!!!!!!!!!!!!!!!!! shouldABrepeat이 true인데 a,b 좌표 없음 !!!!!!!!!!!!!!!!!!!!!!")
            }
        } else if (playerController.positionA != nil) {
            // a 만 설정되어 있다면
            setUpperControllerSVButton(status: .onlyA)
        } else {
            setUpperControllerSVButton(status : .none)
        }
        
        [Abutton, backToAbutton, trashButton, Bbutton].forEach{
            stackView.addArrangedSubview($0)
        }
        
        return stackView
    }()
    
    lazy var scrollStackView : MyWaveImgStackView = {
        let stackView = MyWaveImgStackView()
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
        lbl.font = UIFont.monospacedDigitSystemFont(ofSize: 40.0, weight: .regular)
        lbl.addCharacterSpacing()
        
        return lbl
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playerController.player.delegate = self
        setLayout()
        configureTimeAndView()
        repeatTerm = getRepeatTerm()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 처음으로 viewDidLayoutSubviews가 호출 될때
        if waveHeight == 0 && Int(scrollStackView.frame.size.height) != 0 {
            waveHeight = Int(scrollStackView.frame.size.height)
            configureWaveImgView()
            scrollStackView.changeWithNowArr(WaveIdx: nowSectionIdx)
            
            addNotificationObserver(){
                self.playerController.playPlayer()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 첫번째 appear 제외
        if waveHeight != 0 {
            repeatTerm = getRepeatTerm()
            playerLowerView.configureSecondButtonImage()
            playerLowerView.configureSpeedSelector()

            // disappear 할때 삭제함
            addNotificationObserver(){
                self.adminTimer()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        if let timer = timer {
            if timer.isValid { timer.invalidate() }
        }
    }
    
    func configureTimeAndView() {
        currentTimeLabel.text = playerController.player.currentTime.toString()
        DurationLabel.text = playerController.player.duration.toString()
        timerLabel.text = playerController.player.currentTime.toStringContainMilisec()
        timerLabel.addCharacterSpacing()
        slider.minimumValue = 0
        slider.maximumValue = Float(playerController.player.duration)
        slider.value = Float(playerController.player.currentTime)
        slider.addTarget(self, action: #selector(onSliderValChanged(slider:event:)), for: .valueChanged)
    }
    
    func getSectionidx(target : Int) -> Int {
        let sectionStartArr = audio.sectionStart
        
        var idx = 0
        while idx < sectionStartArr.count-1 {
            if target < sectionStartArr[idx+1] {
                break
            }
            idx += 1
        }
        return idx
    }
    
    
    private func getRepeatTerm() -> Double {
        let terms = [0.0, 0.5, 1.0, 2.0, 3.0, 5.0, 10.0, 15.0]
        let repeatTermSelected = AdminUserDefault.shared.settingSelected["repeatTerm"] ?? 0
        
        return terms[repeatTermSelected]
    }
    
    
    // 처음 ScrollStackView 만들때
    func configureWaveImgView() {
        let current = Int(playerController.player.currentTime * changedAmountPerSec)
        
        leftSectionIdx = getSectionidx(target : current - Int(windowWidth/2) - 100)
        rightSectionIdx = getSectionidx(target : current + Int(windowWidth/2) + 100)
        
        setImgOnScrollSV(waveImageIdxList: Array(leftSectionIdx...rightSectionIdx))
        setScrollViewX(time : playerController.player.currentTime)
        scrollStackView.showAddSubViewsIdx()
    }
    
    
    // scrollView의 x좌표 설정, currentLoc - leftSectionStart - 화면가로/2
    func setScrollViewX(time : TimeInterval) {
        let currentLoc = time < 0.0 ? 0 : time * changedAmountPerSec
        var nx = currentLoc
        
        if leftSectionIdx != 0 {
            let startLoc = audio.sectionStart[leftSectionIdx]
            nx -= Double(startLoc + Int(windowWidth/2))
        }
        
        scrollView.contentOffset = CGPointMake(nx, 0)
    }
    
}
    
// draw and set Image for scrollView
extension NewPlayerVIewController {
    // int 배열에 맞추어 waveImage 생성 후 scrollStackView에 추가
    func setImgOnScrollSV(waveImageIdxList : [Int]) {
        waveImageIdxList.forEach{
            scrollStackView.appendWaveImg(
                view: drawWaveImage(idx : $0, status: .basicWave),
                nowView: drawWaveImage(idx : $0, status: .nowWave)
            )
        }
        
    }
    
    // int에 맞추어 waveAnalysis의 구간을 설정해 draw
    func drawWaveImage(idx : Int, status : waveCategory) -> UIImageView {
        let waveImgView = UIImageView()
        waveImgView.contentMode = .scaleToFill
        
        let waveformImageDrawer = MyWaveformImageDrawer()
        var width = 0
        let scale = 1
        
        var target : Range = 0..<1
        
        // 처음과 마지막 waveImgView에는 화면 반크기의 빈 이미지 추가
        switch idx {
        case 0:
            target = 0..<audio.sectionStart[idx+1]
            width = target.count + Int(windowWidth/2)
            waveformImageDrawer.leftOffset = Int(windowWidth/2)
        case sectionCount - 1:
            target = audio.sectionStart[idx]..<audio.waveAnalysis.count
            width = target.count + Int(windowWidth/2)
        default:
            target = audio.sectionStart[idx]..<audio.sectionStart[idx+1]
            width = target.count
        }
        
        // 구간 색깔 선정
        let sectionColor : UIColor = {
            // 현재 재생중인 구간 색
            switch status {
            case .basicWave:
                return UIColor(rgb: 0xfde9c5)
            case .nowWave:
                return UIColor(rgb: 0xFFD384)
            case .repeatWave:
                return UIColor(rgb: 0xFBA5A9)
            }
        }()
        
        let image = waveformImageDrawer.waveformImage(from: target, with: .init(
            size : CGSize(width: width, height: waveHeight),
            backgroundColor: .tertiarySystemGroupedBackground,
            stripeConfig: .init(color: .black),
            sectionColor : sectionColor,
            dampening: nil,
            scale: CGFloat(scale),
            verticalScalingFactor: 0.5,
            sectionIdx : idx)
        )
        waveImgView.image = image ?? UIImage()
        waveImgView.tag = idx
        
        return waveImgView
    }
    
}


// timer observer functions
extension NewPlayerVIewController {
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
            selector: #selector(updateScrollStackViewForWaveRepeat),
            name: Notification.Name("tapWaveRepeatButton"),
            object: nil
        )

        completion()
    }
    
    // waveRepeat 버튼 눌렸을 때 호출
    @objc func updateScrollStackViewForWaveRepeat() {
        if playerController.shouldSectionRepeat == true {
            // 구간반복 실행
            if let timer = timer { if timer.isValid { timer.invalidate() }}
            if playerController.status != .intermit(.play, .repeated) {
                playerController.intermitPlayer(type: .repeated)
                playerController.changePlayerTime(changedTime: Double(playerController.positionSectionStart!) / changedAmountPerSec)
            }
            // nowSection 의 색깔 반복할때의 색으로
            scrollStackView.changeWaveImageForRepeat(WaveIdx: nowSectionIdx, view: drawWaveImage(idx: nowSectionIdx, status: .repeatWave))
        }
        else {
            // 구간반복 취소
            scrollStackView.changeWithNowArr(WaveIdx: nowSectionIdx)
        }
    }

    // ScrollStackView 재구성
    @objc func resetScrollStackView() {
        scrollStackView.removeFullySubviews()
        configureWaveImgView()
        scrollStackView.changeWithNowArr(WaveIdx: nowSectionIdx)
        if playerController.shouldSectionRepeat {
            scrollStackView.changeWaveImageForRepeat(WaveIdx: nowSectionIdx, view: drawWaveImage(idx: nowSectionIdx, status: .repeatWave))
        }
    }

    // noti를 받으면 status에 따라 timer에 0.01단위의 schedule을 설정
    @objc func adminTimer() {
        switch playerController.status {
        case .play:
            if let timer = timer { if timer.isValid { return } }
            self.timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updatePlayTime), userInfo: nil, repeats: true)
        case .intermit(let originStatus, let type):
            print("intermit \(type)")
            switch originStatus {
            case .play:
                playerController.playPlayer()
            case .pause:
                playerController.pausePlayer()
            default:
                print("intermit's origin status is \(originStatus). it's not normal")
                playerController.pausePlayer()
            }
        default:
            if let timer = timer { if timer.isValid { timer.invalidate() } }
            updatePlayTime()
        }
    }
    
    
    // 시간 라벨들 업데이트 함수
    private func updateTimeLabel(time : TimeInterval) {
        currentTimeLabel.text = time.toString()
        timerLabel.text = time.toStringContainMilisec()
        timerLabel.addCharacterSpacing()
        slider.value = Float(time)
    }

    // 주어진 time을 바탕으로 left,right idx를 비롯해 scrollView의 stack 관리
    private func updateScrollStackView(time : TimeInterval){
        let leftStart = leftSectionIdx == 0 ? 0 : audio.sectionStart[leftSectionIdx]
        let rightEnd = rightSectionIdx == sectionCount-1 ? audio.waveAnalysis.count : audio.sectionStart[rightSectionIdx+1]
        
        let target = Int(time * changedAmountPerSec)
        let windowStart = target - Int(windowWidth/2) - 100
        let windowEnd = target + Int(windowWidth/2) + 100
        
        if target < leftStart || rightEnd < target {
            resetScrollStackView()
        }
        else {
            var nx = scrollView.contentOffset.x
            while true {
                let leftStart = leftSectionIdx == 0 ? 0 : audio.sectionStart[leftSectionIdx]
                let leftEnd = leftSectionIdx == sectionCount-1 ? audio.waveAnalysis.count : audio.sectionStart[leftSectionIdx+1]
                
                // 왼쪽에 waveImg추가
                if windowStart < leftStart && leftSectionIdx != 0 {
                    leftSectionIdx -= 1
                    nx += scrollStackView.appendLeftWaveImg(
                        view: drawWaveImage(idx : leftSectionIdx, status: .basicWave),
                        nowView: drawWaveImage(idx : leftSectionIdx, status: .nowWave)
                    )
                }
                // 왼쪽의 waveImg 제거
                else if leftEnd < windowStart && leftSectionIdx != sectionCount-1 {
                    nx -= scrollStackView.popLeftWaveImg()
                    leftSectionIdx += 1
                }
                else {
                    break
                }
            }
            
            while true {
                let rightStart = rightSectionIdx == 0 ? 0 : audio.sectionStart[rightSectionIdx]
                let rightEnd = rightSectionIdx == sectionCount-1 ? audio.waveAnalysis.count : audio.sectionStart[rightSectionIdx+1]
                
                // 오른쪽 waveImg 제거
                if windowEnd < rightStart && rightSectionIdx != 0 {
                    scrollStackView.popWaveImg()
                    rightSectionIdx -= 1
                }
                // 오른쪽 이미지 추가
                else if rightEnd < windowEnd && rightSectionIdx != sectionCount-1 {
                    rightSectionIdx += 1
                    scrollStackView.appendWaveImg(
                        view: drawWaveImage(idx : rightSectionIdx, status: .basicWave),
                        nowView: drawWaveImage(idx : rightSectionIdx, status: .nowWave)
                    )
                }
                else { break }
            }
            
            // scrollView x좌표 업데이트
            if scrollView.contentOffset.x != nx {
                scrollView.contentOffset.x = nx
            }
            
        }
    }
    
    
    // 반복 시 설정한 대기 시간만큼 지연후 재생
    private func changeTimeForRepeat(time : TimeInterval, intermitType : IntermitType) {
        if let timer = timer { if timer.isValid { timer.invalidate() }}
        if playerController.status != .intermit(.play, intermitType) {
            print("intermitType", intermitType)
            playerController.intermitPlayer(type: intermitType)
            playerController.player.currentTime = time
            updatePlayTime()
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + repeatTerm) {
                // 지연 후에 아직 intermit이라면 originStatus에 맞춰 진행
                switch self.playerController.status {
                case .intermit(let status, intermitType):
                    switch status {
                    case .play:
                        self.playerController.playPlayer()
                    default:
                        self.playerController.pausePlayer()
                    }
                default:
                    return
                }
            }
        }
    }
    
    
    // player currentTime에 맞추어 시간 label들 관리 및 scrollView 위치이동
    @objc func updatePlayTime() {
        let targetAnalysis = playerController.player.currentTime * changedAmountPerSec
        
        // ab 반복
        if playerController.shouldABRepeat == true && (targetAnalysis < Double(playerController.positionA!) || Double(playerController.positionB!) < targetAnalysis) {
            changeTimeForRepeat(time : Double(self.playerController.positionA!) / self.changedAmountPerSec, intermitType: .repeated)
            return
        }

        // wave 반복
        if playerController.shouldSectionRepeat == true && (targetAnalysis < Double(playerController.positionSectionStart!) || Double(playerController.positionSectionEnd!) < targetAnalysis) {
            changeTimeForRepeat(time : Double(self.playerController.positionSectionStart!) / self.changedAmountPerSec, intermitType: .repeated)
            return
        }
        
        // label들 시간 업데이트
        updateTimeLabel(time: playerController.player.currentTime)

        // 현재 시각에 따른 scrollStackView 관리
        updateScrollStackView(time: playerController.player.currentTime)

        // time에 맞추어 scrollView 좌표 업데이트
        setScrollViewX(time : playerController.player.currentTime)
        
        // nowSectionIdx에 맞추어 waveImage color 바꾸기
        
        let newSectionIdx = getSectionidx(target: Int(targetAnalysis))
        if nowSectionIdx != newSectionIdx {
            let originSectionIdx = nowSectionIdx
            nowSectionIdx = newSectionIdx
            
            scrollStackView.changeWithBasicArr(WaveIdx: originSectionIdx)
            scrollStackView.changeWithNowArr(WaveIdx: nowSectionIdx)
            
            // 데이터에 현재 시간 저장
            if playerController.status == .play || playerController.status == .pause {
                audio.currentTime = playerController.player.currentTime
                CoreDataFunc.shared.updateCurrentTime(audio: audio)
            }
            
            if playerController.shouldSectionRepeat {
                scrollStackView.changeWaveImageForRepeat(WaveIdx: nowSectionIdx, view: drawWaveImage(idx: nowSectionIdx, status: .repeatWave))
            }
        }

    }
}


// slider 동작 인식
extension NewPlayerVIewController {
    @objc func onSliderValChanged(slider: UISlider, event: UIEvent) {
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .began:
                // 플레이어 잠시 멈춤
                if let timer = timer { if timer.isValid { timer.invalidate() } }
                playerController.intermitPlayer(type: .moved)
            case .moved:
                // 슬라이더 드래그 중에 value에 맞추어 player 시간 업데이트
                playerController.player.currentTime = Double(slider.value)
                updatePlayTime()
            case .ended:
                adminTimer()
            default:
                break
            }
        }
    }
}


//// 스크롤 동작 인식
extension NewPlayerVIewController : UIScrollViewDelegate {
    // 드래그 시작할 때 재생중이라면 플레이어 잠시 멈춤
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        playerController.pausePlayer()
        playerController.intermitPlayer(type: .moved)
        if let timer = timer { if timer.isValid { timer.invalidate() } }
        updatePlayTime()
    }

    // 드래그에 위치에 따라 시간 라벨들 업데이트 및 waveStackView 업데이트
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let timer = timer { if timer.isValid { return }}

        let leftStart = leftSectionIdx == 0 ? 0 : audio.sectionStart[leftSectionIdx]
        let nx = scrollView.contentOffset.x
        var target = Double(leftStart) + nx
        if leftSectionIdx != 0 { target += Double(Int(windowWidth/2)) }
        
        if target <= 0 { target = 0.0 }
        else if Double(audio.waveAnalysis.count) <= target { target = Double(audio.waveAnalysis.count) }
        
        
        updateTimeLabel(time: target/changedAmountPerSec)
        updateScrollStackView(time: target/changedAmountPerSec)
    }
    
    // 드래그 끝날 때 끄는 동작 없다면 플레이어 시간 업데이트
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false {
            let leftStart = leftSectionIdx == 0 ? 0 : audio.sectionStart[leftSectionIdx]
            let nx = scrollView.contentOffset.x
            var target = Double(leftStart) + nx
            if leftSectionIdx != 0 { target += Double(Int(windowWidth/2)) }
            
//            adminTimer()
            playerController.changePlayerTime(changedTime : target/changedAmountPerSec)
        }
    }
    
    // 끄는 동작 끝날 때 플레이어 시간 업데이트
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let leftStart = leftSectionIdx == 0 ? 0 : audio.sectionStart[leftSectionIdx]
        let nx = scrollView.contentOffset.x
        var target = Double(leftStart) + nx
        if leftSectionIdx != 0 { target += Double(Int(windowWidth/2)) }
        
        playerController.changePlayerTime(changedTime : target/changedAmountPerSec)
    }
}


// repeat button functions
extension NewPlayerVIewController {
    private func setUpperControllerSVButton(status : ABbuttonStatus) {
        switch status {
        case .none:
            Abutton.tintColor = .label
            Bbutton.tintColor = .label
            
            Abutton.isEnabled = true
            backToAbutton.isEnabled = false
            Bbutton.isEnabled = false
            trashButton.isEnabled = false
        case .onlyA:
            Abutton.tintColor = .red
            Bbutton.tintColor = .label
            
            Abutton.isEnabled = true
            backToAbutton.isEnabled = true
            Bbutton.isEnabled = true
            trashButton.isEnabled = true
        case .ABboth:
            Abutton.tintColor = .red
            Bbutton.tintColor = .blue
            
            Abutton.isEnabled = false
            backToAbutton.isEnabled = true
            trashButton.isEnabled = true
            Bbutton.isEnabled = true
        }
    }
    
    @objc private func tapAButton() {
        if playerController.positionA == nil {
            // A위치 설정
            let leftStart = leftSectionIdx == 0 ? 0 : audio.sectionStart[leftSectionIdx]
            let nx = scrollView.contentOffset.x
            var target = Double(leftStart) + nx
            if leftSectionIdx != 0 { target += Double(Int(windowWidth/2)) }
            playerController.positionA = Int(target)
            
            setUpperControllerSVButton(status: .onlyA)
        } else {
            // A 위치 설정 해제
            playerController.positionA = nil
            
            setUpperControllerSVButton(status: .none)
        }

        // wave image업데이트
        resetScrollStackView()
    }

    @objc private func tapBackToAButton() {
        if playerController.positionA != nil {
            playerController.intermitPlayer(type: .button)
            playerController.changePlayerTime(changedTime: Double(playerController.positionA!) / changedAmountPerSec)
        }
    }

    @objc private func taptrashButton() {
        playerController.shouldABRepeat = false
        playerController.positionA = nil
        playerController.positionB = nil
        
        setUpperControllerSVButton(status: .none)

        resetScrollStackView()
    }


    @objc private func tapBButton() {
        // B 위치 설정
        if playerController.positionB == nil {
            let leftStart = leftSectionIdx == 0 ? 0 : audio.sectionStart[leftSectionIdx]
            let nx = scrollView.contentOffset.x
            var target = Double(leftStart) + nx
            if leftSectionIdx != 0 { target += Double(Int(windowWidth/2)) }
            
            playerController.positionB = Int(target)

            playerController.shouldABRepeat = true
            
            setUpperControllerSVButton(status: .ABboth)
        } else {
            playerController.positionB = nil

            playerController.shouldABRepeat = false
            
            setUpperControllerSVButton(status: .onlyA)
        }

        // wave image업데이트
        resetScrollStackView()
    }
}


    
// NavigationController funcs
extension NewPlayerVIewController {
    
    // go back rootViewVC(PlayListVC or SettingVC)
    @objc func backToRootVC() {
        tabBarController?.tabBar.isHidden = false
        tabBarController?.tabBar.isTranslucent = true
        
        navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func tapPlayerSetting() {
        let playerSettingVC = PlayerSettingViewController()
        navigationController?.pushViewController(playerSettingVC, animated: true)
    }
    
}


// 끝까지 재생되었다면 끝 시간에서 정지
extension NewPlayerVIewController : AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playerController.pausePlayer()
        playerLowerView.setPlayButtonImage()
        
        playerController.changePlayerTime(changedTime: player.duration)
    }
}


// UI Design
extension NewPlayerVIewController {
    func setNavigationBar(title : String) {
        navigationItem.title = title
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(backToRootVC))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "slider.horizontal.3"), style: .plain, target: self, action: #selector(tapPlayerSetting))
        
        navigationItem.leftBarButtonItem?.tintColor = .label
        navigationItem.rightBarButtonItem?.tintColor = .label
    }
    
    private func setLayout() {
        tabBarController?.tabBar.isHidden = true
        tabBarController?.tabBar.isTranslucent = true
        
        [playerLowerView, sliderContainer, upperControllerSV, scrollView, currentIndicator, timerLabel].forEach{
            view.addSubview($0)
        }
        
        [slider, currentTimeLabel, DurationLabel].forEach{
            sliderContainer.addSubview($0)
        }
        
        sliderContainer.snp.makeConstraints{
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(15)
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
            $0.top.equalTo(upperControllerSV.snp.bottom).offset(15)
            $0.bottom.equalTo(timerLabel.snp.top).offset(-20)
        }
        
        scrollStackView.snp.makeConstraints{
            $0.top.bottom.leading.trailing.height.equalTo(scrollView)
        }
        
        currentIndicator.snp.makeConstraints{
            $0.top.equalTo(scrollView).inset(7)
            $0.bottom.equalTo(scrollView).inset(20)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(2)
        }
        
        timerLabel.snp.makeConstraints{
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(playerLowerView.snp.top)
//            $0.width.equalTo(197)
            $0.height.equalTo(60)
        }
//        timerLabel.backgroundColor = .blue
        
        playerLowerView.snp.makeConstraints{
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(15)
            $0.height.equalTo(180)
        }
    }
}

extension UILabel {
    func addCharacterSpacing(_ value: Double = -0.03) {
        let kernValue = self.font.pointSize * CGFloat(value)
        guard let text = text, !text.isEmpty else { return }
        let string = NSMutableAttributedString(string: text)
        string.addAttribute(NSAttributedString.Key.kern, value: kernValue, range: NSRange(location: 0, length: string.length - 1))
        attributedText = string
    }
}
