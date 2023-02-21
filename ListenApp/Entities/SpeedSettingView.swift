//
//  SpeedSettingView.swift
//  ListenApp
//
//  Created by 곽지혁 on 2023/02/21.
//

import UIKit

class SpeedSettingView: UIView {
    
    let slider : UISlider = {
        let slider = UISlider()
        
        slider.value = 10
        slider.minimumValue = 5
        slider.maximumValue = 20
        
        return slider
    }()
    
    private lazy var turtle : UIImageView = {
        let imageView = UIImageView()
        let imageConfig = UIImage.SymbolConfiguration(font: .systemFont(ofSize: 20, weight: .regular), scale: .default)
        imageView.image = UIImage(systemName: "tortoise", withConfiguration: imageConfig)
        
        return imageView
    }()
    
    private lazy var rabbit : UIImageView = {
        let imageView = UIImageView()
        let imageConfig = UIImage.SymbolConfiguration(font: .systemFont(ofSize: 20, weight: .regular), scale: .default)
        imageView.image = UIImage(systemName: "hare", withConfiguration: imageConfig)
        
        return imageView
    }()
    
    let plusButton : UIButton = {
        let button = UIButton()
        let imageConfig = UIImage.SymbolConfiguration(font: .systemFont(ofSize: 20, weight: .regular), scale: .default)
        button.setImage(UIImage(systemName: "plus.circle", withConfiguration: imageConfig), for: .normal)
        return button
    }()
    
    let minusButton : UIButton = {
        let button = UIButton()
        let imageConfig = UIImage.SymbolConfiguration(font: .systemFont(ofSize: 20, weight: .regular), scale: .default)
        button.setImage(UIImage(systemName: "minus.circle", withConfiguration: imageConfig), for: .normal)
        return button
    }()
    
    let speedLabel : UILabel = {
        let lbl = UILabel()
        let rate = String(format: "%.1f", PlayerController.playerController.player.rate)
        lbl.text = "\(rate)x"
        lbl.font = .systemFont(ofSize: 20, weight: .bold)
        
        return lbl
    }()
    
    lazy var speedLabelSV : UIStackView = {
        let stackView = UIStackView()
        
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        
        stackView.tintColor = .label
        
        [minusButton, speedLabel, plusButton].forEach{
            stackView.addArrangedSubview($0)
        }
        
        return stackView
    }()
    
    lazy var speedSliderSV : UIStackView = {
        let stackView = UIStackView()
        
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        
        stackView.tintColor = .label
        
        [turtle, slider, rabbit].forEach{
            stackView.addArrangedSubview($0)
        }
        
        return stackView
    }()
    
    
    let completeButton : UIButton = {
        let button = UIButton()
        button.setTitle("완료", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setLayout() {
        self.backgroundColor = .systemBackground
        
        [speedLabelSV, completeButton, speedSliderSV].forEach{
            self.addSubview($0)
        }
        
        speedLabelSV.snp.makeConstraints{
            $0.top.equalToSuperview().inset(15)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(40)
            $0.width.equalTo(150)
        }
        
        completeButton.snp.makeConstraints{
            $0.centerY.equalTo(speedLabelSV)
            $0.trailing.equalToSuperview().inset(20)
        }
        
        speedSliderSV.snp.makeConstraints{
            $0.top.equalTo(speedLabelSV.snp.bottom)
            $0.bottom.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.width.equalTo(300)
        }
        
    }
    
    func setNewRate(rate : Float) {
        let rateString = String(format: "%.1f", rate)
        speedLabel.text = "\(rateString)x"
        slider.value = rate * 10
    }
    
}
