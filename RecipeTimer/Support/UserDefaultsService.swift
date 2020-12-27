//
//  UserDefaultsService.swift
//  RecipeTimer
//
//  Created by Sam McGarry on 8/6/20.
//  Copyright © 2020 Sam McGarry. All rights reserved.
//

import Foundation

enum UserDefaultsServiceActionType {
    case updateBool
}

enum UserDefaultsService {
    static private let defaults = UserDefaults.standard
    
    enum Keys {
        static let timerStartsAutomatically = "timerStartsAutomatically"
        static let timerDelay = "timerDelay"
        static let organizeRecipes = "organizeRecipes"
    }
    
    static func save() {
        defaults.set(Settings.timerStartsAutomatically, forKey: Keys.timerStartsAutomatically)
        defaults.set(Settings.timerDelay, forKey: Keys.timerDelay)
        defaults.set(Settings.organizeRecipes, forKey: Keys.organizeRecipes)
    }
    
    static func retrieve() {
        guard let timerStartsAutomaticallyData = defaults.object(forKey: Keys.timerStartsAutomatically) as? Bool else {
            return
        }
        Settings.timerStartsAutomatically = timerStartsAutomaticallyData
        
        
        guard let timerDelayData = defaults.object(forKey: Keys.timerDelay) as? Int else {
            return
        }
        Settings.timerDelay = timerDelayData
        
        guard let organizeRecipesData = defaults.object(forKey: Keys.organizeRecipes) as? String else {
            return
        }
        Settings.organizeRecipes = organizeRecipesData
        print(Settings.organizeRecipes)
    }
}
