//
//  waveSettingViewController.swift
//  ListenApp
//
//  Created by 곽지혁 on 2023/02/27.
//

import UIKit

protocol WaveSettingProtocol : AnyObject {
    func ChangeWaveSetting(selectedValue : Float)
}

class WaveSettingViewController : UIViewController {
    
    var settingCategory : SettingCategory?
    var selectedValue : Float?
    
    weak var delegate : WaveSettingProtocol?
    
    private lazy var tableView : UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(WaveSettingTableViewCell.self, forCellReuseIdentifier: "WaveSettingTableViewCell")
        
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


extension WaveSettingViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let waveSettingTableViewCell = tableView.dequeueReusableCell(withIdentifier: "WaveSettingTableViewCell", for: indexPath) as? WaveSettingTableViewCell else {return UITableViewCell() }
        
        waveSettingTableViewCell.selectionStyle = .none
        
        waveSettingTableViewCell.val = selectedValue ?? 1.0
        waveSettingTableViewCell.delegate = delegate
        waveSettingTableViewCell.setButtonFunc()
        waveSettingTableViewCell.setLayout()
        
        return waveSettingTableViewCell
    }

}



class WaveSettingTableViewCell : UITableViewCell {
    var val : Float = 1.0
    
    weak var delegate : WaveSettingProtocol?
    
    let waveSlider : UISlider = {
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
    
    let waveLabel : UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 20, weight: .bold)
        
        return lbl
    }()
    
    lazy var waveLabelSV : UIStackView = {
        let stackView = UIStackView()
        
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        
        stackView.tintColor = .label
        
        [minusButton, waveLabel, plusButton].forEach{
            stackView.addArrangedSubview($0)
        }
        
        return stackView
    }()
    
    lazy var waveSliderSV : UIStackView = {
        let stackView = UIStackView()
        
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        
        stackView.tintColor = .label
        
        [turtle, waveSlider, rabbit].forEach{
            stackView.addArrangedSubview($0)
        }
        
        stackView.setCustomSpacing(5, after: turtle)
        stackView.setCustomSpacing(5, after: waveSlider)
        
        return stackView
    }()
    
    
    @objc func waveSliderValChanged(slider: UISlider, event: UIEvent) {
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .moved:
                let value = round(slider.value)
                if value != round(val * 10) {
                    val = value / 10
                    setNewRate()
                }
            case .ended:
                let value = round(slider.value)
                slider.setValue(value, animated: true)
                delegate?.ChangeWaveSetting(selectedValue: val)
            default:
                break
            }
        }
    }
    
    @objc private func tapWavePlusButton() {
        let newVal = round(val * 10 + 1) / 10
        if newVal > 2.0 { return }
        
        val = newVal
        delegate?.ChangeWaveSetting(selectedValue: val)
        setNewRate()
    }
    
    @objc private func tapWaveMinusButton() {
        let newVal = (round(val * 10 - 1) / 10)
        if newVal < 0.5 { return }
        
        val = newVal
        delegate?.ChangeWaveSetting(selectedValue: val)
        setNewRate()
    }
    
    
    func setButtonFunc() {
        plusButton.addTarget(self, action: #selector(tapWavePlusButton), for: .touchUpInside)
        minusButton.addTarget(self, action: #selector(tapWaveMinusButton), for: .touchUpInside)
        waveSlider.addTarget(self, action: #selector(waveSliderValChanged(slider:event:)), for: .valueChanged)
    }
    
    func setLayout() {
        self.backgroundColor = .systemBackground
        
        setNewRate()
        waveLabel.text = "\(val)x"
        
        [waveLabelSV, waveSliderSV].forEach{
            self.addSubview($0)
        }
        
        waveLabelSV.snp.makeConstraints{
            $0.top.equalToSuperview().inset(15)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(40)
            $0.width.equalTo(150)
        }
        
        waveSliderSV.snp.makeConstraints{
            $0.top.equalTo(waveLabelSV.snp.bottom)
            $0.bottom.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.width.equalTo(300)
        }
        
    }

    func setNewRate() {
        setNewLabel()
        waveSlider.value = val * 10
    }
    
    func setNewLabel() {
        let rateString = String(format: "%.1f", val)
        waveLabel.text = "\(rateString)x"
    }
    
}

