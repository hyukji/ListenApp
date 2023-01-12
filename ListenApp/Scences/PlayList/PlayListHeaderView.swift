//
//  PlayListHeaderView.swift
//  ListenTo
//
//  Created by 곽지혁 on 2023/01/09.
//

import UIKit
import SnapKit

class PlayListHeaderView : UIView {
    private lazy var mainLabel : UILabel = {
        let label = UILabel()
        label.text = "재생목록"
        label.font = .systemFont(ofSize: 35, weight: .bold)
        label.textColor = .label
        
        
        return label
    }()
    
    private lazy var editBtn : UIButton = {
        let btn = UIButton()
        btn.setTitle("편집", for: .normal)
        btn.setTitleColor(.label, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        
        btn.addTarget(self, action: #selector(tapEditBtn), for: .touchUpInside)
        
        return btn
    }()

    private lazy var plusBtn : UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "plus"), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        btn.tintColor = .label
        
        btn.addTarget(self, action: #selector(tapPlusBtn), for: .touchUpInside)

        return btn
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setLayout()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @objc private func tapEditBtn() {
        print("tapEditBtn")
    }
    
    
    @objc private func tapPlusBtn() {
        print("tapPlusBtn")
    }
    
}

extension PlayListHeaderView {
    
    private func setLayout() {
        
        [mainLabel, editBtn, plusBtn].forEach{
            addSubview($0)
        }
        
        mainLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(20)
            $0.leading.equalToSuperview().offset(20)
        }
        
        editBtn.snp.makeConstraints {
            $0.centerY.equalTo(mainLabel)
            $0.trailing.equalToSuperview().inset(20)
        }

        plusBtn.snp.makeConstraints {
            $0.centerY.equalTo(mainLabel)
            $0.trailing.equalTo(editBtn.snp.leading).offset(-10)
        }

    }
    
    
}


