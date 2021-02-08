//
//  Settings.swift
//  RecipeTimer
//
//  Created by Sam McGarry on 8/7/20.
//  Copyright © 2020 Sam McGarry. All rights reserved.
//

import Foundation

//Class that stores the current settings values.
//The benefit of this is not having to access UserDefaults unless a change has been made to the settings.
//Also streamlines implemenation of the preferences into the app.
class Settings {
    //Boolean for whether or not a timer starts automatically on a Cooking Step.
    static var timerStartsAutomatically: Bool = false
    
    //Int that represents the amount of seconds the timer delay is set to.
    static var timerDelay: Int = 0
    
    //String that represents how the recipes are organized. By default it is by most recently created.
    static var organizeRecipes: String = "mostRecent"
}
