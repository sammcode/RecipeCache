//
//  AlertPopUp.swift
//  RecipeTimer
//
//  Created by Sam McGarry on 1/2/21.
//  Copyright © 2021 Sam McGarry. All rights reserved.
//

import UIKit

class AlertPopUp: UIView {

    var editTitleDelegate: EditTitleDelegate?
    var title: String?
    fileprivate let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.text = "No Content"
        label.textAlignment = .center
        return label
    }()
    
    fileprivate let messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.text = "Looks like your recipe doesn't have any content. In order to use the Walkthrough feature your recipe needs atleast one Ingredient, Prep Step, or Cooking Step. You can add these by pressing the edit button."
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    fileprivate let button: StyleButton = {
        let button = StyleButton()
        button.setTitle("Ok", for: .normal)
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        return button
    }()
    fileprivate lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, messageLabel, button])
        addActionToButton()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 10
        stack.distribution = .fillProportionally
        return stack
    }()
    
    fileprivate let container: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.systemBackground
        v.layer.cornerRadius = 24
        return v
    }()
    
    fileprivate let background: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.clear
        return v
    }()
    
    @objc fileprivate func animateOut(){
        UIView.animate(withDuration: 0.5, delay: 0.6, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
             self.container.transform = CGAffineTransform(translationX: 0, y: -self.frame.height)
             self.alpha = 0
        }) { (complete) in
            if complete{
                self.removeFromSuperview()
                print("removed from superview")
            }
        }
    }
    
    @objc fileprivate func animateIn(){
        self.container.transform = CGAffineTransform(translationX: 0, y: -self.frame.height)
        self.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
            self.container.transform = .identity
            self.alpha = 1
        })
    }
    
    func addActionToButton(){
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    @objc func buttonTapped(){
        button.pulsate()
        animateOut()
    }
    
    override init(frame: CGRect){
        super.init(frame: frame)
        
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(animateOut)))
        self.backgroundColor = UIColor.gray.withAlphaComponent(0.6)
        self.frame = UIScreen.main.bounds
        
        if DeviceType.isiPadPro {
            self.frame = UIScreen.main.bounds.offsetBy(dx: -160, dy: -150)
        }else if DeviceType.isiPad11inch {
            self.frame = UIScreen.main.bounds.offsetBy(dx: -70, dy: -110)
        }else if DeviceType.isiPadAir {
            self.frame = UIScreen.main.bounds.offsetBy(dx: -60, dy: -100)
        }else if DeviceType.isiPad7thGen {
            self.frame = UIScreen.main.bounds.offsetBy(dx: -60, dy: -100)
        }else if DeviceType.isiPad {
            self.frame = UIScreen.main.bounds.offsetBy(dx: -30, dy: -10)
        }else{
            self.frame = UIScreen.main.bounds
        }
        
        let width: CGFloat!
        let height: CGFloat!
        
        if DeviceType.isiPadPro {
            width = ScreenSize.width * 0.6
            height = ScreenSize.height * 0.2475
        }else if DeviceType.isiPad11inch {
            width = ScreenSize.width * 0.6
            height = ScreenSize.height * 0.2475
        }else if DeviceType.isiPadAir {
            width = ScreenSize.width * 0.6
            height = ScreenSize.height * 0.33
        }else if DeviceType.isiPad7thGen {
            width = ScreenSize.width * 0.6
            height = ScreenSize.height * 0.33
        }else if DeviceType.isiPad {
            width = ScreenSize.width * 0.6
            height = ScreenSize.height * 0.33
        }else if DeviceType.isiPhone8PlusStandard {
            width = ScreenSize.width * 0.9
            height = ScreenSize.height * 0.4125
        }else if DeviceType.isiPhone8Standard || DeviceType.isiPhoneSE{
            width = ScreenSize.width * 0.9
            height = ScreenSize.height * 0.49
        }else {
            width = ScreenSize.width * 0.9
            height = ScreenSize.height * 0.33
        }
        
        self.addSubview(background)
        background.pin(to: self)
        background.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(animateOut)))
        
        self.addSubview(container)
        container.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        container.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        container.widthAnchor.constraint(equalToConstant: width).isActive = true
        container.heightAnchor.constraint(equalToConstant: height).isActive = true
        
        container.addSubview(stack)
        
        stack.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 0.8).isActive = true
        stack.heightAnchor.constraint(equalTo: container.heightAnchor, multiplier: 0.9).isActive = true
        stack.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
        stack.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
        
        animateIn()
        self.bindToKeyboard()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
