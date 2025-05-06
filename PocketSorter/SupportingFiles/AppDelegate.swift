//
//  AppDelegate.swift
//  PocketSorter
//
//  Created by Pavel Stupak on 13.03.2025.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		
		#if DEBUG
		UIApplication.shared.resetIfNeeded()
		#endif
		
		setupDefaultsIfNeeded()
		
		return true
	}

	// MARK: - Private

	private func setupDefaultsIfNeeded() {
		let defaults = UserDefaults.standard
		if defaults.object(forKey: "itemSortingType") == nil {
			defaults.set(ItemSortingType.dateAdded.rawValue, forKey: "itemSortingType")
		}
	}

	// MARK: - UISceneSession Lifecycle

	func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
		return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
	}
}
