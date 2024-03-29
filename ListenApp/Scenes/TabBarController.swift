//
//  PlayListViewController.swift
//  ListenTo
//
//  Created by 곽지혁 on 2023/01/09.
//

import UIKit
import SnapKit

class TabBarController: UITabBarController {
    
    private lazy var PlayListVC : UIViewController = {
        let viewController = UINavigationController(rootViewController: PlayListViewController())
        let tabBarItem = UITabBarItem(
            title: "홈",
            image: UIImage(systemName: "house"),
            tag: 0
        )
        viewController.tabBarItem = tabBarItem
        return viewController
    }()
    
    private lazy var SettingVC : UIViewController = {
        let viewController = UINavigationController(rootViewController: SettingViewController())
        let tabBarItem = UITabBarItem(
            title: "정보",
            image: UIImage(systemName: "info.circle"),
            tag: 1
        )
        viewController.tabBarItem = tabBarItem
        return viewController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        tabBar.isTranslucent = false
        
        viewControllers = [PlayListVC, SettingVC]
    }

}

