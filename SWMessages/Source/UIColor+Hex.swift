//
//  UIColor+Hex.swift
//
//  Copyright (c) 2016-present Sai Prasanna R
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit

extension UIColor {
    
    convenience init(hexString: String) {
        self.init(hexString: hexString, alpha: 1.0)
    }
    
    convenience init(hexString: String, alpha: Float) {
        var hex = hexString
        
        if hex.hasPrefix("#") {
            hex = hex.substringFromIndex(hex.startIndex.advancedBy(1))
        }
        
        if (hex.rangeOfString("(^[0-9A-Fa-f]{6}$)|(^[0-9A-Fa-f]{3}$)", options: .RegularExpressionSearch) != nil) {
            
            if hex.characters.count == 3 {
                let redHex   = hex.substringToIndex(hex.startIndex.advancedBy(1))
                let greenHex = hex.substringWithRange(hex.startIndex.advancedBy(1) ..< hex.startIndex.advancedBy(2))
                let blueHex  = hex.substringFromIndex(hex.startIndex.advancedBy(2))
                
                hex = redHex + redHex + greenHex + greenHex + blueHex + blueHex
            }
            
            let redHex = hex.substringToIndex(hex.startIndex.advancedBy(2))
            let greenHex = hex.substringWithRange(hex.startIndex.advancedBy(2) ..< hex.startIndex.advancedBy(4))
            let blueHex = hex.substringWithRange(hex.startIndex.advancedBy(4) ..< hex.startIndex.advancedBy(6))
            
            var redInt:   CUnsignedInt = 0
            var greenInt: CUnsignedInt = 0
            var blueInt:  CUnsignedInt = 0
            
            NSScanner(string: redHex).scanHexInt(&redInt)
            NSScanner(string: greenHex).scanHexInt(&greenInt)
            NSScanner(string: blueHex).scanHexInt(&blueInt)
            
            self.init(red: CGFloat(redInt) / 255.0, green: CGFloat(greenInt) / 255.0, blue: CGFloat(blueInt) / 255.0, alpha: CGFloat(alpha))
        }
        else {
            self.init()
        }
    }
    
    convenience init(hex: Int) {
        self.init(hex: hex, alpha: 1.0)
    }
    
    convenience init(hex: Int, alpha: Float) {
        let hexString = NSString(format: "%2X", hex)
        self.init(hexString: hexString as String , alpha: alpha)
    }
}