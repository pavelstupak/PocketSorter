//
//  SceneDelegate.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 13.03.2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
	var window: UIWindow?

	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		guard let _ = (scene as? UIWindowScene) else { return }
	}

	// MARK: - Background Handling

	func sceneDidEnterBackground(_ scene: UIScene) {
		PersistentContainerProvider.shared.saveViewContextIfNeeded()
	}
}
