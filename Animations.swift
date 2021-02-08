//
//  Animations.swift
//  RecipeTimer
//
//  Created by Sam McGarry on 5/28/20.
//  Copyright © 2020 Sam McGarry. All rights reserved.
//

import Foundation
import UIKit

//Creates a pulsating animation on any UIView.
//In the context of this app I use it for my custom buttons
func pulsate(view: UIView) {
    let pulse = CASpringAnimation(keyPath: "transform.scale")
    pulse.duration = 0.4
    pulse.fromValue = 0.75
    pulse.toValue = 1.0
    //pulse.autoreverses = true
    pulse.repeatCount = 0
    pulse.initialVelocity = 0.5
    pulse.damping = 1.0
    
    view.layer.add(pulse, forKey: nil)
}
