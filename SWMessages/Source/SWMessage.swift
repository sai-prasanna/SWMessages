//
//  SWMessages.swift
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

private let kSWMessageDisplayTime = 1.5
private let kSWMessageExtraDisplayTimePerPixel = 0.04
private let kSWMessageAnimationDuration = 0.3


open class SWMessage :NSObject {
    
    open static let sharedInstance = SWMessage()
    
    /** Set a custom offset for the notification view */
    open var offsetHeightForMessage :CGFloat = 0.0
    
    open var customizeMessageView  :((SWMessageView) -> Void)?
    
    /** Use this property to set a default view controller to display the messages in */
    open var defaultViewController :UIViewController  {
        get {
            return _defaultViewController ?? UIApplication.shared.keyWindow!.rootViewController!
        }
        set {
            _defaultViewController = newValue
        }
    }
    
    /** Indicates whether a notification is currently active. */
    open fileprivate(set) var notificationActive = false
    
    fileprivate var messages = [SWMessageView]()
    fileprivate weak var _defaultViewController :UIViewController?
    
    override init() {
        super.init()
    }
    
    /**
     
     Shows a notification message
     
     - Parameter message: The title of the notification view
     - Parameter type: The notification type (Message, Warning, Error, Success)
     */
    open func showNotificationWithTitle(_ title: String, type: SWMessageNotificationType) {
        showNotificationWithTitle(title, subtitle: nil, type: type)
    }
    
    /**
     
     Shows a notification message
     
     - Parameter title: The title of the notification view
     - Parameter subtitle: The text that is displayed underneath the title
     - Parameter type: The notification type (Message, Warning, Error, Success)
     */
    open func showNotificationWithTitle(_ title: String, subtitle: String?, type: SWMessageNotificationType) {
        showNotificationInViewController(defaultViewController, title: title, subtitle: subtitle, type: type, duration: .automatic)
    }
    
    /**
     
     Shows a notification message in a specific view controller
     
     - Parameter viewController The view controller to show the notification in.
     You can use +setDefaultViewController: to set the the default one instead
     - Parameter title: The title of the notification view
     - Parameter subtitle: The text that is displayed underneath the title
     - Parameter type: The notification type (Message, Warning, Error, Success)
     */
    open func showNotificationInViewController(_ viewController: UIViewController, title: String, subtitle: String, type: SWMessageNotificationType) {
        showNotificationInViewController(viewController, title: title, subtitle: subtitle, image: nil, type: type, duration: .automatic, callback: nil, buttonTitle: nil, buttonCallback: nil, atPosition: .top, canBeDismissedByUser: true)
    }
    
    /**
     
     Shows a notification message in a specific view controller with a specific duration
     
     - Parameter viewController The view controller to show the notification in.
     You can use +setDefaultViewController: to set the the default one instead
     - Parameter title: The title of the notification view
     - Parameter subtitle: The text that is displayed underneath the title
     - Parameter type: The notification type (Message, Warning, Error, Success)
     - Parameter duration: The duration of the notification being displayed  (Automatic, Endless, Custom)
     */
    open func showNotificationInViewController(_ viewController: UIViewController, title: String, subtitle: String?, type: SWMessageNotificationType, duration: SWMessageDuration) {
        showNotificationInViewController(viewController, title: title, subtitle: subtitle, image: nil, type: type, duration: duration, callback: nil, buttonTitle: nil, buttonCallback: nil, atPosition: .top, canBeDismissedByUser: true)
    }
    
    /** Shows a notification message in a specific view controller with a specific duration
     - Parameter viewController The view controller to show the notification in.
     You can use +setDefaultViewController: to set the the default one instead
     - Parameter title: The title of the notification view
     - Parameter subtitle: The text that is displayed underneath the title
     - Parameter type: The notification type (Message, Warning, Error, Success)
     - Parameter duration: The duration of the notification being displayed  (Automatic, Endless, Custom)
     - Parameter dismissingEnabled: Should the message be dismissed when the user taps/swipes it
     */
    open func showNotificationInViewController(_ viewController: UIViewController, title: String, subtitle: String, type: SWMessageNotificationType, duration: SWMessageDuration, canBeDismissedByUser dismissingEnabled: Bool) {
        showNotificationInViewController(viewController, title: title, subtitle: subtitle, image: nil, type: type, duration: duration, callback: nil, buttonTitle: nil, buttonCallback: nil, atPosition: .top, canBeDismissedByUser: dismissingEnabled)
    }
    
