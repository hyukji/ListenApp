//
//  SettingViewController.swift
//  ListenTo
//
//  Created by 곽지혁 on 2023/01/09.
//

import UIKit

enum SettingAccessory {
    case onlySwitch
    case onlyChevron
    case textChevron
}

struct settingCellStruct {
    let text : String
    let icon : String
    let accessory : SettingAccessory
    var accessoryText : String?
    var detailData : [String]?
    
    
    init(text: String, icon: String, accessory: SettingAccessory) {
        self.text = text
        self.icon = icon
        self.accessory = accessory
        self.accessoryText = nil
        self.detailData = nil
    }
    
    init(text: String, icon: String, accessory: SettingAccessory, accessoryText: String?, detailData: [String]?) {
        self.text = text
        self.icon = icon
        self.accessory = accessory
        self.accessoryText = accessoryText
        self.detailData = detailData
    }
    
    init(text: String, icon: String, accessory: SettingAccessory, accessoryText: String?) {
        self.text = text
        self.icon = icon
        self.accessory = accessory
        self.accessoryText = accessoryText
        self.detailData = nil
    }
    
}

class SettingViewController : UIViewController {
    
    private let normalSettingList: [settingCellStruct] = [
        settingCellStruct(text: "다크 모드", icon: "moon", accessory: .onlySwitch),
        settingCellStruct(text: "언어", icon: "globe", accessory: .textChevron, accessoryText: "한쿡말", detailData: ["한국어", "영어"])
        ]
    private let audioSettingList: [settingCellStruct] = [
        settingCellStruct(text: "시작 위치", icon: "play", accessory: .textChevron, accessoryText: "처음부터", detailData: ["처음부터", "종료된 시점부터"]),
        settingCellStruct(text: "재생 속도", icon: "forward.circle", accessory: .textChevron, accessoryText: "1.0xx"),
        settingCellStruct(text: "초단위 이동", icon: "arrow.rectanglepath", accessory: .textChevron, accessoryText: "5ss", detailData: ["1s", "2s","3s","5s","10s","15s"]),
        settingCellStruct(text: "파장 분석", icon: "waveform.badge.exclamationmark", accessory: .onlyChevron)
    ]
    private let supportSettingList: [settingCellStruct] = [
        settingCellStruct(text: "평가", icon: "star", accessory: .onlyChevron),
        settingCellStruct(text: "앱공유", icon: "paperplane", accessory: .onlyChevron),
        settingCellStruct(text: "오픈카카오톡", icon: "message", accessory: .onlyChevron)
    ]
    
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
        self.view.backgroundColor = .systemGray6
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.title = "설정"
        setLayout()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
}


// layout Setting
private extension SettingViewController {
    
    func setLayout() {
        [tableView].forEach{
            view.addSubview($0)
        }
        
        tableView.snp.makeConstraints{
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.bottom.equalToSuperview()
        }


    }
    
}



extension SettingViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var targetList : [settingCellStruct] = []
        switch indexPath.section {
        case 0:
            targetList = normalSettingList
        case 1:
            targetList = audioSettingList
        case 2:
            targetList = supportSettingList
        default:
            return
        }
        
        let data = targetList[indexPath.row]
        if data.accessory == .textChevron {
            let settingDetailView = SettingDetailView()
            settingDetailView.settingDetailData = data
            navigationController?.pushViewController(settingDetailView, animated: true)
        }
        else { print("nope")}
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return normalSettingList.count
        case 1:
            return audioSettingList.count
        case 2:
            return supportSettingList.count

        default:
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let SettingTableViewCell = tableView.dequeueReusableCell(withIdentifier: "SettingTableViewCell", for: indexPath) as? SettingTableViewCell else {return UITableViewCell() }
        
        let targetList : [settingCellStruct]
        
        switch indexPath.section {
        case 0:
            targetList = normalSettingList
        case 1:
            targetList = audioSettingList
        case 2:
            targetList = supportSettingList
        default:
            return UITableViewCell()
        }
        SettingTableViewCell.setLayout(data : targetList[indexPath.row])
        
        
        return SettingTableViewCell
    }
    
    
}
