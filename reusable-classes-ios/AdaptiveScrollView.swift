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

    let KeyboardDidShowSelector  = Selector("keyboardDidShow:")
    let KeyboardWillHideSelector = Selector("keyboardWillHide:")

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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: KeyboardDidShowSelector, name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: KeyboardWillHideSelector, name: UIKeyboardDidShowNotification, object: nil)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func keyboardDidShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue else { return }
        let keyboardSize = keyboardFrame.CGRectValue().size
        let contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0)
        adjustContentInsets(contentInsets)
    }

    func keyboardWillHide(notification: NSNotification) {
        adjustContentInsets(UIEdgeInsetsZero)
    }

    private func adjustContentInsets(contentInsets: UIEdgeInsets) {
        contentInset = contentInsets
        scrollIndicatorInsets = contentInsets
    }
}