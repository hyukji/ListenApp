//
//  PlayerSettingViewController.swift
//  ListenApp
//
//  Created by 곽지혁 on 2023/03/07.
//


import UIKit


class PlayerSettingViewController : UIViewController {
    let adminUserDefault = AdminUserDefault.shared
    
    private var audioSettingList: [SettingCategory] = []
    
    private lazy var tableView : UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = 50
        
        tableView.register(SettingTableViewCell.self, forCellReuseIdentifier: "SettingTableViewCell")
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemGroupedBackground
        self.navigationItem.title = "오디오 설정"
        setData()
        setLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    func setData() {
        audioSettingList = [
            SettingCategory(name: "startLocation", text: "시작 위치", icon: "play", type: .listSetting),
            SettingCategory(name: "rateSetting", text: "초기 재생 속도", icon: "forward.circle", type: .rateSetting),
            SettingCategory(name: "secondTerm", text: "초단위 이동", icon: "arrow.triangle.2.circlepath", type: .listSetting),
            SettingCategory(name: "repeatTerm", text: "반복 대기시간", icon: "repeat.circle", type: .listSetting)
        ]
    }
    
}


// layout Setting
private extension PlayerSettingViewController {
    
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



extension PlayerSettingViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let data = audioSettingList[indexPath.row]
        switch data.type {
        case .listSetting:
            let subSettingVC = ListSettingViewController()
            
            subSettingVC.settingCategory = data
            subSettingVC.subSettingData = adminUserDefault.settingData[data.name] ?? []
            subSettingVC.selected = adminUserDefault.settingSelected[data.name] ?? 0
            subSettingVC.SettingindexPath = indexPath
            subSettingVC.delegate = self
            
            navigationController?.pushViewController(subSettingVC, animated: true)
        case .rateSetting:
            let rateSettingVC = RateSettingViewController()
            
            rateSettingVC.settingCategory = data
            rateSettingVC.selectedValue = adminUserDefault.rateSetting
            rateSettingVC.delegate = self
            
            navigationController?.pushViewController(rateSettingVC, animated: true)
        default:
            print("nope")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return audioSettingList.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let SettingTableViewCell = tableView.dequeueReusableCell(withIdentifier: "SettingTableViewCell", for: indexPath) as? SettingTableViewCell else {return UITableViewCell() }
        
        SettingTableViewCell.setLayout(data : audioSettingList[indexPath.row])
        SettingTableViewCell.selectionStyle = .none
        
        return SettingTableViewCell
    }
    
    
}

extension PlayerSettingViewController : ListSettingProtocol {
    func ChangeListSetting(indexPath: IndexPath, selectedInt: Int) {
        adminUserDefault.saveListSettingData(name: audioSettingList[indexPath.row].name, new: selectedInt)
    }
}



extension PlayerSettingViewController : RateSettingProtocol {
    func ChangeRateSetting(selectedValue: Float) {
        adminUserDefault.saveRateSettingData(new: selectedValue)
        if PlayerController.playerController.player != nil {
            PlayerController.playerController.player.rate = AdminUserDefault.shared.rateSetting
        }
    }
}
