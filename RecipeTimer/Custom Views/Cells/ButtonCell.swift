//
//  ButtonCell.swift
//  RecipeTimer
//
//  Created by Sam McGarry on 6/1/20.
//  Copyright © 2020 Sam McGarry. All rights reserved.
//

import UIKit

protocol ButtonCellDelegate {
    func didPressButton(cell: ButtonCell)
}

class ButtonCell: UITableViewCell {
    
    var buttonDelegate: ButtonCellDelegate?
    var title : String? {
        didSet {
            button.setTitle(title, for: .normal)
        }
    }
    
    private let button: StyleButton = {
        let button = StyleButton()
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        return button
    }()
    
    @objc func buttonPressed(_ sender: UIButton){
        buttonDelegate?.didPressButton(cell: self)
    }
    
    func addActionToButton(){
        button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.addSubview(button)
        addActionToButton()
        
        let width: CGFloat!
        let height: CGFloat!
        
        if DeviceType.isiPhoneSE {
            width = 200
            height = 20
        }else if DeviceType.isiPhone8Standard {
            width = 250
            height = self.bounds.size.height
        }else {
            width = 250
            height = self.bounds.size.height
        }
        
        self.bounds = CGRect(x: self.bounds.origin.x, y: self.bounds.origin.y, width: width, height: height)
        
        layer.masksToBounds = true
        layer.cornerRadius = 10
        layer.shadowRadius = 5
        selectionStyle = .none
        
        setUpElementConstraints()
    }
    
    convenience init(style: UITableViewCell.CellStyle, reuseIdentifier: String?, color: UIColor) {
        self.init()
        button.backgroundColor = color
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
        button.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: frame.size.width * 1.175, height: frame.size.height * 5.3 , enableInsets: false)
    }
}
