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
        edgesForExtendedLayout = .all
        navigationController?.navigationBar.isTranslucent = true
        
    }
    
    @IBAction func didTapError(_ sender: AnyObject) {
        SWMessage.sharedInstance.showNotificationWithTitle("Something failed!",
            subtitle: "Cannot open the pod bay doors",
            type: .error)
    }
    
    
    @IBAction func didTapWarning(_ sender: AnyObject) {
        SWMessage.sharedInstance.showNotificationWithTitle("Warning",
            subtitle: "Imminent singularity, please take shelter or wage Butlerian Jihad",
            type: .warning)
    }
    
    @IBAction func didTapMessage(_ sender: AnyObject) {
        SWMessage.sharedInstance.showNotificationWithTitle("Info",
            subtitle: "Humans are required to submit for mandatory inspection!",
            type: .message)
    }
    
    
    @IBAction func didTapSuccess(_ sender: AnyObject) {
        SWMessage.sharedInstance.showNotificationWithTitle("Success",
            subtitle: "1 Ring delivered to Mount Doom",
            type: .success)
    }
    
    
    @IBAction func didTapWithButton(_ sender: AnyObject) {
        SWMessage.sharedInstance.showNotificationInViewController(self,
            title: "Update available",
            subtitle: "Please update our app. We added AI to replace you",
            image: nil,
            type: .success,
            duration: .automatic,
            callback: nil,
            buttonTitle: "Update",
            buttonCallback: { SWMessage.sharedInstance.showNotificationWithTitle("Thanks for updating", type: .success)},
            atPosition: .top,
            canBeDismissedByUser: true)
    }
    
    
    @IBAction func didTapToggleNav(_ sender: AnyObject) {
        navigationController?.setNavigationBarHidden(!navigationController!.isNavigationBarHidden, animated: true)
    }
    
    @IBAction func didTapNavAlpha(_ sender: AnyObject) {
        navigationController?.navigationBar.alpha = navigationController?.navigationBar.alpha == 1 ? 0.5 : 1
    }
    
    @IBAction func didTapToggleFullscreen(_ sender: AnyObject) {
        edgesForExtendedLayout = edgesForExtendedLayout == UIRectEdge() ? .all : UIRectEdge()
    }
    
    @IBAction func didTapDismiss(_ sender: AnyObject) {
        let _ = SWMessage.sharedInstance.dismissActiveNotification()
    }
    
    @IBAction func didTapInfinite(_ sender: AnyObject) {
        SWMessage.sharedInstance.showNotificationInViewController(self,
            title: "Endless",
            subtitle: "This message can not be dismissed and will not be hidden automatically. Tap the 'Dismiss' button to dismiss the currently shown message",
            image: nil,
            type: .success,
            duration: .endless,
            callback: nil,
            buttonTitle: nil,
            buttonCallback: nil,
            atPosition: .top,
            canBeDismissedByUser: false)
    }

    @IBAction func didTapLongMessage(_ sender: AnyObject) {
        SWMessage.sharedInstance.showNotificationInViewController(self,
            title: "Long",
            subtitle: "This message is displayed 10 seconds instead of the calculated value",
            image: nil,
            type: .success,
            duration: .custom(10),
            callback: nil,
            buttonTitle: nil,
            buttonCallback: nil,
            atPosition: .top,
            canBeDismissedByUser: false)
    }
    
    @IBAction func didTapText(_ sender: AnyObject) {
        SWMessage.sharedInstance.showNotificationInViewController(self,
            title: "Long Text",
            subtitle: "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus",
            image: nil,
            type: .success,
            duration: .automatic,
            callback: nil,
            buttonTitle: nil,
            buttonCallback: nil,
            atPosition: .top,
            canBeDismissedByUser: false)
    }
    
    
    @IBAction func didTapCustomDesign(_ sender: AnyObject) {
        
    
        
    }
    
    @IBAction func didTapBottom(_ sender: AnyObject) {
        SWMessage.sharedInstance.showNotificationInViewController(self,
            title: "Bottom",
            subtitle: "showing message at bottom of screen",
            image: nil,
            type: .success,
            duration: .automatic,
            callback: nil,
            buttonTitle: nil,
            buttonCallback: nil,
            atPosition: .bottom,
            canBeDismissedByUser: false)
    }

    
}

