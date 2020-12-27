//
//  ImageCell.swift
//  RecipeTimer
//
//  Created by Sam McGarry on 4/30/20.
//  Copyright © 2020 Sam McGarry. All rights reserved.
//

import UIKit

class ImageCell: UITableViewCell {

    var img : UIImage? {
        didSet {
            recipeImage.image = img
        }
    }
    
    private let recipeImage: ScaledHeightImageView = {
        let img = ScaledHeightImageView()
        img.contentMode = .scaleAspectFill
        img.layer.cornerRadius = 10
        img.layer.masksToBounds = true
        return img
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.addSubview(recipeImage)
        
        let width: CGFloat = getWidthBasedOnScreenSize()
        
        self.bounds = CGRect(x: self.bounds.origin.x, y: self.bounds.origin.y, width: width, height: self.bounds.size.height)
        
        layer.cornerRadius = 10
        selectionStyle = .none
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 2
        layer.shadowColor = UIColor.label.cgColor
        layer.shadowOffset = CGSize(width: 3, height: 3)
        clipsToBounds = true
        layer.masksToBounds = false
        
        setUpElementConstraints()
    }
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set (newFrame) {
            var frame = newFrame
            let newWidth = frame.width * 0.9 // get 80% width here
            let space = (frame.width - newWidth) / 2
            frame.size.width = newWidth
            frame.origin.x += space

            super.frame = frame

        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func getWidthBasedOnScreenSize() -> CGFloat {
        if DeviceType.isiPadPro {
            return ScreenSize.width * 0.5
        }else if DeviceType.isiPad11inch {
            return ScreenSize.width * 0.6
        }else if DeviceType.isiPadAir {
            return ScreenSize.width * 0.6
        }else if DeviceType.isiPad7thGen {
            return ScreenSize.width * 0.6
        }else if DeviceType.isiPad {
            return ScreenSize.width * 0.7
        }else {
            return ScreenSize.width * 0.7
        }
    }
    
    private func setUpElementConstraints() {
        recipeImage.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: frame.size.width * 1.175, height: frame.size.height * 5.3 , enableInsets: false)
    }
}
