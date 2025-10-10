//
//  SceneDelegate.swift
//  knights25
//
//  Created by Vadim on 18. 9. 2025..
//

import UIKit
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var coordinator: AppCoordinator!
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options: UIScene.ConnectionOptions) {
        guard let winScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: winScene)
        
        let gameService = Game()
        coordinator = AppCoordinator(window: window,
                                     gameService: gameService)
        
        self.window = window
        coordinator.start()
    }
}
