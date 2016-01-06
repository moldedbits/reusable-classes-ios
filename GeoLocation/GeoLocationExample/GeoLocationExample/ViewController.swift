//
//  ViewController.swift
//  GeoLocationExample
//
//  Created by vishal singh on 04/01/16.
//  Copyright © 2016 moldedbits. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in 0...3 {
            let button = UIButton(type: .Custom)
            button.layer.borderColor = UIColor.blackColor().CGColor
            button.layer.cornerRadius = 10
            button.backgroundColor = UIColor(white: 0.5, alpha: 1)
            button.frame = CGRectMake(0, 60.0 + CGFloat(80 * i), 200.0, 60.0)
            button.center = CGPoint(x: view.center.x, y: button.center.y)
            button.addTarget(self, action: Selector("buttonTapped:"), forControlEvents: .TouchUpInside)
            button.tag = i
            view.addSubview(button)

            switch i {
                case 0:
                    button.setTitle( "Current Location Demo", forState: .Normal)
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
            case 0:
                let newScreen = CurrentLocationScreen()
                navigationController?.pushViewController(newScreen, animated: true)
            
        default: return
        }
    }
}
