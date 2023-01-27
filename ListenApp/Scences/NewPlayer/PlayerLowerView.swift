//
//  PlayerLowerView.swift
//  ListenApp
//
//  Created by 곽지혁 on 2023/01/27.
//

import UIKit

class PlayerLowerView : UIView {
    let playerController = PlayerController.playerController
    
    lazy var normalControllerSV : UIStackView = {
        let stackView = UIStackView()
        
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        
        stackView.tintColor = .label
        
        let playButton = UIButton()
        let secondFrontButton = UIButton()
        let secondBackButton = UIButton()
        
        let secondImageConfig = UIImage.SymbolConfiguration(font: .systemFont(ofSize: 30), scale: .default)
        
        secondBackButton.setImage(UIImage(systemName: "gobackward.\(Int(playerController.timeInterval))", withConfiguration: secondImageConfig), for: .normal)
        secondFrontButton.setImage(UIImage(systemName: "goforward.\(Int(playerController.timeInterval))", withConfiguration: secondImageConfig), for: .normal)
        setPlayButtonImage(btn : playButton)
        
        playButton.addTarget(self, action: #selector(tapPlayButton(_:)), for: .touchUpInside)
        secondBackButton.addTarget(self, action: #selector(tapSecondBackButton), for: .touchUpInside)
        secondFrontButton.addTarget(self, action: #selector(tapSecondFrontButton), for: .touchUpInside)
        
        
        [secondBackButton, playButton, secondFrontButton].forEach{
            stackView.addArrangedSubview($0)
        }
        
        return stackView
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
        
        waveBackButton.setImage(UIImage(systemName: "gobackward", withConfiguration: waveImageConfig), for: .normal)
        waveFrontButton.setImage(UIImage(systemName: "goforward", withConfiguration: waveImageConfig), for: .normal)
        
//        waveBackButton.addTarget(<#T##target: Any?##Any?#>, action: <#T##Selector#>, for: <#T##UIControl.Event#>)
//        waveFrontButton.addTarget(<#T##target: Any?##Any?#>, action: <#T##Selector#>, for: <#T##UIControl.Event#>)
        
        [waveBackButton, waveFrontButton].forEach{
            stackView.addArrangedSubview($0)
        }
        
        return stackView
    }()
    
    private lazy var waveContollerContainer : UIView = {
        let view = UIView()
        
        view.layer.borderWidth = 2
        view.layer.cornerRadius = 35
        
        view.addSubview(waveControllerSV)
        
        return view
    }()
    
    private lazy var verticalStackView : UIStackView = {
        let stackView = UIStackView()
        
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        
        
        [normalControllerSV, waveContollerContainer].forEach{
            stackView.addArrangedSubview($0)
        }
        
        return stackView
    }()
    
    override init(frame: CGRect) {
        super .init(frame: frame)
        
        setLayout()
        
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setPlayButtonImage(btn : UIButton) {
        let playImageConfig = UIImage.SymbolConfiguration(font: .systemFont(ofSize: 45), scale: .default)
        if playerController.status == .play {
            btn.setImage(UIImage(systemName: "pause.fill", withConfiguration: playImageConfig), for: .normal)
        } else {
            btn.setImage(UIImage(systemName: "play.fill", withConfiguration: playImageConfig), for: .normal)
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
        setPlayButtonImage(btn : sender)
    }
    
    @objc private func tapSecondBackButton() {
        let changedTime = playerController.player.currentTime - playerController.timeInterval
        playerController.changePlayerTime(changedTime: changedTime)
        
    }
    
    @objc private func tapSecondFrontButton() {
        let changedTime = playerController.player.currentTime + playerController.timeInterval
        playerController.changePlayerTime(changedTime: changedTime)
    }
    
    @objc private func waveBackButton() {
        
    }
    
    @objc private func waveFrontButton() {
        
    }
}



// PlayerLowerView UI
extension PlayerLowerView {
    private func setLayout() {
        
        self.addSubview(verticalStackView)
        
        verticalStackView.snp.makeConstraints{
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        
        waveContollerContainer.snp.makeConstraints{
            $0.width.equalTo(170)
            $0.height.equalToSuperview().multipliedBy(0.4)
        }
        
        normalControllerSV.snp.makeConstraints{
            $0.width.equalTo(300)
        }
        
        waveControllerSV.snp.makeConstraints{
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.9)
            $0.height.equalToSuperview().multipliedBy(0.9)
        }
    }
}

