//
//  AddMultiplierPopUp.swift
//  RecipeTimer
//
//  Created by Sam McGarry on 9/16/20.
//  Copyright © 2020 Sam McGarry. All rights reserved.
//

import UIKit

protocol AddMultiplierPopUpDelegate: class {
    func buttonTapped4()
    func resetButtonTapped()
}

class AddMultiplierPopUp: UIView {

    //Declare variables to be used within the scopoe of the class
    var addMultiplierPopUpDelegate: AddMultiplierPopUpDelegate!
    var multiplier: String = "1.0"
    
    //Declare all UI elements to be added to the view, set their properties
    fileprivate let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.text = "Add Multiplier"
        label.textAlignment = .center
        return label
    }()
    
    fileprivate let addMultiplier: MultiplierTextField = {
        let textfield = MultiplierTextField(insets: UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 12))
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.placeholder = "0.0"
        textfield.height(40)
        return textfield
    }()
    
    fileprivate let button: StyleButton = {
        let button = StyleButton()
        button.setTitle("Set Multiplier", for: .normal)
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        return button
    }()
    
    fileprivate let resetButton: StyleButton = {
        let button = StyleButton()
        button.setTitle("Reset", for: .normal)
        button.backgroundColor = UIColor(named: "background")
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        return button
    }()
    
    fileprivate lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, addMultiplier, resetButton, button])
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
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
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
    
    //Adds buttonTapped function to the button
    func addActionToButton(){
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
    }
    
    //Triggers button animation, and performs actions to properly update the recipe with a new multiplier
    @objc func buttonTapped(){
        //Animates button
        button.pulsate()
        
        //Declares variables to be used in creating new Ingredient
        multiplier = addMultiplier.text ?? ""
        
        //Call the delegate function that notifies the ViewController presenting the popup to perform some actions
        addMultiplierPopUpDelegate?.buttonTapped4()
        
        //Dismiss the popup and animate it off screen
        animateOut()
    }
    
    @objc func resetButtonTapped(){
        //Animates button
        button.pulsate()
        
        //Call the delegate function for the reset button that notifies the ViewController presenting the popup to perform some actions
        addMultiplierPopUpDelegate?.resetButtonTapped()
        
        //Dismiss the popup and animate it off screen
        animateOut()
    }
    
    override init(frame: CGRect){
        super.init(frame: frame)
        
        //Adds gesture recognizer to the popup that calls the close keyboard function when the view is tapped
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(animateOut)))
        
        //Sets the background color
        self.backgroundColor = UIColor.gray.withAlphaComponent(0.6)
        
        //Adjusts the frame of the popup if the device being used is an iPad
        self.frame = UIScreen.main.bounds
        
        //Declare constants that will be used to set the width and height of the popup
        let width: CGFloat!
        let height: CGFloat!
        
        //Set width and height constants based on device type
        if DeviceType.isiPadPro {
            width = ScreenSize.width * 0.6
            height = ScreenSize.height * 0.2
        }else if DeviceType.isiPad11inch {
            width = ScreenSize.width * 0.6
            height = ScreenSize.height * 0.25
        }else if DeviceType.isiPadAir {
            width = ScreenSize.width * 0.6
            height = ScreenSize.height * 0.25
        }else if DeviceType.isiPad7thGen {
            width = ScreenSize.width * 0.6
            height = ScreenSize.height * 0.25
        }else if DeviceType.isiPad {
            width = ScreenSize.width * 0.6
            height = ScreenSize.height * 0.25
        }else if DeviceType.isiPhone8PlusStandard {
            width = ScreenSize.width * 0.9
            height = ScreenSize.height * 0.35
        }else if DeviceType.isiPhone8Standard || DeviceType.isiPhoneSE{
            width = ScreenSize.width * 0.9
            height = ScreenSize.height * 0.45
        }else {
            width = ScreenSize.width * 0.9
            height = ScreenSize.height * 0.3
        }
        
        //Adds background as a subview. Adds a gesture recognizer that calls the animateOut function if background view is tapped
        self.addSubview(background)
        background.pin(to: self)
        background.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(animateOut)))
        
        //Adds container as a subview, constrains it to the center of the popup view
        self.addSubview(container)
        container.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        container.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        container.widthAnchor.constraint(equalToConstant: width).isActive = true
        container.heightAnchor.constraint(equalToConstant: height).isActive = true
        
        //Adds container as a subview, constrains it to the center of the popup view
        container.addSubview(stack)
        stack.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 0.8).isActive = true
        stack.heightAnchor.constraint(equalTo: container.heightAnchor, multiplier: 0.9).isActive = true
        stack.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
        stack.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
        
        //After all the elements are configured, the popup view is animated on screen
        animateIn()
        
        //The popup view is binded to the keyboard, so it's position adjusts when the keyboard comes on screen
        self.bindToKeyboard()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
