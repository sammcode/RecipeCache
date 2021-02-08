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
    
    //Function that takes a quantity, and a multiplier as parameters, converts them to Doubles, multiplies them, and then returns a String containing the result.
    static func applyMultiplier(quantity: String, multiplier: String) -> String {
        let actualNumber = extractDigits(quantity: quantity)
        if actualNumber[0] == ""{
            return quantity + " x " + multiplier
        }else {
            let mult = Double(multiplier)
            let num = Double(actualNumber[0])
            let result = mult! * num!
            if result - result.rounded(.towardZero) == 0 {
                let result1 = Int(result)
                return String(result1) + " " + String(actualNumber[1])
            }else if actualNumber[1] == "" {
                return String(result).trimmingCharacters(in: .whitespaces)
            }
            return String(result) + " " + String(actualNumber[1])
        }
    }
    
    //Function that takes a string as a parameter, extracts any numbers from it, and returns an array of strings (one being the extracted number, and the other being the remaining characters)
    static func extractDigits(quantity: String) -> [String] {
        var resultChars: [Character] = []
        var remainingChars: [Character] = []
        for char in quantity {
            print(char)
            if char == "1" || char == "2" || char == "3" || char == "4" || char == "5" || char == "6" || char == "7" || char == "8" || char == "9" || char == "0" || char == "."{
                resultChars.append(char)
            }else if !resultChars.isEmpty && (char == "/") {
                return ["", ""]
            }else{
                remainingChars.append(char)
            }
        }
        print(String(resultChars))
        return [String(resultChars).trimmingCharacters(in: .whitespaces), String(remainingChars).trimmingCharacters(in: .whitespaces)]
    }
    
    //Takes a CGRect and array of UIColors as parameters, and returns a UIColor that is gradient of the inputted array
    static func colorWithGradient(frame: CGRect, colors: [UIColor]) -> UIColor {
        
        //Creates the background layer that will hold the gradient
        let backgroundGradientLayer = CAGradientLayer()
        backgroundGradientLayer.frame = frame
         
        //Creates an array of CG colors from the inputted UIColor array
        let cgColors = colors.map({$0.cgColor})
        
        backgroundGradientLayer.colors = cgColors
        
        UIGraphicsBeginImageContext(backgroundGradientLayer.bounds.size)
        backgroundGradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let backgroundColorImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return UIColor(patternImage: backgroundColorImage)
    }
}
