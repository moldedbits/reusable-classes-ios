//
//  ViewController.swift
//  GeoLocationExample
//
//  Created by vishal singh on 04/01/16.
//  Copyright © 2016 moldedbits. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private var screenHeight, screenWidth: CGFloat!
    let currentLocationScreen = CurrentLocationScreen()
    let forwardGeocodingScreen = ForwardGeocodingScreen()
    let reverseGeoCodingScreen = ReverseGeocodingScreen()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GeoLocation.shared.requestAlwaysAuthorization()

        screenHeight = view.frame.height
        screenWidth = view.frame.width
        
        for i in 0...3 {
            let button = UIButton(type: .Custom)
            button.layer.borderColor = UIColor.blackColor().CGColor
            button.layer.cornerRadius = 10
            button.backgroundColor = UIColor(white: 0.5, alpha: 1)
            button.frame = CGRectMake(0, 70 + (screenHeight / 5 + 20) * CGFloat(i) , 200.0, screenHeight / 5)
            button.center = CGPoint(x: view.center.x, y: button.center.y)
            button.addTarget(self, action: Selector("buttonTapped:"), forControlEvents: .TouchUpInside)
            button.tag = i
            view.addSubview(button)

            switch i {
                case 0:
                    button.setTitle("Current Location Demo", forState: .Normal)
                case 1:
                    button.setTitle("Forward Geocode Demo", forState: .Normal)
                case 2:
                    button.setTitle("Reverse Geocode Demo", forState: .Normal)
                default:
                    button.setTitle("Under Progress", forState: .Normal)
            }
        }
    }
    
    func buttonTapped(sender: AnyObject) {
        switch sender.tag {
            case 0: presentViewController(currentLocationScreen, animated: true, completion: nil)
            case 1: presentViewController(forwardGeocodingScreen, animated: true, completion: nil)
            case 2: presentViewController(reverseGeoCodingScreen, animated: true, completion: nil)

            default: return
        }
    }
}

extension UIViewController {
    
    func displayError(error: NSError) {
        let alert = UIAlertController(title: "Error!", message: error.localizedDescription, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func dismissScreen() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func dismissKeyboard(sender: UIGestureRecognizer) {
        view.endEditing(true)
    }
}
