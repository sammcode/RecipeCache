//
//  RCAlertContainerView.swift
//  RecipeTimer
//
//  Created by Sam McGarry on 10/6/20.
//  Copyright © 2020 Sam McGarry. All rights reserved.
//

import UIKit

class RCAlertContainerView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure(){
        backgroundColor = .systemBackground
        layer.cornerRadius = 16
        layer.borderWidth = 2
        layer.borderColor = UIColor.white.cgColor
        translatesAutoresizingMaskIntoConstraints = false
    }
}
