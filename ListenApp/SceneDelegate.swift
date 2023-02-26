//
//  SceneDelegate.swift
//  ListenTo
//
//  Created by 곽지혁 on 2023/01/09.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        let rootViewController = TabBarController()
        
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()
        
        window?.overrideUserInterfaceStyle = AdminUserDefault.shared.getThema()
        return
    }


}

