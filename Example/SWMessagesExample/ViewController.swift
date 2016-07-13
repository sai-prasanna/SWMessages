//
//  ViewController.swift
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
import SWMessages

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        SWMessage.sharedInstance.defaultViewController = self
        edgesForExtendedLayout = .All
        navigationController?.navigationBar.translucent = true
        
    }
    
    @IBAction func didTapError(sender: AnyObject) {
        SWMessage.sharedInstance.showNotificationWithTitle("Something failed!",
            subtitle: "Cannot open the pod bay doors",
            type: .Error)
    }
    
    
    @IBAction func didTapWarning(sender: AnyObject) {
        SWMessage.sharedInstance.showNotificationWithTitle("Warning",
            subtitle: "Imminent singularity, please take shelter or wage Butlerian Jihad",
            type: .Warning)
    }
    
    @IBAction func didTapMessage(sender: AnyObject) {
        SWMessage.sharedInstance.showNotificationWithTitle("Info",
            subtitle: "Humans are required to submit for mandatory inspection!",
            type: .Message)
    }
    
    
    @IBAction func didTapSuccess(sender: AnyObject) {
        SWMessage.sharedInstance.showNotificationWithTitle("Success",
            subtitle: "1 Ring delivered to Mount Doom",
            type: .Success)
    }
    
    
    @IBAction func didTapWithButton(sender: AnyObject) {
        SWMessage.sharedInstance.showNotificationInViewController(self,
            title: "Update available",
            subtitle: "Please update our app. We added AI to replace you",
            image: nil,
            type: .Success,
            duration: .Automatic,
            callback: nil,
            buttonTitle: "Update",
            buttonCallback: { SWMessage.sharedInstance.showNotificationWithTitle("Thanks for updating", type: .Success)},
            atPosition: .Top,
            canBeDismissedByUser: true)
    }
    
    
    @IBAction func didTapToggleNav(sender: AnyObject) {
        navigationController?.setNavigationBarHidden(!navigationController!.navigationBarHidden, animated: true)
    }
    
    @IBAction func didTapNavAlpha(sender: AnyObject) {
        navigationController?.navigationBar.alpha = navigationController?.navigationBar.alpha == 1 ? 0.5 : 1
    }
    
    @IBAction func didTapToggleFullscreen(sender: AnyObject) {
        edgesForExtendedLayout = edgesForExtendedLayout == .None ? .All : .None
    }
    
    @IBAction func didTapDismiss(sender: AnyObject) {
        SWMessage.sharedInstance.dismissActiveNotification()
    }
    
    @IBAction func didTapInfinite(sender: AnyObject) {
        SWMessage.sharedInstance.showNotificationInViewController(self,
            title: "Endless",
            subtitle: "This message can not be dismissed and will not be hidden automatically. Tap the 'Dismiss' button to dismiss the currently shown message",
            image: nil,
            type: .Success,
            duration: .Endless,
            callback: nil,
            buttonTitle: nil,
            buttonCallback: nil,
            atPosition: .Top,
            canBeDismissedByUser: false)
    }

    @IBAction func didTapLongMessage(sender: AnyObject) {
        SWMessage.sharedInstance.showNotificationInViewController(self,
            title: "Long",
            subtitle: "This message is displayed 10 seconds instead of the calculated value",
            image: nil,
            type: .Success,
            duration: .Custom(10),
            callback: nil,
            buttonTitle: nil,
            buttonCallback: nil,
            atPosition: .Top,
            canBeDismissedByUser: false)
    }
    
    @IBAction func didTapText(sender: AnyObject) {
        SWMessage.sharedInstance.showNotificationInViewController(self,
            title: "Long Text",
            subtitle: "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus",
            image: nil,
            type: .Success,
            duration: .Automatic,
            callback: nil,
            buttonTitle: nil,
            buttonCallback: nil,
            atPosition: .Top,
            canBeDismissedByUser: false)
    }
    
    
    @IBAction func didTapCustomDesign(sender: AnyObject) {
        
    
        
    }
    
    @IBAction func didTapBottom(sender: AnyObject) {
        SWMessage.sharedInstance.showNotificationInViewController(self,
            title: "Bottom",
            subtitle: "showing message at bottom of screen",
            image: nil,
            type: .Success,
            duration: .Automatic,
            callback: nil,
            buttonTitle: nil,
            buttonCallback: nil,
            atPosition: .Bottom,
            canBeDismissedByUser: false)
    }

    
}

