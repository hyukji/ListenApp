//
//  PlayerViewController.swift
//  ListenTo
//
//  Created by 곽지혁 on 2023/01/10.
//

import UIKit
import AVFoundation

class PlayerViewController : UIViewController {
    
    private lazy var playerController = PlayerControlView()
    private lazy var playerProgressView = PlayerProgressView()
    private lazy var pageViewController = PageViewController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationBar()
        setLayout()
    }
    
    
    // go back rootViewVC(PlayListVC or SettingVC)
    @objc func backToRootVC() {
        tabBarController?.tabBar.isHidden = false
        tabBarController?.tabBar.isTranslucent = false
        
        navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func tapPlayerSetting() {
        print("tapPlayerSetting")
    }
    
    
}


// Player Method
extension PlayerViewController {
    
    private func getDocumentFileURL() -> URL {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        let title = audio?.title ?? ""
        let finalURL = documentsURL.appendingPathComponent("\(title).mp3")
        
        return finalURL
    }
    
    func configurePlayer() {
        let url = getDocumentFileURL()
        
        do {
            
            player = try AVAudioPlayer(contentsOf: url)
//            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
//            try AVAudioSession.sharedInstance().setActive(true)
//            player.prepareToPlay()
            player.play()
            
        } catch {
            print("Error: Audio File missing.")
        }
    }
    
}


// UI Design
private extension PlayerViewController {
    func setNavigationBar() {
        
        navigationItem.title = "노래 제목1"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(backToRootVC))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "slider.horizontal.3"), style: .plain, target: self, action: #selector(tapPlayerSetting))
        
        navigationItem.leftBarButtonItem?.tintColor = .label
        navigationItem.rightBarButtonItem?.tintColor = .label
    }
    
    func setLayout() {
        tabBarController?.tabBar.isHidden = true
        tabBarController?.tabBar.isTranslucent = true
        
        addChild(pageViewController)
        
        [playerController, playerProgressView, pageViewController.view].forEach{
            view.addSubview($0)
        }
        
        playerController.snp.makeConstraints{
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(50)
            $0.height.equalTo(130)
        }
        
        playerProgressView.snp.makeConstraints{
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(playerController.snp.top)
            $0.height.equalTo(45)
        }
        
        pageViewController.view.snp.makeConstraints{
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(playerProgressView.snp.top).offset(-40)
            $0.top.equalTo(view.safeAreaLayoutGuide)
        }
        
    }
}
