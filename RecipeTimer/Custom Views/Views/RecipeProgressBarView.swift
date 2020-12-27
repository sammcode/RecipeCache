//
//  RecipeProgressBarView.swift
//  RecipeTimer
//
//  Created by Sam McGarry on 7/21/20.
//  Copyright © 2020 Sam McGarry. All rights reserved.
//

import UIKit

enum StepType {
    case ingredient
    case prepstep
    case cookingstep
}

enum Direction {
    case backwards
    case forwards
}

class RecipeProgressBarView: UIView {

    let stackView: UIStackView = UIStackView()
    
    init(recipe: Recipe) {
        super.init(frame: .zero)
        configure(recipe: recipe)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(recipe: Recipe) {
        addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: self.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        for _ in recipe.ingredients {
            let imageView = UIImageView()
            imageView.image = UIImage(systemName: "rectangle")
            imageView.tintColor = UIColor(named: "ingredient")
            stackView.addArrangedSubview(imageView)
        }
        for _ in recipe.prepSteps {
            let imageView = UIImageView()
            imageView.image = UIImage(systemName: "rectangle")
            imageView.tintColor = UIColor(named: "prepstep")
            stackView.addArrangedSubview(imageView)
        }
        for _ in recipe.cookingSteps {
            let imageView = UIImageView()
            imageView.image = UIImage(systemName: "rectangle")
            imageView.tintColor = UIColor(named: "cookingstep")
            stackView.addArrangedSubview(imageView)
        }
    }
}
