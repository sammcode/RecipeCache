//
//  PlayPauseIndicatorView.swift
//  RecipeTimer
//
//  Created by Sam McGarry on 8/22/20.
//  Copyright © 2020 Sam McGarry. All rights reserved.
//

import UIKit

class PlayPauseIndicatorView: UIView {

    private var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(image: UIImage) {
        self.init(frame: .zero)
        imageView.image = image
        imageView.tintColor = UIColor.white
    }
    
    func configure(){
        setUpImageViewConstraints()
        backgroundColor = UIColor.black.withAlphaComponent(0.5)
        isOpaque = false
    }
    
    func setUpImageViewConstraints(){
        addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 140),
            imageView.heightAnchor.constraint(equalToConstant: 90)
        ])
    }
}
