//
//  RecipeCell.swift
//  RecipeTimer
//
//  Created by Sam McGarry on 4/15/20.
//  Copyright © 2020 Sam McGarry. All rights reserved.
//

import UIKit

class RecipeCell: UITableViewCell {
    
    var recipe: Recipe? {
        didSet{
            recipeDateLabel.text = "Edited: " + recipe!.dateCreated
            recipeNameLabel.text = recipe?.title
            numIngredientsLabel.text = "\(recipe?.ingredients.count ?? 0) Ingredients"
            numPrepStepsLabel.text = "\(recipe?.prepSteps.count ?? 0) Prep Steps"
            numCookingStepsLabel.text = "\(recipe?.cookingSteps.count ?? 0) Cooking Steps"
            recipeImageView.image = recipe?.image
        }
    }
    
    private let recipeDateLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .label
        lbl.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        lbl.textAlignment = .left
        lbl.numberOfLines = 0
        return lbl
    }()
    
    private let recipeNameLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .label
        lbl.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        lbl.textAlignment = .left
        lbl.numberOfLines = 0
        return lbl
    }()
    
    private let recipeImageView: ScaledHeightImageView = {
        let img = ScaledHeightImageView()
        img.contentMode = .scaleAspectFill
        img.layer.cornerRadius = 10
        img.layer.masksToBounds = true
        return img
    }()
    
    private let numIngredientsLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = UIColor(named: "ingredient2")
        lbl.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        lbl.textAlignment = .left
        lbl.numberOfLines = 0
        return lbl
    }()
    
    private let numPrepStepsLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = UIColor(named: "prepstep2")
        lbl.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        lbl.textAlignment = .left
        lbl.numberOfLines = 0
        return lbl
    }()
    
    private let numCookingStepsLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = UIColor(named: "cookingstep2")
        lbl.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        lbl.textAlignment = .left
        lbl.numberOfLines = 0
        return lbl
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        
        self.addSubviews(recipeNameLabel, recipeDateLabel, recipeImageView, numIngredientsLabel, numPrepStepsLabel, numCookingStepsLabel)
        
        self.bounds = CGRect(x: self.bounds.origin.x, y: self.bounds.origin.y, width: ScreenSize.width * 0.7, height: self.bounds.size.height * 0.9)
        layer.cornerRadius = 10
        layer.borderWidth = 5
        layer.masksToBounds = true
        selectionStyle = .none
        
        setUpElementConstraints()
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if (highlighted) {
            self.layer.borderColor = UIColor.clear.cgColor
        } else {
            self.layer.borderColor = UIColor.clear.cgColor
        }
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
    
    private func setUpElementConstraints() {
        recipeImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: frame.size.width * 1.175, height: frame.size.height * 5.3, enableInsets: false)
        recipeNameLabel.anchor(top: recipeImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: frame.size.width * 1.175, height: 0, enableInsets: false)
        recipeDateLabel.anchor(top: recipeNameLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 5, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: frame.size.width, height: 0, enableInsets: false)
        numIngredientsLabel.anchor(top: recipeDateLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 5, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: frame.size.width, height: 0, enableInsets: false)
        numPrepStepsLabel.anchor(top: numIngredientsLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 5, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: frame.size.width, height: 0, enableInsets: false)
        numCookingStepsLabel.anchor(top: numPrepStepsLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 5, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: frame.size.width, height: 0, enableInsets: false)
    }
}
