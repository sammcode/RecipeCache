//
//  TimePickerTextField.swift
//  RecipeTimer
//
//  Created by Sam McGarry on 4/19/20.
//  Copyright © 2020 Sam McGarry. All rights reserved.
//

import UIKit

class TimePickerTextField: UITextField {

    let insets: UIEdgeInsets
    var hour = 0
    var minute = 0
    var second = 0
    var displayHour = "00"; var displayMinute = "00"; var displaySecond = "00"
    
    init(insets: UIEdgeInsets){
        self.insets = insets
        super.init(frame: .zero)
        
        layer.cornerRadius = 8
        layer.borderWidth = 1.5
        layer.borderColor = UIColor.lightGray.cgColor
        backgroundColor = UIColor.systemBackground
        placeholder = "Name"
        textColor = UIColor.label
        
        let timePicker = UIPickerView()
        timePicker.delegate = self
        inputView = timePicker
        
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
    
    func createTimePicker() {
        let timePicker = UIPickerView()
        timePicker.delegate = self
        
        inputView = timePicker
    }
}

extension TimePickerTextField: UIPickerViewDelegate, UIPickerViewDataSource{

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 60
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(format: "%02d", row)
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0{
            hour = row
            if row > 9{
                displayHour = "\(hour)"
            }else{
                displayHour = "0\(hour)"
            }
        }else if component == 1{
            minute = row
            if row > 9{
                displayMinute = "\(minute)"
            }else{
                displayMinute = "0\(minute)"
            }
        }
        else{
            second = row
            if row > 9{
                displaySecond = "\(second)"
            }else{
                displaySecond = "0\(second)"
            }
        }
        text = displayHour + ":" + displayMinute + ":" + displaySecond
    }
}
