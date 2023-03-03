//
//  NewPlayerVIewController.swift
//  ListenApp
//
//  Created by 곽지혁 on 2023/01/27.
//

import UIKit
import AVFAudio


class NewPlayerVIewController : UIViewController {
    
    private lazy var playerUpperView = PlayerUpperView()
    private lazy var playerLowerView = PlayerLowerView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
        PlayerController.playerController.player.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        guard let timer = playerUpperView.timer else { return }
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


// 끝까지 재생되었다면 끝 시간에서 정지
extension NewPlayerVIewController : AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        PlayerController.playerController.pausePlayer()
        playerLowerView.setPlayButtonImage()
        
        PlayerController.playerController.changePlayerTime(changedTime: player.duration)
    }
}



// UI Design
extension NewPlayerVIewController {
    func setNavigationBar(title : String) {
        navigationItem.title = title
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(backToRootVC))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "slider.horizontal.3"), style: .plain, target: self, action: #selector(tapPlayerSetting))
        
        navigationItem.leftBarButtonItem?.tintColor = .label
        navigationItem.rightBarButtonItem?.tintColor = .label
    }
    
    private func setLayout() {
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
