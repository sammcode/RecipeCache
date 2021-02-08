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
    
    //Declares a private constant for the standard UserDefaults
    static private let defaults = UserDefaults.standard
    
    //Enum for the string keys of different settings
    enum Keys {
        static let timerStartsAutomatically = "timerStartsAutomatically"
        static let timerDelay = "timerDelay"
        static let organizeRecipes = "organizeRecipes"
    }
    
    //Saves the current settings to UserDefaults
    static func save() {
        defaults.set(Settings.timerStartsAutomatically, forKey: Keys.timerStartsAutomatically)
        defaults.set(Settings.timerDelay, forKey: Keys.timerDelay)
        defaults.set(Settings.organizeRecipes, forKey: Keys.organizeRecipes)
    }
    
    //Retrieves the settings saved to UserDefaults, and appropiately sets the data to the Settings class
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
