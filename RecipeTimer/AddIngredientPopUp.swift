//
//  AddIngredientPopUp.swift
//  RecipeTimer
//
//  Created by Sam McGarry on 4/15/20.
//  Copyright © 2020 Sam McGarry. All rights reserved.
//

import UIKit
import TinyConstraints

protocol AddIngredientDelegate {
    func buttonTapped()
}

class AddIngredientPopUp: UIView {
    
    var ingredientDelegate: AddIngredientDelegate?
    public var ingredient: Ingredient?
    fileprivate let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.text = "New Ingredient"
        label.textAlignment = .center
        return label
    }()
    
    fileprivate let addName: NameTextField = {
        let textfield = NameTextField(insets: UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 12))
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.placeholder = "Ingredient Name"
        textfield.height(40)
        return textfield
    }()
    
    fileprivate let addQuantity: NameTextField = {
        let textfield = NameTextField(insets: UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 12))
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.placeholder = "Quantity (Optional)"
        textfield.height(40)
        return textfield
    }()
    
    fileprivate let addNotes: NotesTextView = {
        let textview = NotesTextView()
        textview.translatesAutoresizingMaskIntoConstraints = false
        textview.height(115)
        return textview
    }()
    
    fileprivate let button: StyleButton = {
        let button = StyleButton()
        button.setTitle("Add Ingredient", for: .normal)
        if DeviceType.isiPhoneSE {
            button.heightAnchor.constraint(equalToConstant: 35).isActive = true
            button.layer.cornerRadius = 15
        }else {
            button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        }
        return button
    }()
    
    func addActionToButton(){
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    @objc func buttonTapped(){
        button.pulsate()
        var notes: String!
        var qnty: String!
        if addNotes.text != "" && addNotes.text != "Notes"  {
            notes = addNotes.text
        }
        if addQuantity.text != "" {
            qnty = addQuantity.text
        }
        ingredient = Ingredient(title: addName.text!, qnty: qnty, notes: notes)
        ingredientDelegate?.buttonTapped()
        animateOut()
    }
    
    fileprivate lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, addName, addQuantity, addNotes, button])
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
    
    @objc func handleKeyboardShow(notification: Notification) {}
    
    @objc func closeKeyboard(){
        self.endEditing(true)
    }
    
    override init(frame: CGRect){
        super.init(frame: frame)
            
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeKeyboard)))
        self.backgroundColor = UIColor.gray.withAlphaComponent(0.6)
        
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
        
        print("Max length is:")
        print(ScreenSize.maxLength)
        if DeviceType.isiPadPro {
            width = ScreenSize.width * 0.6
            height = ScreenSize.height * 0.3
            print("IPAD PRO")
        }else if DeviceType.isiPad11inch {
            width = ScreenSize.width * 0.6
            height = ScreenSize.height * 0.35
            print("IPAD 11 INCH")
        }else if DeviceType.isiPad7thGen {
            width = ScreenSize.width * 0.6
            height = ScreenSize.height * 0.4
        }else if DeviceType.isiPad {
            width = ScreenSize.width * 0.6
            height = ScreenSize.height * 0.4
            print("IPAD REG")
        }else if DeviceType.isiPadAir {
            print("IPAD AIR")
            width = ScreenSize.width * 0.6
            height = ScreenSize.height * 0.4
        }else if DeviceType.isiPhone8PlusStandard {
            width = ScreenSize.width * 0.9
            height = ScreenSize.height * 0.5
        }else if DeviceType.isiPhone8Standard || DeviceType.isiPhoneSE{
            width = ScreenSize.width * 0.9
            height = ScreenSize.height * 0.6
        }else {
            width = ScreenSize.width * 0.9
            height = ScreenSize.height * 0.45
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