    /**
     
     Shows a notification message in a specific view controller
     
     - Parameter viewController: The view controller to show the notification in.
     - Parameter title: The title of the notification view
     - Parameter subtitle: The message that is displayed underneath the title (optional)
     - Parameter image: A custom icon image (optional)
     - Parameter type: The notification type (Message, Warning, Error, Success)
     - Parameter duration: The duration of the notification being displayed  (Automatic, Endless, Custom)
     - Parameter callback: The block that should be executed, when the user tapped on the message
     - Parameter buttonTitle: The title for button (optional)
     - Parameter buttonCallback: The block that should be executed, when the user tapped on the button
     - Parameter messagePosition: The position of the message on the screen
     - Parameter dismissingEnabled: Should the message be dismissed when the user taps/swipes it
     - Parameter overrideStyle: Override default styles using this style object, it has highest priority.
     */
    open func showNotificationInViewController(_ viewController: UIViewController, title: String, subtitle: String?, image: UIImage?, type: SWMessageNotificationType, duration: SWMessageDuration, callback: (() -> Void)?, buttonTitle: String?, buttonCallback: (() -> Void)?, atPosition messagePosition: SWMessageNotificationPosition, canBeDismissedByUser dismissingEnabled: Bool, overrideStyle: SWMessageView.Style?=nil) {
        // Create the TSMessageView
        let messageView  = SWMessageView(
            title: title,
            subtitle: subtitle,
            image: image,
            type: type,
            duration: duration,
            viewController: viewController,
            callback: callback,
            buttonTitle: buttonTitle,
            buttonCallback: buttonCallback,
            position: messagePosition,
            dismissingEnabled: dismissingEnabled,
            style: overrideStyle
        )
        messageView.fadeOut = { [weak messageView, weak self] in
            if let messageView = messageView {
                self?.fadeOutNotification(messageView)
            }
        }
        
        messages.append(messageView)
        
        
        if !notificationActive {
            fadeInCurrentNotification()
        }
    }
    
