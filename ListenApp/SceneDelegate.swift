//
//  SceneDelegate.swift
//  ListenTo
//
//  Created by 곽지혁 on 2023/01/09.
//

import UIKit
import StoreKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        let rootViewController = TabBarController()
        
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()
        
//        SKStoreReviewController.requestReview(in: windowScene)
//        - Development 환경에서는 항상 뜨고,
//        - TestFlight 환경에서는 뜨지 않으며,
//        - 실제로 배포되었을 때는, 애플 정책을 따른다고 되어있다.

        // 테마 적용
        window?.overrideUserInterfaceStyle = AdminUserDefault.shared.getThema()
        return
    }


}

