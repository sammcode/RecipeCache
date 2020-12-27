//
//  UIImageViewExt.swift
//  RecipeTimer
//
//  Created by Sam McGarry on 9/13/20.
//  Copyright © 2020 Sam McGarry. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {

    enum ImageAddingMode {
        case changeOriginalImage
        case addSubview
        case addCopiedSubview
    }

    func drawOnCurrentImage<T: UIView>(view: T, mode: ImageAddingMode, editSubviewClosure: @escaping UIImage.EditSubviewClosure<T>) {

        guard let image = image else {
            return
        }

        let addSubView: (T) -> () = { view in
            editSubviewClosure(self.frame.size, view)
            self.addSubview(view)
        }

        switch mode {
            case .changeOriginalImage:
                self.image = image.with(view: view, editSubviewClosure: editSubviewClosure)

            case .addSubview:
                addSubView(view)

            case .addCopiedSubview:
                if let copiedView = view.copyObject() as? T {
                    addSubView(copiedView)
                }
        }
    }
}
