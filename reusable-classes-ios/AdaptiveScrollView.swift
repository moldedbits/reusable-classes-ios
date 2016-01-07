//
//  AdaptiveScrollView.swift
//  reusable-classes-ios
//
//  Created by Aashish Dhawan on 03/01/16.
//  Copyright © 2016 Aashish Dhawan. All rights reserved.
//

import Foundation
import UIKit

class AdaptiveScrollView: UIScrollView {

    let KeyboardWillShowSelector  = Selector("keyboardWillShow:")
    let KeyboardWillHideSelector = Selector("keyboardWillHide:")
    let ContentOffset: CGFloat = 10.0

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        registerForKeyboardNotifications()
    }

    private func registerForKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: KeyboardWillShowSelector, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: KeyboardWillHideSelector, name: UIKeyboardWillHideNotification, object: nil)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {        
            let contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height + ContentOffset, 0.0)
            adjustContentInsets(contentInsets)
        }
    }

    func keyboardWillHide(notification: NSNotification) {
        adjustContentInsets(UIEdgeInsetsZero)
    }

    private func adjustContentInsets(contentInsets: UIEdgeInsets) {
        contentInset = contentInsets
        scrollIndicatorInsets = contentInsets
    }
}