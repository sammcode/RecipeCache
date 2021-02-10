//
//  Constants.swift
//  RecipeTimer
//
//  Created by Sam McGarry on 4/15/20.
//  Copyright © 2020 Sam McGarry. All rights reserved.
//

import Foundation
import UIKit

//Images used for testing purposes
struct images {
    static let chickensoup = UIImage(named: "chickensoup")!
    static let lasagna = UIImage(named: "lasagna")!
    static let salmon = UIImage(named: "salmon")!
    static let spaghetti = UIImage(named: "spaghetti")!
    static let add = UIImage(named: "add")!
    static let emptyState = UIImage(named: "EmptyState")!
    static let selectImage = UIImage(named: "SelectImage")!
}

//Reusable cell identifiers
struct Cells {
    static let recipeCell = "RecipeCell"
    static let ingredientCell = "IngredientCell"
    static let prepStepCell = "PrepStepCell"
    static let cookingStepCell = "CookingStepCell"
    static let titleCell = "TitleCell"
    static let imageCell = "ImageCell"
    static let buttonCell = "ButtonCell"
}

struct ErrorMessages {
    static let noContent = "Looks like your recipe doesn't have any content. In order to use the Walkthrough feature your recipe needs atleast one Ingredient, Prep Step, or Cooking Step. You can add these by pressing the edit button."
    static let noRecipes = "No recipes?\nAdd one by tapping the plus button."
}

//Represents the width and height of the current device screen
enum ScreenSize {
    static let width        = UIScreen.main.bounds.size.width
    static let height       = UIScreen.main.bounds.size.height
    static let maxLength    = max(ScreenSize.width, ScreenSize.height)
    static let minLength    = min(ScreenSize.width, ScreenSize.height)
}

//Depicts whether or not a device is of a certain type
enum DeviceType {
    static let idiom                    = UIDevice.current.userInterfaceIdiom
    static let nativeScale              = UIScreen.main.nativeScale
    static let scale                    = UIScreen.main.scale
    
    static let isiPhoneSE               = idiom == .phone && ScreenSize.maxLength == 568.0
    static let isiPhone8Standard        = idiom == .phone && ScreenSize.maxLength == 667.0 && nativeScale == scale
    static let isiPhone8Zoomed          = idiom == .phone && ScreenSize.maxLength == 667.0 && nativeScale > scale
    static let isiPhone8PlusStandard    = idiom == .phone && ScreenSize.maxLength == 736.0
    static let isiPhone8PlusZoomed      = idiom == .phone && ScreenSize.maxLength == 736.0 && nativeScale < scale
    static let isiPhoneX                = idiom == .phone && ScreenSize.maxLength == 812.0
    static let isiPhoneXsMaxAndXr       = idiom == .phone && ScreenSize.maxLength == 896.0
    static let isiPad                   = idiom == .pad && ScreenSize.maxLength == 1024.0
    static let isiPad7thGen             = idiom == .pad && ScreenSize.maxLength == 1080.0
    static let isiPad11inch             = idiom == .pad && ScreenSize.maxLength == 1194.0
    static let isiPadPro                = idiom == .pad && ScreenSize.maxLength == 1366.0
    static let isiPadAir                = idiom == .pad && ScreenSize.maxLength == 1112.0
    static func isiPhoneXAspectRation() -> Bool {
        return isiPhoneX || isiPhoneXsMaxAndXr
    }
}
