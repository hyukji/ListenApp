//
//  SettingViewController.swift
//  ListenTo
//
//  Created by 곽지혁 on 2023/01/09.
//

import UIKit


struct SettingCategory {
    let name : String
    let text : String
    let icon : String
    var type : SettingType
}

enum SettingType : Equatable {
    case subSetting
    case another
}


class SettingViewController : UIViewController {
    let adminUserDefault = AdminUserDefault.shared
    
    private var normalSettingList: [SettingCategory] = []
    private var audioSettingList: [SettingCategory] = []
    private var supportSettingList: [SettingCategory] = []
    
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
            SettingCategory(name: "thema", text: "테마", icon: "moon", type: .subSetting),
            SettingCategory(name: "language", text: "언어", icon: "globe", type: .subSetting)
        ]
        audioSettingList = [
            SettingCategory(name: "startLocation", text: "시작 위치", icon: "play", type: .subSetting),
            SettingCategory(name: "audioSpeed", text: "재생 속도", icon: "forward.circle", type: .subSetting),
            SettingCategory(name: "secondTerm", text: "초단위 이동", icon: "arrow.rectanglepath", type: .subSetting),
            SettingCategory(name: "waveAnalysis", text: "파장 분석", icon: "waveform.badge.exclamationmark", type: .another)
        ]
        supportSettingList = [
            SettingCategory(name: "", text: "평가", icon: "star", type: .another),
            SettingCategory(name: "", text: "앱공유", icon: "paperplane", type: .another),
            SettingCategory(name: "", text: "오픈카카오톡", icon: "message", type: .another)
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
        var targetList : [SettingCategory] = []
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
        
        if data.type == .another {
            print("nope")
        } else {
            let subSettingVC = SubSettingViewController()
            
            subSettingVC.settingCategory = data
            subSettingVC.subSettingData = adminUserDefault.settingData[data.name] ?? []
            subSettingVC.selected = adminUserDefault.settingSelected[data.name] ?? 0
            subSettingVC.SettingindexPath = indexPath
            subSettingVC.delegate = self
            
            navigationController?.pushViewController(subSettingVC, animated: true)
        }
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
        
        let targetList : [SettingCategory]
        
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

extension SettingViewController : SubSettingProtocol {
    func ChangeSetting(indexPath: IndexPath, selectedInt: Int) {
        guard let cell = tableView.cellForRow(at: indexPath) as? SettingTableViewCell else {return}
        switch indexPath.section {
        case 0:
            adminUserDefault.saveSettingData(name: normalSettingList[indexPath.row].name, new: selectedInt)
            cell.setLayout(data : normalSettingList[indexPath.row])
        case 1:
            adminUserDefault.saveSettingData(name: audioSettingList[indexPath.row].name, new: selectedInt)
            cell.setLayout(data : audioSettingList[indexPath.row])
        case 2:
            adminUserDefault.saveSettingData(name: supportSettingList[indexPath.row].name, new: selectedInt)
            cell.setLayout(data : supportSettingList[indexPath.row])
        default:
            return
        }
    }
}
