//
//  TitleCell.swift
//  RecipeTimer
//
//  Created by Sam McGarry on 4/23/20.
//  Copyright © 2020 Sam McGarry. All rights reserved.
//

import UIKit

class TitleCell: UITableViewCell {

    var title : String? {
        didSet {
            nameLabel.text = title
        }
    }
    var fontSize : CGFloat? {
        didSet {
            nameLabel.font = UIFont.systemFont(ofSize: fontSize!, weight: .semibold)
        }
    }
    
    private let nameLabel : UILabel = {
        let lbl = UILabel()
        lbl.textColor = .label
        lbl.font = UIFont.systemFont(ofSize: 30, weight: .semibold)
        lbl.textAlignment = .left
        lbl.numberOfLines = 0
        return lbl
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.addSubview(nameLabel)
        
        self.bounds = CGRect(x: self.bounds.origin.x, y: self.bounds.origin.y, width: 300, height: self.bounds.size.height)
        layer.cornerRadius = 10
        layer.masksToBounds = true
        layer.shadowRadius = 5
        layer.shadowColor = UIColor.label.cgColor
        backgroundColor = UIColor.clear
        selectionStyle = .none
        
        setUpElementConstraints()
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if (highlighted) {
            self.layer.borderColor = UIColor(named: "cookingstep2")?.cgColor
        } else {
            self.layer.borderColor = UIColor(named: "cookingstep")?.cgColor
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
        nameLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: frame.size.width, height: 0, enableInsets: false)
    }
}
