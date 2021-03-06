//
//  IngredientCell.swift
//  RecipeTimer
//
//  Created by Sam McGarry on 4/20/20.
//  Copyright © 2020 Sam McGarry. All rights reserved.
//

import UIKit

class IngredientCell: UITableViewCell {
    
    var ingredient : Ingredient? {
        didSet {
            ingredientNameLabel.text = ingredient?.title
            ingredientQntyLabel.text = ingredient?.qnty
            ingredientNotesLabel.text = ingredient?.notes
        }
    }
    
    private let ingredientNameLabel : UILabel = {
        let lbl = UILabel()
        lbl.textColor = .white
        lbl.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        lbl.textAlignment = .left
        lbl.layer.cornerRadius = 5
        return lbl
    }()
    
    let ingredientQntyLabel : UILabel = {
        let lbl = UILabel()
        lbl.textColor = .white
        lbl.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        lbl.textAlignment = .left
        lbl.numberOfLines = 0
        return lbl
    }()
    
    private let ingredientNotesLabel : UILabel = {
        let lbl = UILabel()
        lbl.textColor = .white
        lbl.font = UIFont.systemFont(ofSize: 16, weight: .light)
        lbl.textAlignment = .left
        lbl.numberOfLines = 0
        return lbl
    }()
    
    private let container: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .white
        v.layer.cornerRadius = 24
        v.layer.shadowOpacity = 0.5
        v.layer.shadowRadius = 8
        v.layer.shadowColor = UIColor.label.cgColor
        v.layer.shadowOffset = CGSize(width: 3, height: 3)
        v.clipsToBounds = true
        v.layer.masksToBounds = false
        return v
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubviews(ingredientNameLabel, ingredientQntyLabel, ingredientNotesLabel)
        
        self.bounds = CGRect(x: self.bounds.origin.x, y: self.bounds.origin.y, width: 300, height: self.bounds.size.height)
        self.contentView.layer.cornerRadius = 10
        self.contentView.layer.borderWidth = 5
        self.contentView.layer.borderColor = UIColor(named: "ingredient")?.cgColor
        self.contentView.backgroundColor = UIColor(named: "ingredient")
        selectionStyle = .none
        
        setUpElementConstraints()
        
    }
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if (highlighted) {
            self.layer.borderColor = UIColor(named: "ingredient2")?.cgColor
        } else {
            self.layer.borderColor = UIColor(named: "ingredient")?.cgColor
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
        let width: CGFloat!
        if DeviceType.isiPhoneSE {
            width = frame.size.width * 0.9
        }else {
            width = frame.size.width
        }
        ingredientNameLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: frame.size.width, height: 0, enableInsets: false)
        ingredientQntyLabel.anchor(top: ingredientNameLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: frame.size.width, height: 0, enableInsets: false)
        ingredientNotesLabel.anchor(top: ingredientQntyLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: width, height: 0, enableInsets: false)
    }
}
