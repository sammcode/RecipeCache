//
//  RTEmptyStateView.swift
//  RecipeTimer
//
//  Created by Sam McGarry on 8/17/20.
//  Copyright © 2020 Sam McGarry. All rights reserved.
//

import UIKit

class RTEmptyStateView: UIView {

    let messageLabel = TitleLabel(textAlignment: .center, fontSize: 28)

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(message: String) {
        self.init(frame: .zero)
        messageLabel.text = message
    }
    
    private func configure(){
        addSubview(messageLabel)
        configureMessageLabel()
    }
    
    private func configureMessageLabel(){
        messageLabel.numberOfLines = 3
        messageLabel.textColor = .secondaryLabel
        
        let labelCenterYConstant: CGFloat = getCenterYConstantBasedOnScreenSize()
        
        NSLayoutConstraint.activate([
            messageLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: labelCenterYConstant),
            messageLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 40),
            messageLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -40),
            messageLabel.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    private func getCenterYConstantBasedOnScreenSize() -> CGFloat {
        if DeviceType.isiPhoneSE {
            return -20
        }else if DeviceType.isiPhone8Standard {
            return -40
        }else {
            return -150
        }
    }
}
