//
//  SettingViewController.swift
//  ListenTo
//
//  Created by 곽지혁 on 2023/01/09.
//

import UIKit

enum SettingAccessory {
    case onlyChevron
    case textChevron
}

struct settingCellStruct {
    let name : String
    let text : String
    let icon : String
    let accessory : SettingAccessory
    var accessoryText : String?
    var detailData : [String]?
    var selectedIndex : Int?
    
    
    init(name : String, text: String, icon: String, accessory: SettingAccessory) {
        self.name = name
        self.text = text
        self.icon = icon
        self.accessory = accessory
        self.accessoryText = nil
        self.detailData = nil
        self.selectedIndex = nil
    }
    
    init(name : String, text: String, icon: String, accessory: SettingAccessory, accessoryText: String, detailData: [String], selectedIndex : Int) {
        self.name = name
        self.text = text
        self.icon = icon
        self.accessory = accessory
        self.accessoryText = accessoryText
        self.detailData = detailData
        self.selectedIndex = selectedIndex
    }
    
    init(name : String, text: String, icon: String, accessory: SettingAccessory, accessoryText: String) {
        self.name = name
        self.text = text
        self.icon = icon
        self.accessory = accessory
        self.accessoryText = accessoryText
        self.detailData = nil
        self.selectedIndex = nil
    }
    
}

class SettingViewController : UIViewController {
    
    private var normalSettingList: [settingCellStruct] = []
    private var audioSettingList: [settingCellStruct] = []
    private var supportSettingList: [settingCellStruct] = []
    
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
        setData()
        setLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func setData() {
        normalSettingList = [
            settingCellStruct(name: "thema", text: "테마", icon: "moon", accessory: .textChevron, accessoryText: "라이트?", detailData: ["라이트 모드", "다크 모드"], selectedIndex: AdminUserDefault.thema),
            settingCellStruct(name: "language", text: "언어", icon: "globe", accessory: .textChevron, accessoryText: "한쿡말", detailData: ["한국어", "영어"], selectedIndex: AdminUserDefault.langauge)
        ]
        audioSettingList = [
            settingCellStruct(name: "startLocation", text: "시작 위치", icon: "play", accessory: .textChevron, accessoryText: "처음부터", detailData: ["처음부터", "종료된 시점부터"], selectedIndex: AdminUserDefault.startLocation),
            settingCellStruct(name: "audioSpeed", text: "재생 속도", icon: "forward.circle", accessory: .textChevron, accessoryText: "1.0xx"),
            settingCellStruct(name: "secondTerm", text: "초단위 이동", icon: "arrow.rectanglepath", accessory: .textChevron, accessoryText: "5ss", detailData: ["1s", "2s","3s","5s","10s","15s"], selectedIndex: AdminUserDefault.secondTerm),
            settingCellStruct(name: "waveAnalysis", text: "파장 분석", icon: "waveform.badge.exclamationmark", accessory: .onlyChevron)
        ]
        supportSettingList = [
            settingCellStruct(name: "", text: "평가", icon: "star", accessory: .onlyChevron),
            settingCellStruct(name: "", text: "앱공유", icon: "paperplane", accessory: .onlyChevron),
            settingCellStruct(name: "", text: "오픈카카오톡", icon: "message", accessory: .onlyChevron)
        ]
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
            settingDetailView.SettingindexPath = indexPath
            settingDetailView.delegate = self
            
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
        SettingTableViewCell.selectionStyle = .none
        
        
        return SettingTableViewCell
    }
    
    
}

extension SettingViewController : settingDetailProtocol {
    func ChangeSetting(indexPath: IndexPath, selectedInt: Int) {
        guard let cell = tableView.cellForRow(at: indexPath) as? SettingTableViewCell else {return}
        switch indexPath.section {
        case 0:
            normalSettingList[indexPath.row].selectedIndex = selectedInt
            cell.setLayout(data : normalSettingList[indexPath.row])
            AdminUserDefault().saveData(name: normalSettingList[indexPath.row].name, new: selectedInt)
        case 1:
            audioSettingList[indexPath.row].selectedIndex = selectedInt
            cell.setLayout(data : audioSettingList[indexPath.row])
            AdminUserDefault().saveData(name: audioSettingList[indexPath.row].name, new: selectedInt)
        case 2:
            supportSettingList[indexPath.row].selectedIndex = selectedInt
            cell.setLayout(data : supportSettingList[indexPath.row])
            AdminUserDefault().saveData(name: supportSettingList[indexPath.row].name, new: selectedInt)
        default:
            return
        }
    }
}
