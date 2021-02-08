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
        return true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
    
    //The code below is a work in progress. It contributes to a feature that will allow users to open recipes sent to them in the RecipeCache app.
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
