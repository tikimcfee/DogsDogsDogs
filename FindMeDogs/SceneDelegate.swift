//
//  SceneDelegate.swift
//  FindMeDogs
//
//  Created by Ivan Lugo on 2/8/20.
//  Copyright © 2020 Ivan Lugo. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

	var window: UIWindow?
	
	private func configureInitialViewController() -> UIViewController {
		// VC retains -> presenter retains -> data manager
		let initial = MainDogListViewController()
		let dataManager = DogDataManager()
		_ = MainDogListPresenter(dataManager: dataManager, view: initial)
		return initial
	}

	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		guard let windowScene = (scene as? UIWindowScene) else { return }
		
		let window = UIWindow(windowScene: windowScene)
		window.rootViewController = configureInitialViewController()
		window.makeKeyAndVisible()
		
		// Sorry - no dark mode support! ;)
		if #available(iOS 13, *) {
			window.overrideUserInterfaceStyle = .light
		}
		
		self.window = window		
	}

	func sceneDidDisconnect(_ scene: UIScene) { }

	func sceneDidBecomeActive(_ scene: UIScene) { }

	func sceneWillResignActive(_ scene: UIScene) { }

	func sceneWillEnterForeground(_ scene: UIScene) { }

	func sceneDidEnterBackground(_ scene: UIScene) { }


}

