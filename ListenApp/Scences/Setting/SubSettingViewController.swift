//
//  SettingDetailView.swift
//  ListenApp
//
//  Created by 곽지혁 on 2023/02/22.
//

import UIKit

protocol SubSettingProtocol : AnyObject {
    func ChangeSetting(indexPath : IndexPath, selectedInt : Int)
}

class SubSettingViewController : UIViewController {
    var settingCategory : SettingCategory?
    var subSettingData : [String]?
    var selected : Int?
    var SettingindexPath : IndexPath!
    
    weak var delegate : SubSettingProtocol?
    
    private lazy var tableView : UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(SettingDetailTableViewCell.self, forCellReuseIdentifier: "SettingDetailTableViewCell")
        
        // tableView의 계산된 높이 값은 68이다. 즉 Default Height이다.
//                UITableView.estimatedRowHeight = 68.0
//                // tableView의 rowHeight는 유동적일 수 있다
//                UITableView.rowHeight = UITableViewAutomaticDimension
        
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        
        navigationController?.navigationBar.prefersLargeTitles = false
//        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(popVC))
        navigationItem.title = settingCategory?.text
        setLayout()
        
    }
    
}



// layout Setting
private extension SubSettingViewController {
    
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



extension SubSettingViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subSettingData?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let settingDetailTableViewCell = tableView.dequeueReusableCell(withIdentifier: "SettingDetailTableViewCell", for: indexPath) as? SettingDetailTableViewCell else {return UITableViewCell() }
        
        settingDetailTableViewCell.setLayout(text : subSettingData![indexPath.row])
        if selected! == indexPath.row {
            settingDetailTableViewCell.accessoryType = .checkmark
        }
        settingDetailTableViewCell.selectionStyle = .none
        
        
        return settingDetailTableViewCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 현재 checkMark 되어 있는 row를 클릭시 그냥 넘기기
        if selected! == indexPath.row { return }
        else {
            if settingCategory?.name == "thema" {
                view.window?.overrideUserInterfaceStyle = AdminUserDefault.shared.themas[indexPath.row]
            } else if settingCategory?.name == "language" {
                print("language")
            }
            
            // 새로운 row select -> 데디터 저장 및 checkMark업데이트
            selected = indexPath.row
            delegate?.ChangeSetting(indexPath: SettingindexPath, selectedInt: indexPath.row)
            for row in 0...(subSettingData?.count ?? 0){
                if let cell = tableView.cellForRow(at: IndexPath(row: row, section: 0)) {
                    if row == indexPath.row {
                        cell.accessoryType = .checkmark
                    } else {
                        cell.accessoryType = .none
                    }
                }
            }
        }
        
    }
    
}


class SettingDetailTableViewCell : UITableViewCell {
    
    private lazy var titleLabel : UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .label
        
        return label
    }()
//
//    private lazy var chevronImgView : UIImageView = {
//        let imageView = UIImageView()
//        imageView.image = UIImage(systemName: "chevron.right")
//        imageView.tintColor = .secondaryLabel
//
//        return imageView
//    }()
    
    
    
    func setLayout(text : String) {
        titleLabel.text = text
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints{
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(15)
        }
        
        
    }
    
    
}
