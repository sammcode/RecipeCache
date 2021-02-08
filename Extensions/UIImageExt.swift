//
//  UIImageExt.swift
//  RecipeTimer
//
//  Created by Sam McGarry on 9/13/20.
//  Copyright © 2020 Sam McGarry. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    
    //Converts the UIImage to pngData. Used for testing purposes, comparing one image to another.
    var toData: Data? {
        return pngData()
    }
    
    //Ensures the UIImage has the correct orientation
    func updateImageOrientionUpSide() -> UIImage? {
        
        //If the imageOrientation is already set to up, the function returns the original UIImage
        if self.imageOrientation == .up {
            return self
        }
        
        //Beings a new image context, redraws the UIImage in a CGRect with the correct orientation, then returns that normalized UIImage
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        if let normalizedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()
            return normalizedImage
        }
        UIGraphicsEndImageContext()
        return nil
    }
}

