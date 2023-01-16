//
//  PlayerControllerView.swift
//  ListenTo
//
//  Created by 곽지혁 on 2023/01/10.
//

import UIKit
import AVFoundation

class PlayerControlView : UIView {
    var timeInterval = 5.0
    
    lazy var mainController : UIStackView = {
        let stackView = UIStackView()
        
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        
        stackView.tintColor = .label
        
        let waveBackButton = UIButton()
        let secondBackButton = UIButton()
        let playButton = UIButton()
        let waveFrontButton = UIButton()
        let secondFrontButton = UIButton()
        
        let waveImageConfig = UIImage.SymbolConfiguration(font: .systemFont(ofSize: 35, weight: .regular), scale: .default)
        let secondImageConfig = UIImage.SymbolConfiguration(font: .systemFont(ofSize: 33, weight: .regular), scale: .default)
        let playImageConfig = UIImage.SymbolConfiguration(font: .systemFont(ofSize: 45), scale: .default)
        
        waveBackButton.setImage(UIImage(systemName: "gobackward", withConfiguration: waveImageConfig), for: .normal)
        secondBackButton.setImage(UIImage(systemName: "gobackward", withConfiguration: secondImageConfig), for: .normal)
        playButton.setImage(UIImage(systemName: "play.fill", withConfiguration: playImageConfig), for: .normal)
        secondFrontButton.setImage(UIImage(systemName: "goforward", withConfiguration: secondImageConfig), for: .normal)
        waveFrontButton.setImage(UIImage(systemName: "goforward", withConfiguration: waveImageConfig), for: .normal)
        
        playButton.addTarget(self, action: #selector(tapPlayButton(_:)), for: .touchUpInside)
        secondBackButton.addTarget(self, action: #selector(tapSecondBackButton), for: .touchUpInside)
        secondFrontButton.addTarget(self, action: #selector(tapSecondFrontButton), for: .touchUpInside)
//        waveBackButton.addTarget(<#T##target: Any?##Any?#>, action: <#T##Selector#>, for: <#T##UIControl.Event#>)
//        waveFrontButton.addTarget(<#T##target: Any?##Any?#>, action: <#T##Selector#>, for: <#T##UIControl.Event#>)
        
        
        [waveBackButton, secondBackButton, playButton, secondFrontButton, waveFrontButton].forEach{
            stackView.addArrangedSubview($0)
        }
        
        return stackView
    }()
    
    
    private lazy var subController : UIStackView = {
        let stackView = UIStackView()

        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        
        stackView.tintColor = .label
        
        let waveRepeatButton = UIButton()
        let abRepeatButton = UIButton()
        let speedButton = UIButton()
        
        let repeatImageConfig = UIImage.SymbolConfiguration(font: .systemFont(ofSize: 22), scale: .default)
        let speedTitle = UILabel()
        
        waveRepeatButton.setImage(UIImage(systemName: "repeat.1", withConfiguration: repeatImageConfig), for: .normal)
        abRepeatButton.setImage(UIImage(systemName: "repeat", withConfiguration: repeatImageConfig), for: .normal)
        speedButton.setTitle("1.0x", for: .normal)
        speedButton.setTitleColor(.label, for: .normal)
        
        [waveRepeatButton, speedButton, abRepeatButton].forEach{
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
    
}
    

// PlayerControlView functions of tap UIButton
extension PlayerControlView {
    @objc private func tapPlayButton(_ sender: UIButton) {
        let playImageConfig = UIImage.SymbolConfiguration(font: .systemFont(ofSize: 45), scale: .default)
        if player.isPlaying {
            player.pause()
            sender.setImage(UIImage(systemName: "pause.fill", withConfiguration: playImageConfig), for: .normal)
        } else {
            player.play()
            sender.setImage(UIImage(systemName: "play.fill", withConfiguration: playImageConfig), for: .normal)
        }
    }
    
    @objc private func tapSecondBackButton() {
        let currentTime = player.currentTime
        player.currentTime = currentTime - timeInterval
    }
    
    @objc private func tapSecondFrontButton() {
        let currentTime = player.currentTime
        player.currentTime = currentTime + timeInterval
    }
    
    @objc private func waveBackButton() {
        
    }
    
    @objc private func waveFrontButton() {
        
    }
}




extension PlayerControlView {
    private func setLayout() {
        
        
        [mainController, subController].forEach{
            addSubview($0)
        }
        
        subController.snp.makeConstraints{
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        mainController.snp.makeConstraints{
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(subController.snp.top).offset(-22)
        }
        
        
        
    }
    
    
}