    /**
     
     Fades out the currently displayed notification. If another notification is in the queue,
     the next one will be displayed automatically
     
     - Returns: true if the currently displayed notification was successfully dismissed. NO if no notification
     was currently displayed.
     */
    open func dismissActiveNotification() -> Bool {
        return dismissActiveNotificationWithCompletion(nil)
    }
    
    
    open func dismissActiveNotificationWithCompletion(_ completion: (() -> Void)?) -> Bool {
        if messages.count == 0 {
            return false
        }
        DispatchQueue.main.async(execute: {() -> Void in
            if self.messages.count == 0 {
                return
            }
            let currentMessage = self.messages[0]
            if currentMessage.messageIsFullyDisplayed {
                self.fadeOutNotification(currentMessage, animationFinishedBlock: completion)
            } else {
                
                Timer.scheduledTimer(timeInterval: kSWMessageAnimationDuration + 0.1, target: BlockOperation(block: {
                    self.fadeOutNotification(currentMessage, animationFinishedBlock: completion)
                }), selector: #selector(Operation.main), userInfo: nil, repeats: false)
                
            }
        })
        return true
    }
    
    /**  The currently queued array of TSMessageView */
    open var  queuedMessages :[SWMessageView] {
        return messages
    }
    
    fileprivate func fadeInCurrentNotification() {
        if messages.count == 0 {
            return
        }
        notificationActive = true
        let currentView = messages[0]
        var verticalOffset: CGFloat = 0.0
        let addStatusBarHeightToVerticalOffset = {() -> Void in
            if currentView.messagePosition == .navBarOverlay {
                return
            }
            let statusBarSize: CGSize = UIApplication.shared.statusBarFrame.size
            verticalOffset += min(statusBarSize.width, statusBarSize.height)
        }
        if (currentView.viewController is  UINavigationController) || (currentView.viewController.parent is UINavigationController) {
            let currentNavigationController = currentView.viewController as? UINavigationController ?? currentView.viewController.parent as! UINavigationController
            var isViewIsUnderStatusBar: Bool = (currentNavigationController.childViewControllers[0].edgesForExtendedLayout == .all)
            if !isViewIsUnderStatusBar && currentNavigationController.parent == nil {
                isViewIsUnderStatusBar = !SWMessage.isNavigationBarInNavigationControllerHidden(currentNavigationController)
                // strange but true
            }
            if !SWMessage.isNavigationBarInNavigationControllerHidden(currentNavigationController) && currentView.messagePosition != .navBarOverlay {
                currentNavigationController.view!.insertSubview(currentView, belowSubview: currentNavigationController.navigationBar)
                verticalOffset = currentNavigationController.navigationBar.bounds.size.height
                if isViewIsUnderStatusBar {
                    addStatusBarHeightToVerticalOffset()
                }
            }
            else {
                currentView.viewController.view!.addSubview(currentView)
                if isViewIsUnderStatusBar {
                    addStatusBarHeightToVerticalOffset()
                }
            }
        }
        else {
            currentView.viewController.view!.addSubview(currentView)
            addStatusBarHeightToVerticalOffset()
        }
        var toPoint: CGPoint
        if currentView.messagePosition != .bottom {
            toPoint = CGPoint(x: currentView.center.x, y: offsetHeightForMessage + verticalOffset + currentView.frame.height / 2.0)
        }
        else {
            var y: CGFloat = currentView.viewController.view.bounds.size.height - currentView.frame.height / 2.0
            if let toolbarHidden = currentView.viewController.navigationController?.isToolbarHidden , !toolbarHidden {
                y -= currentView.viewController.navigationController!.toolbar.bounds.height
            }
            toPoint = CGPoint(x: currentView.center.x, y: y)
        }
        
        customizeMessageView?(currentView)
        
        let animationBlock = {
            currentView.center = toPoint
        }
        let completionBlock = {(finished :Bool)  in
            currentView.messageIsFullyDisplayed = true
        }
        
        UIView.animate(withDuration: kSWMessageAnimationDuration + 0.1, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: [.beginFromCurrentState, .allowUserInteraction], animations: animationBlock, completion: completionBlock)
        
        
        var durationToPresent :TimeInterval?
        switch(currentView.duration) {
        case .automatic:
            durationToPresent = kSWMessageAnimationDuration + kSWMessageDisplayTime + TimeInterval(currentView.frame.size.height) * kSWMessageExtraDisplayTimePerPixel
        case .custom(let timeInterval):
            durationToPresent = timeInterval
        default:
            break
        }
        
        if let durationToPresent = durationToPresent {
            DispatchQueue.main.async(execute: {() -> Void in
                self.perform(#selector(SWMessage.fadeOutNotification(_:)), with: currentView, afterDelay: durationToPresent)
            })
        }
    }
    
    class func isNavigationBarInNavigationControllerHidden(_ navController: UINavigationController) -> Bool {
        if navController.isNavigationBarHidden {
            return true
        }
        else if navController.navigationBar.isHidden {
            return true
        }
        else {
            return false
        }
    }
    
    func fadeOutNotification(_ currentView: SWMessageView) {
        fadeOutNotification(currentView, animationFinishedBlock: nil)
    }
    
    func fadeOutNotification(_ currentView: SWMessageView, animationFinishedBlock animationFinished: (() -> Void)?) {
        currentView.messageIsFullyDisplayed = false
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(SWMessage.fadeOutNotification(_:)), object: currentView)
        var fadeOutToPoint: CGPoint
        if currentView.messagePosition != .bottom {
            fadeOutToPoint = CGPoint(x: currentView.center.x, y: -currentView.frame.height / 2.0)
        }
        else {
            fadeOutToPoint = CGPoint(x: currentView.center.x, y: currentView.viewController.view.bounds.size.height + currentView.frame.height / 2.0)
        }
        UIView.animate(withDuration: kSWMessageAnimationDuration, animations: {() -> Void in
            currentView.center = fadeOutToPoint
            }, completion: {(finished: Bool) -> Void in
                currentView.removeFromSuperview()
                if self.messages.count > 0 {
                    self.messages.remove(at: 0)
                }
                self.notificationActive = false
                if self.messages.count > 0 {
                    self.fadeInCurrentNotification()
                }
                if finished {
                    animationFinished?()
                }
        })
    }
}
