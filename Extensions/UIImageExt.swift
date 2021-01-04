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
    
    var toData: Data? {
        return pngData()
    }
}

extension UIImage {
    var data: Data? {
        if let data = self.jpegData(compressionQuality: 1.0) {
            return data
        } else {
            return nil
        }
    }
}

extension UIImage {

    typealias EditSubviewClosure<T: UIView> = (_ parentSize: CGSize, _ viewToAdd: T)->()

    func with<T: UIView>(view: T, editSubviewClosure: EditSubviewClosure<T>) -> UIImage {

        if let copiedView = view.copyObject() as? T {
            UIGraphicsBeginImageContext(size)

            let basicSize = CGRect(origin: .zero, size: size)
            draw(in: basicSize)
            editSubviewClosure(size, copiedView)
            copiedView.draw(basicSize)

            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return newImage!
        }
        return self

    }
}

extension UIImage {

    func updateImageOrientionUpSide() -> UIImage? {
        if self.imageOrientation == .up {
            return self
        }

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
