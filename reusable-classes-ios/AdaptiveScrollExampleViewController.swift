//
//  AdaptiveScrollExampleViewController.swift
//  reusable-classes-ios
//
//  Created by Aashish Dhawan on 05/01/16.
//  Copyright © 2016 Aashish Dhawan. All rights reserved.
//

import Foundation
import UIKit

class AdaptiveScrollExampleViewController: UIViewController {
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scrollView = AdaptiveScrollView(frame: view.bounds)
        scrollView.contentSize = view.bounds.size
        
        let sampleTextField = UITextField(frame: CGRectMake(20, 300, 200, 40))
        sampleTextField.placeholder = "Enter text here"
        sampleTextField.font = UIFont.systemFontOfSize(15)
        sampleTextField.borderStyle = UITextBorderStyle.RoundedRect
        sampleTextField.autocorrectionType = UITextAutocorrectionType.No
        sampleTextField.keyboardType = UIKeyboardType.Default
        sampleTextField.returnKeyType = UIReturnKeyType.Done
        sampleTextField.clearButtonMode = UITextFieldViewMode.WhileEditing;
        sampleTextField.contentVerticalAlignment = UIControlContentVerticalAlignment.Center
        
        scrollView.addSubview(sampleTextField)
        view.addSubview(scrollView)
    }
}