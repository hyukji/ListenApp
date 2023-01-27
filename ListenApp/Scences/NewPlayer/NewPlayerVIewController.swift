//
//  NewPlayerVIewController.swift
//  ListenApp
//
//  Created by 곽지혁 on 2023/01/27.
//

import UIKit


class NewPlayerVIewController : UIViewController {
    
    private lazy var playerUpperView = PlayerUpperView()
    private lazy var playerLowerView = PlayerLowerView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        setLayout()
    }
    
    // go back rootViewVC(PlayListVC or SettingVC)
    @objc func backToRootVC() {
        tabBarController?.tabBar.isHidden = false
        tabBarController?.tabBar.isTranslucent = true
        
        navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func tapPlayerSetting() {
        print("tapPlayerSetting")
    }
    
    
}


// UI Design
private extension NewPlayerVIewController {
    func setNavigationBar() {
        
        navigationItem.title = PlayerController.playerController.audio?.title
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(backToRootVC))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "slider.horizontal.3"), style: .plain, target: self, action: #selector(tapPlayerSetting))
        
        navigationItem.leftBarButtonItem?.tintColor = .label
        navigationItem.rightBarButtonItem?.tintColor = .label
    }
    
    func setLayout() {
        tabBarController?.tabBar.isHidden = true
        tabBarController?.tabBar.isTranslucent = true
        
        [playerUpperView, playerLowerView].forEach{
            view.addSubview($0)
        }
        
        playerUpperView.snp.makeConstraints{
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(playerLowerView.snp.top)
            $0.top.equalTo(view.safeAreaLayoutGuide)
        }
        
        playerLowerView.snp.makeConstraints{
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(15)
            $0.height.equalTo(180)
        }
        
    }
}
