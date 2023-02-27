//
//  RateSettingViewController.swift
//  ListenApp
//
//  Created by 곽지혁 on 2023/02/27.
//

import UIKit

protocol RateSettingProtocol : AnyObject {
    func ChangeRateSetting(selectedValue : Float)
}

class RateSettingViewController : UIViewController {
    
    var settingCategory : SettingCategory?
    var selectedValue : Float?
    
    weak var delegate : RateSettingProtocol?
    
    private lazy var tableView : UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(RateSettingTableViewCell.self, forCellReuseIdentifier: "RateSettingTableViewCell")
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.tintColor = .label
        navigationItem.title = settingCategory?.text
        setLayout()
        
    }
    
    // layout Setting
    func setLayout() {
        [tableView].forEach{
            view.addSubview($0)
        }
        
        tableView.snp.makeConstraints{
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalToSuperview()
        }

    }

}


extension RateSettingViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let rateSettingTableViewCell = tableView.dequeueReusableCell(withIdentifier: "RateSettingTableViewCell", for: indexPath) as? RateSettingTableViewCell else {return UITableViewCell() }
        
        rateSettingTableViewCell.selectionStyle = .none
        
        rateSettingTableViewCell.rate = selectedValue ?? 1.0
        rateSettingTableViewCell.delegate = delegate
        rateSettingTableViewCell.setButtonFunc()
        rateSettingTableViewCell.setLayout()
        
        return rateSettingTableViewCell
    }

}



class RateSettingTableViewCell : UITableViewCell {
    var rate : Float = 1.0
    
    weak var delegate : RateSettingProtocol?
    
    let speedSlider : UISlider = {
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
        
        [turtle, speedSlider, rabbit].forEach{
            stackView.addArrangedSubview($0)
        }
        
        stackView.setCustomSpacing(5, after: turtle)
        stackView.setCustomSpacing(5, after: speedSlider)
        
        return stackView
    }()
    
    
    @objc func speedSliderValChanged(slider: UISlider, event: UIEvent) {
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .moved:
                let value = round(slider.value)
                if value != round(rate * 10) {
                    rate = value / 10
                    setNewRate()
                }
            case .ended:
                let value = round(slider.value)
                slider.setValue(value, animated: true)
                delegate?.ChangeRateSetting(selectedValue: rate)
            default:
                break
            }
        }
    }
    
    @objc private func tapSpeedPlusButton() {
        let newRate = round(rate * 10 + 1) / 10
        if newRate > 2.0 { return }
        
        rate = newRate
        delegate?.ChangeRateSetting(selectedValue: rate)
        setNewRate()
    }
    
    @objc private func tapSpeedMinusButton() {
        let newRate = (round(rate * 10 - 1) / 10)
        if newRate < 0.5 { return }
        
        rate = newRate
        delegate?.ChangeRateSetting(selectedValue: rate)
        setNewRate()
    }
    
    
    func setButtonFunc() {
        plusButton.addTarget(self, action: #selector(tapSpeedPlusButton), for: .touchUpInside)
        minusButton.addTarget(self, action: #selector(tapSpeedMinusButton), for: .touchUpInside)
        speedSlider.addTarget(self, action: #selector(speedSliderValChanged(slider:event:)), for: .valueChanged)
    }
    
    func setLayout() {
        self.backgroundColor = .systemBackground
        
        setNewRate()
        speedLabel.text = "\(rate)x"
        
        [speedLabelSV, speedSliderSV].forEach{
            self.addSubview($0)
        }
        
        speedLabelSV.snp.makeConstraints{
            $0.top.equalToSuperview().inset(15)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(40)
            $0.width.equalTo(150)
        }
        
        speedSliderSV.snp.makeConstraints{
            $0.top.equalTo(speedLabelSV.snp.bottom)
            $0.bottom.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.width.equalTo(300)
        }
        
    }

    func setNewRate() {
        setNewLabel()
        speedSlider.value = rate * 10
    }
    
    func setNewLabel() {
        let rateString = String(format: "%.1f", rate)
        speedLabel.text = "\(rateString)x"
    }
    
}
