//
//  NameTextField.swift
//  RecipeTimer
//
//  Created by Sam McGarry on 4/17/20.
//  Copyright © 2020 Sam McGarry. All rights reserved.
//

import UIKit

class NameTextField: UITextField {
    
    let insets: UIEdgeInsets
    
    init(insets: UIEdgeInsets){
        self.insets = insets
        super.init(frame: .zero)
        
        layer.cornerRadius = 8
        layer.borderWidth = 1.5
        layer.borderColor = UIColor.lightGray.cgColor
        placeholder = "Name"
        textColor = UIColor.label
        delegate = self
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
}

extension NameTextField: UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // get the current text, or use an empty string if that failed
        let currentText = textField.text ?? ""

        // attempt to read the range they are trying to change, or exit if we can't
        guard let stringRange = Range(range, in: currentText) else { return false }

        // add their new text to the existing text
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)

        // make sure the result is under 30 characters
        return updatedText.count <= 30
    }
}
