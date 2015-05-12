//
//  Helper.swift
//  Rembee
//
//  Created by Sebastian Sandtorv on 29/04/15.
//  Copyright (c) 2015 Protodesign. All rights reserved.
//

import Foundation
import UIKit

// Colors
var lightGreenColor: UIColor = UIColor(red: 0, green: 1, blue: 0, alpha: 0.03)
var darkGreenColor:  UIColor = UIColor(red: 0, green: 1, blue: 0, alpha: 0.06)
var lightBlackColor: UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.03)
var darkBlackColor:  UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.06)

// Error printing - handle error msg later?
func printError(input: AnyObject){
    println(input)
}

// Delay Helper
func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}

// Funny function to create color gradient from blue header to white at last cell. Dynamic
func colorForIndex(index: Int, length: Int) -> UIColor {
    let val = (CGFloat(index) / CGFloat(length-1)) * 1
    return UIColor(red: 0, green: 0.5, blue: 1, alpha: 1-val)
}

// Color for normal cells
func cellBGColorNormal(index: Int) -> UIColor{
    if(index % 2 == 0){
        return darkBlackColor
    } else{
        return lightBlackColor
    }
}

// Color for completed cells
func cellBGColorComplete(index: Int) -> UIColor{
    if(index % 2 == 0){
        return darkGreenColor
    } else{
        return lightGreenColor
    }
}