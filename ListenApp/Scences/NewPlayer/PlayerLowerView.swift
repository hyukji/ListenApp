//
//  PlayerLowerView.swift
//  ListenApp
//
//  Created by 곽지혁 on 2023/01/27.
//

import UIKit

class PlayerLowerView : UIView {
    let playerController = PlayerController.playerController
    let audio = PlayerController.playerController.audio!
    
    let playButton = UIButton()
    let secondFrontButton = UIButton()
    let secondBackButton = UIButton()
    
    lazy var normalControllerSV : UIStackView = {
        let stackView = UIStackView()
        
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        
        stackView.tintColor = .label
        
        setPlayButtonImage()
        
        playButton.addTarget(self, action: #selector(tapPlayButton(_:)), for: .touchUpInside)
        secondBackButton.addTarget(self, action: #selector(tapSecondBackButton), for: .touchUpInside)
        secondFrontButton.addTarget(self, action: #selector(tapSecondFrontButton), for: .touchUpInside)
        
//        playButton.tintColor = UIColor(rgb: 0x666666)
//        secondBackButton.tintColor = UIColor(rgb: 0x777777)
//        secondFrontButton.tintColor = UIColor(rgb: 0x777777)
        playButton.tintColor = UIColor(rgb: 0x333333)
        secondBackButton.tintColor = UIColor(rgb: 0x333333)
        secondFrontButton.tintColor = UIColor(rgb: 0x333333)
        
        [secondBackButton, playButton, secondFrontButton].forEach{
            stackView.addArrangedSubview($0)
        }
        
        return stackView
    }()
    
    let waveRepeatButton : UIButton = {
        let button = UIButton()
        let imageConfig = UIImage.SymbolConfiguration(font: .systemFont(ofSize: 19, weight: .regular), scale: .default)
        button.setImage(UIImage(systemName: "repeat", withConfiguration: imageConfig), for: .normal)
//        button.setImage(UIImage(named: "waveRepeat", in: nil, with: imageConfig), for: .normal)
        button.tintColor = (PlayerController.playerController.shouldSectionRepeat) ? .orange : .label
        return button
    }()
    
    let speedButton : UIButton = {
        let button = UIButton()
        button.setTitle(String(format: "%.1fx", PlayerController.playerController.player.rate), for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        return button
    }()
    
    private lazy var waveControllerSV : UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        
        stackView.tintColor = .label
        
        let waveFrontButton = UIButton()
        let waveBackButton = UIButton()
        
        let waveImageConfig = UIImage.SymbolConfiguration(font: .systemFont(ofSize: 35, weight: .regular), scale: .default)
        
        waveBackButton.setImage(UIImage(named: "goWaveBack", in: nil, with: waveImageConfig), for: .normal)
        waveFrontButton.setImage(UIImage(named: "goWaveForward", in: nil, with: waveImageConfig), for: .normal)
        
        waveBackButton.addTarget(self, action: #selector(tapWaveBackButton), for: .touchUpInside)
        waveFrontButton.addTarget(self, action: #selector(tapWaveFrontButton), for: .touchUpInside)
        
//        waveBackButton.tintColor = .secondaryLabel
//        waveFrontButton.tintColor = .secondaryLabel
        
        waveBackButton.tintColor = UIColor(rgb: 0x666666)
        waveFrontButton.tintColor = UIColor(rgb: 0x666666)
        
        
        [waveRepeatButton, waveBackButton, waveFrontButton, speedButton].forEach{
            stackView.addArrangedSubview($0)
        }
        
        return stackView
    }()
    
    private lazy var waveContollerContainer : UIView = {
        let view = UIView()

        view.layer.borderColor = UIColor(rgb: 0xcccccc).cgColor
        view.layer.borderWidth = 2
        view.layer.cornerRadius = 15
        view.backgroundColor = .tertiarySystemGroupedBackground

        view.addSubview(waveControllerSV)

        return view
    }()
    
    private lazy var lowerControllerStackView : UIStackView = {
        let stackView = UIStackView()
        
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        
        stackView.tintColor = .label
        
        waveRepeatButton.addTarget(self, action: #selector(tapWaveRepeatButton), for: .touchUpInside)
        speedButton.addTarget(self, action: #selector(tapSpeedButton), for: .touchUpInside)
        
        [waveContollerContainer].forEach{
//        [waveRepeatButton, waveContollerContainer, speedButton].forEach{
            stackView.addArrangedSubview($0)
        }
        
        return stackView
    }()
    
    private lazy var verticalStackView : UIStackView = {
        let stackView = UIStackView()
        
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        
        [normalControllerSV, lowerControllerStackView].forEach{
            stackView.addArrangedSubview($0)
        }
        
        return stackView
    }()
    
    private lazy var speedSettingView = SpeedSettingView(frame: .zero, rate: playerController.player.rate)
    
    override init(frame: CGRect) {
        super .init(frame: frame)
        
        setLayout()
        configureSecondButtonImage()
        configureSpeedSelector()
        playerController.playButtonDelegate = self
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureSecondButtonImage() {
        let secondImageConfig = UIImage.SymbolConfiguration(font: .systemFont(ofSize: 27), scale: .default)
        let secondTerm = getSecondTerm()
        
        if secondTerm > 3 {
            secondBackButton.setImage(UIImage(systemName: "gobackward.\(secondTerm)", withConfiguration: secondImageConfig), for: .normal)
            secondFrontButton.setImage(UIImage(systemName: "goforward.\(secondTerm)", withConfiguration: secondImageConfig), for: .normal)
        } else {
            secondBackButton.setImage(UIImage(named : "gobackward.\(secondTerm)", in: nil, with: secondImageConfig), for: .normal)
            secondFrontButton.setImage(UIImage(named : "goforward.\(secondTerm)", in: nil, with: secondImageConfig), for: .normal)
        }
    }
    
    private func getSecondTerm() -> Int {
        let terms = [1, 2, 3, 5, 10, 15]
        let secondTermSelected = AdminUserDefault.shared.settingSelected["secondTerm"] ?? 3
        
        return terms[secondTermSelected]
    }
    
}

extension PlayerLowerView : AdminPlayBtnProtocol {
    func setPlayButtonImage() {
        let playImageConfig = UIImage.SymbolConfiguration(font: .systemFont(ofSize: 35), scale: .default)
        switch playerController.status {
        case .play:
            playButton.setImage(UIImage(systemName: "pause.fill", withConfiguration: playImageConfig), for: .normal)
        default:
            playButton.setImage(UIImage(systemName: "play.fill", withConfiguration: playImageConfig), for: .normal)
        }
    }
}
    

// PlayerLowerView functions of tap UIButton
extension PlayerLowerView {
    @objc private func tapPlayButton(_ sender: UIButton) {
        if playerController.status == .play {
            playerController.pausePlayer()
        } else {
            playerController.playPlayer()
        }
    }
    
    @objc private func tapSecondBackButton() {
        let changedTime = playerController.player.currentTime - Double(getSecondTerm())
        
        playerController.intermitPlayer(type: .button)
        if changedTime < 0 { playerController.changePlayerTime(changedTime: 0) }
        else { playerController.changePlayerTime(changedTime: changedTime) }
    }
    
    @objc private func tapSecondFrontButton() {
        let changedTime = playerController.player.currentTime + Double(getSecondTerm())
        
        playerController.intermitPlayer(type: .button)
        if audio.duration < changedTime { playerController.changePlayerTime(changedTime: audio.duration) }
        else { playerController.changePlayerTime(changedTime: changedTime) }
    }
    
    // 현재 구간 번호 return
    private func getSection() -> Int {
        let x = playerController.player.currentTime * playerController.changedAmountPerSec
        var section = 0
        while (section < audio.sectionStart.count) {
            if x < Double(audio.sectionStart[section]){
                break
            }
            section += 1
        }
        return section - 1
    }
    
    // 현재 구간 다시 재생
    @objc private func tapWaveBackButton() {
        let section = getSection()
        if section == -1 { return }
        
        var sectionStart = audio.sectionStart[section]
        // 더블 클릭 시에 이전 구간으로
        if playerController.player.currentTime - (Double(sectionStart) / playerController.changedAmountPerSec) < 0.2
            && section != 0 {
            sectionStart = audio.sectionStart[section-1]
        }
        
        playerController.intermitPlayer(type: .button)
        playerController.changePlayerTime(changedTime: Double(sectionStart) / playerController.changedAmountPerSec)
    }
    
    @objc private func tapWaveFrontButton() {
        let nextSection = getSection() + 1
        if nextSection != audio.sectionStart.count {
            let sectionStart = audio.sectionStart[nextSection]
            
            playerController.intermitPlayer(type: .button)
            playerController.changePlayerTime(changedTime: Double(sectionStart) / playerController.changedAmountPerSec)
        }
    }
    
    @objc private func tapWaveRepeatButton() {
        let section = getSection()
        if section == -1 { return }
        
        if playerController.shouldSectionRepeat == false {
            // 반복 설정
            playerController.shouldSectionRepeat = true
            playerController.positionSectionStart = audio.sectionStart[section]
            playerController.positionSectionEnd = audio.sectionEnd[section]
            
            waveRepeatButton.tintColor = UIColor(rgb: 0xEC8489)
        } else {
            // 반복 설정 해제
            playerController.shouldSectionRepeat = false
            playerController.positionSectionStart = nil
            playerController.positionSectionEnd = nil
            
            waveRepeatButton.tintColor = .label
        }
        
        NotificationCenter.default.post(
            name: Notification.Name("tapWaveRepeatButton"),
            object: nil,
            userInfo: nil
        )
    }
    
    
    @objc private func tapSpeedButton() {
        setSpeedSelector()
        speedSettingView.setNewRate(rate: playerController.player.rate)
    }
    
    @objc private func tapSpeedCompleteButton() {
        hideSpeedSelector()
        
        let rate = String(format: "%.1f", PlayerController.playerController.player.rate)
        speedButton.setTitle("\(rate)x", for: .normal)
        
    }
    
    @objc private func tapSpeedPlusButton() {
        if (round(playerController.player.rate * 10) / 10) >= 2.0 { return }
        
        playerController.player.rate += 0.1
        
        speedSettingView.setNewRate(rate: playerController.player.rate)
    }
    
    @objc private func tapSpeedMinusButton() {
        if (round(playerController.player.rate * 10) / 10) <= 0.5 { return }
        
        playerController.player.rate -= 0.1
        
        speedSettingView.setNewRate(rate: playerController.player.rate)
    }
    
}

// SpeedSettingView
extension PlayerLowerView {
    // 하단 safe inset 받아오기
    private func getSafeAreaBottomInset() -> CGFloat {
        let windowScene = UIApplication.shared.connectedScenes.first as! UIWindowScene
        let window = windowScene.windows.first!
        let bottomInset = window.safeAreaInsets.bottom
        
        return bottomInset
    }
    
    // SpeedSettingView 초기화
    func configureSpeedSelector() {
        
        let rate = String(format: "%.1f", PlayerController.playerController.player.rate)
        speedButton.setTitle("\(rate)x", for: .normal)
        
        self.addSubview(speedSettingView)
        
        let bottomInset = getSafeAreaBottomInset()
        speedSettingView.frame = CGRect(x: 0, y: bottomInset + 200, width: UIScreen.main.bounds.width, height: 100)
        
        speedSettingView.completeButton.addTarget(self, action: #selector(tapSpeedCompleteButton), for: .touchUpInside)
        speedSettingView.plusButton.addTarget(self, action: #selector(tapSpeedPlusButton), for: .touchUpInside)
        speedSettingView.minusButton.addTarget(self, action: #selector(tapSpeedMinusButton), for: .touchUpInside)
        
        speedSettingView.speedSlider.addTarget(self, action: #selector(speedSliderValChanged(slider:event:)), for: .valueChanged)
    }
    
    @objc func speedSliderValChanged(slider: UISlider, event: UIEvent) {
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .moved:
                let value = round(slider.value)
                if value != round(playerController.player.rate * 10) {
                    playerController.player.rate = value / 10
                    speedSettingView.setNewLabel(rate: value / 10)
                }
            case .ended:
                let value = round(slider.value)
                slider.setValue(value, animated: true)
            default:
                break
            }
        }
    }
    
    // SpeedSettingView 보이도록 애니메이션
    private func setSpeedSelector() {
        UIView.animate(withDuration: 0.3) {
            self.speedSettingView.frame = CGRect(x: 0, y: 90, width: UIScreen.main.bounds.width, height: 100)
        }
    }
    
    // SpeedSettingView 숨기기 애니메이션
    private func hideSpeedSelector() {
        let bottomInset = getSafeAreaBottomInset()
        UIView.animate(withDuration: 0.3) {
            self.speedSettingView.frame = CGRect(x: 0, y: bottomInset + 200, width: UIScreen.main.bounds.width, height: 100)
        }
    }
    
    
}

// PlayerLowerView UI
extension PlayerLowerView {
    private func setLayout() {
        
        self.addSubview(verticalStackView)
        
        verticalStackView.snp.makeConstraints{
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        
        normalControllerSV.snp.makeConstraints{
            $0.centerX.equalToSuperview()
            $0.width.equalTo(220)
            $0.height.equalTo(108)
        }
        
        
        lowerControllerStackView.snp.makeConstraints{
            $0.width.equalTo(300)
            $0.height.equalTo(72)
        }

        waveContollerContainer.snp.makeConstraints{
            $0.width.equalTo(300)
            $0.height.equalToSuperview()
        }

        waveControllerSV.snp.makeConstraints{
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.width.equalTo(300)
            $0.height.equalToSuperview().multipliedBy(0.9)
        }
        
    }
}

