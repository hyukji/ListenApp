//
//  SettingDetailView.swift
//  ListenApp
//
//  Created by 곽지혁 on 2023/02/22.
//

import UIKit

class SettingDetailView : UIViewController {
    var settingDetailData : settingCellStruct?
    
    private lazy var tableView : UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = 50
        
        tableView.register(SettingDetailTableViewCell.self, forCellReuseIdentifier: "SettingDetailTableViewCell")
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemGray6
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationItem.title = settingDetailData?.text
        setLayout()
        
        
    }
    
}


// layout Setting
private extension SettingDetailView {
    
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



extension SettingDetailView : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingDetailData?.detailData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let settingDetailTableViewCell = tableView.dequeueReusableCell(withIdentifier: "SettingDetailTableViewCell", for: indexPath) as? SettingDetailTableViewCell else {return UITableViewCell() }
        
        let detailData : [String] = settingDetailData!.detailData!
        settingDetailTableViewCell.setLayout(text : detailData[indexPath.row])
        
        return settingDetailTableViewCell
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
