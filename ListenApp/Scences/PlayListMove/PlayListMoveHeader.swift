//
//  PlayListMoveHeader.swift
//  ListenApp
//
//  Created by 곽지혁 on 2023/01/25.
//

import UIKit
import SnapKit

class PlayListMoveHeader : UIView {
    let headerTitle : String
    
    lazy var backBtn : UIButton = {
        let btn = UIButton()
        let btnConfigation = UIImage.SymbolConfiguration(font: .systemFont(ofSize: 20, weight: .bold), scale: .default)
        btn.setImage(UIImage(systemName: "chevron.backward", withConfiguration: btnConfigation), for: .normal)
        btn.tintColor = .label

        return btn
    }()
    
    private lazy var mainLabel : UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 35, weight: .bold)
        label.textColor = .label
        
        return label
    }()
    
    lazy var editBtn : UIButton = {
        let btn = UIButton()
        let btnConfigation = UIImage.SymbolConfiguration(font: .systemFont(ofSize: 20, weight: .bold), scale: .default)
        btn.setImage(UIImage(systemName: "ellipsis.circle", withConfiguration: btnConfigation), for: .normal)
        btn.tintColor = .label
        
        return btn
    }()

    lazy var moveBtn : UIButton = {
        let btn = UIButton()
        
        btn.setTitle("이동", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 20)
        btn.setTitleColor(.label, for: .normal)
        btn.setTitleColor(.secondaryLabel, for: .disabled)
        
        return btn
    }()
    
    init(frame : CGRect ,headerTitle: String) {
        self.headerTitle = headerTitle
        super.init(frame: frame)
        
        setLayout()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension PlayListMoveHeader {
    
    private func setLayout() {
        
        [mainLabel, editBtn, moveBtn].forEach{
            addSubview($0)
        }
        
        if headerTitle == "Documents" {
            mainLabel.text = "재생목록"
            mainLabel.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.leading.equalToSuperview().offset(20)
            }
            
        } else {
            mainLabel.text = headerTitle
            addSubview(backBtn)
            backBtn.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.leading.equalToSuperview().offset(20)
            }
            
            mainLabel.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.leading.equalTo(backBtn.snp.trailing).offset(15)
            }
        }
        
        
        moveBtn.snp.makeConstraints {
            $0.centerY.equalTo(mainLabel)
            $0.trailing.equalToSuperview().inset(20)
        }
        
        editBtn.snp.makeConstraints {
            $0.centerY.equalTo(mainLabel)
            $0.trailing.equalTo(moveBtn.snp.leading).offset(-15)
        }
        
    }
    
    
}


