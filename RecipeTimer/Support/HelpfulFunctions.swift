//
//  HelpfulFunctions.swift
//  RecipeTimer
//
//  Created by Sam McGarry on 9/16/20.
//  Copyright © 2020 Sam McGarry. All rights reserved.
//

import Foundation
import UIKit

class HelpfulFunctions {
    
    private init() {}
    
    static func applyMultiplier(quantity: String, multiplier: String) -> String {
        let actualNumber = extractDigits(quantity: quantity)
        if actualNumber[0] == ""{
            return quantity + " x " + multiplier
        }else {
            let mult = Double(multiplier)
            let num = Double(actualNumber[0])
            let result = mult! * num!
            return String(result) + String(actualNumber[1])
        }
    }
    
    static func extractDigits(quantity: String) -> [String] {
        var resultChars: [Character] = []
        var remainingChars: [Character] = []
        for char in quantity {
            print(char)
            if char == "1" || char == "2" || char == "3" || char == "4" || char == "5" || char == "6" || char == "7" || char == "8" || char == "9"{
                resultChars.append(char)
            }else if !resultChars.isEmpty && (char == "/" || char == ".") {
                return ["", ""]
            }else{
                remainingChars.append(char)
            }
        }
        print(String(resultChars))
        return [String(resultChars), String(remainingChars)]
    }
    
    static func colorWithGradient(frame: CGRect, colors: [UIColor]) -> UIColor {
        
        // create the background layer that will hold the gradient
        let backgroundGradientLayer = CAGradientLayer()
        backgroundGradientLayer.frame = frame
         
        // we create an array of CG colors from out UIColor array
        let cgColors = colors.map({$0.cgColor})
        
        backgroundGradientLayer.colors = cgColors
        
        UIGraphicsBeginImageContext(backgroundGradientLayer.bounds.size)
        backgroundGradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let backgroundColorImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return UIColor(patternImage: backgroundColorImage)
    }
}
