//
//  NotesTextView.swift
//  RecipeTimer
//
//  Created by Sam McGarry on 4/17/20.
//  Copyright © 2020 Sam McGarry. All rights reserved.
//

import UIKit

class NotesTextView: UITextView {

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        self.frame = CGRect(x: 0, y: 0, width: 200, height: 40)
        font = UIFont.systemFont(ofSize: 16)
        layer.cornerRadius = 8
        layer.borderWidth = 1.5
        layer.borderColor = UIColor.lightGray.cgColor
        delegate = self
        isScrollEnabled = false
        text = "Notes (Optional)"
        textColor = .lightGray
        textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 4, right: 8)
        backgroundColor = UIColor.systemBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
extension NotesTextView: UITextViewDelegate{
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // get the current text, or use an empty string if that failed
        let currentText = textView.text ?? ""

        // attempt to read the range they are trying to change, or exit if we can't
        guard let stringRange = Range(range, in: currentText) else { return false }

        // add their new text to the existing text
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)

        // make sure the result is under 16 characters
        return updatedText.count <= 145
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Notes (Optional)"
            textView.textColor = UIColor.lightGray
        }
    }
}

