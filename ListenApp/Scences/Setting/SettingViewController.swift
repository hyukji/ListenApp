//
//  SettingViewController.swift
//  ListenTo
//
//  Created by 곽지혁 on 2023/01/09.
//

import UIKit

class SettingViewController : UIViewController {
    
    private let normalSettingList: [String] = ["테마", "언어"]
    private let audioSettingList: [String] = ["배속", "시작위치"]
    private let supportSettingList: [String] = ["평가", "앱공유", "오픈카카오톡"]
    ///
    
    private lazy var tableView : UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.backgroundColor = .systemBackground
        tableView.rowHeight = 50
        
        tableView.register(SettingTableViewCell.self, forCellReuseIdentifier: "SettingTableViewCell")
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "설정"
        setLayout()
        
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
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalToSuperview()
        }


    }
    
}



extension SettingViewController : UITableViewDelegate, UITableViewDataSource {
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
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "일반"
        case 1:
            return "오디오 설정"
        case 2:
            return "지원"
        default:
            return ""
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let SettingTableViewCell = tableView.dequeueReusableCell(withIdentifier: "SettingTableViewCell", for: indexPath) as? SettingTableViewCell else {return UITableViewCell() }
        
        let settingList : [String]
        
        switch indexPath.section {
        case 0:
            settingList = normalSettingList
        case 1:
            settingList = audioSettingList
        case 2:
            settingList =  supportSettingList
        default:
            return UITableViewCell()
        }
        SettingTableViewCell.setLayout(img : "star", title : settingList[indexPath.row])
        
        
        return SettingTableViewCell
    }
    
    
}
