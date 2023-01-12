//
//  PlayerViewController.swift
//  ListenTo
//
//  Created by 곽지혁 on 2023/01/10.
//

import UIKit

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


private extension PlayerViewController {
    func createForderInDocument() {
        let fileManager = FileManager.default
        let documentURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let directoryURL = documentURL.appendingPathComponent("NewForder")
        
        do {
            try fileManager.createDirectory(at:directoryURL, withIntermediateDirectories: false)
        } catch let e as NSError {
            print(e.localizedDescription)
        }
    }
    
    func createFileInDocument() {
        let fileManager = FileManager.default
        let documentURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = documentURL.appendingPathComponent("FileName.txt")
        
        let text = "Hello World!"
        do {
            try text.write(to: fileName, atomically: false, encoding: .utf8)
        } catch let e as NSError {
            print(e.localizedDescription)
        }
    }
    
    
    func deleteFileInDocument() {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
//        let directoryURL = documentsURL.appendingPathComponent("NewDirectory")

        let fileURL = documentsURL.appendingPathComponent("FileName.txt")

        do {
            try fileManager.removeItem(at: fileURL)
        } catch let e {
            print(e.localizedDescription)
        }
        
    }
    
    func getFileInDocument() {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        // 3. 파일이 있는 Directory 설정
//        let directoryURL = documentsURL.appendingPathComponent("NewDirectory")
        let helloPath = documentsURL.appendingPathComponent("FileName.txt")
        
        do {
            let text = try String(contentsOf: helloPath, encoding: .utf8)
            print(text) // Hello world
        } catch let e {
            print(e.localizedDescription)
        }
    }
    
}


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
//
        
        pageViewController.view.snp.makeConstraints{
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(playerProgressView.snp.top).offset(-40)
            $0.top.equalTo(view.safeAreaLayoutGuide)
        }
        
    }
}
