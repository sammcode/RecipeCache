//
//  MultiplierTextField.swift
//  RecipeTimer
//
//  Created by Sam McGarry on 9/16/20.
//  Copyright © 2020 Sam McGarry. All rights reserved.
//

import UIKit

class MultiplierTextField: UITextField {

    let insets: UIEdgeInsets
    let multiplierOptions: [Double] = [1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0, 5.5, 6.0, 6.5, 7.0, 7.5, 8.0, 8.5, 9.0, 9.5, 10.0, 10.5, 11.0, 11.5, 12.0, 12.5, 13.0, 13.5, 14.0, 14.5, 15.0, 15.5, 16.0, 16.5, 17.0, 17.5, 18.0, 18.5, 19.0, 19.5, 20.0]
    var number = 0.0
    var displayNumber = "0.0"
    
    init(insets: UIEdgeInsets){
        self.insets = insets
        super.init(frame: .zero)
        
        backgroundColor = UIColor.systemBackground
        layer.cornerRadius = 8
        layer.borderWidth = 1.5
        layer.borderColor = UIColor.lightGray.cgColor
        placeholder = "Name"
        textColor = UIColor.label
        
        let multiplierPicker = UIPickerView()
        multiplierPicker.delegate = self
        inputView = multiplierPicker
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissKeyboard))
        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        inputAccessoryView = toolBar
    }
    
    @objc func dismissKeyboard(){
        endEditing(true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: insets)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: insets)
    }
    
    func createMultiplierPicker() {
        let multiplierPicker = UIPickerView()
        multiplierPicker.delegate = self
        
        inputView = multiplierPicker
    }

}

extension MultiplierTextField: UIPickerViewDelegate, UIPickerViewDataSource{

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 38
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(multiplierOptions[row])
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        number = multiplierOptions[row]
        
        text = String(number)
    }
}
