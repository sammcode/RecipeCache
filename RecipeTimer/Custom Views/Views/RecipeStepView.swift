//
//  RecipeStepView.swift
//  RecipeTimer
//
//  Created by Sam McGarry on 7/18/20.
//  Copyright © 2020 Sam McGarry. All rights reserved.
//

import UIKit

class RecipeStepView: UIView {
    
    let titleLabel = TitleLabel()
    let subtitleLabel = BodyLabel()
    let bodyLabel = BodyLabel()
    
    let externalPadding: CGFloat = 15
    let internalPadding: CGFloat = 5
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(title: String, subtitle: String, body: String, color: UIColor){
        self.init(frame: .zero)
        titleLabel.text = title
        subtitleLabel.text = title
        bodyLabel.text = title
        backgroundColor = color
    }
    
    func configure() {
        addSubviews(titleLabel, subtitleLabel, bodyLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: externalPadding),
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: externalPadding),
            titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: externalPadding),
            titleLabel.heightAnchor.constraint(equalToConstant: 50),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: internalPadding),
            subtitleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: externalPadding),
            subtitleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: externalPadding),
            subtitleLabel.heightAnchor.constraint(equalToConstant: 40),
            
            bodyLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: internalPadding),
            bodyLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: externalPadding),
            bodyLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: externalPadding),
            bodyLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
}
