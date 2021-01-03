//
//  AppDelegate.swift
//  RecipeTimer
//
//  Created by Sam McGarry on 4/14/20.
//  Copyright © 2020 Sam McGarry. All rights reserved.
//

import UIKit
import CoreData
//import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //FirebaseApp.configure()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func application(
      _ app: UIApplication,
      open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]
      ) -> Bool {
      // 1
      guard url.pathExtension == "rcp" else { return false }

      // 2
        PersistenceService.importData(from: url)

      // 3
      guard
        let navigationController = window?.rootViewController as? UINavigationController,
        let recipesTableViewController = navigationController.viewControllers
          .first as? HomeVC
        else { return true }

      // 4
      recipesTableViewController.tableView.reloadData()
      return true
    }
    
}
