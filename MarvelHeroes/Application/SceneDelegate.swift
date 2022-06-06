//
//  SceneDelegate.swift
//  MarvelHeroes
//
//  Created by Tarkhan Tahirov on 04.06.22.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        
        window.rootViewController = getRootNavController()
        
        window.backgroundColor = .secondarySystemBackground
        self.window = window
        window.makeKeyAndVisible()
    }
    
    private func getRootNavController() -> UINavigationController {
        let networkClient = MarvelNetworkClient.shared
        let viewModel = CharactersListViewModel(with: networkClient)
        let heroesVC = CharactersViewController(with: viewModel)
        
        let navController = UINavigationController(rootViewController: heroesVC)
        navController.navigationBar.isTranslucent = false
        
        return navController
    }

}

