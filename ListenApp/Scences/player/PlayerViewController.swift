//
//  PlayerViewController.swift
//  ListenTo
//
//  Created by 곽지혁 on 2023/01/10.
//

import UIKit
import AVFoundation

class PlayerViewController : UIViewController {
    
    private lazy var playerControllerView = PlayerControlView()
    private lazy var playerProgressView = PlayerProgressView()
    private lazy var pageViewController = PageViewController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        setLayout()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        guard let timer = playerProgressView.timer else { return }
        if timer.isValid { timer.invalidate() }
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
private extension PlayerViewController {
    func setNavigationBar() {
        
        navigationItem.title = "예시1"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(backToRootVC))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "slider.horizontal.3"), style: .plain, target: self, action: #selector(tapPlayerSetting))
        
        navigationItem.leftBarButtonItem?.tintColor = .label
        navigationItem.rightBarButtonItem?.tintColor = .label
    }
    
    func setLayout() {
        tabBarController?.tabBar.isHidden = true
        tabBarController?.tabBar.isTranslucent = true
        
        addChild(pageViewController)
        
        [playerControllerView, playerProgressView, pageViewController.view].forEach{
            view.addSubview($0)
        }
        
        playerControllerView.snp.makeConstraints{
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(50)
            $0.height.equalTo(130)
        }
        
        playerProgressView.snp.makeConstraints{
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(playerControllerView.snp.top)
            $0.height.equalTo(45)
        }
        
        pageViewController.view.snp.makeConstraints{
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(playerProgressView.snp.top).offset(-40)
            $0.top.equalTo(view.safeAreaLayoutGuide)
        }
        
    }
}
