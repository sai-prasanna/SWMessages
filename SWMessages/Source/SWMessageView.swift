//
//  SWMessageView.swift
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

private let messageViewMinimumPadding :CGFloat = 15.0

public class SWMessageView :UIView , UIGestureRecognizerDelegate {
    
    public struct Style {
        let image: UIImage?
        let backgroundColor: UIColor
        let textColor: UIColor
        let textShadowColor: UIColor?
        let titleFont: UIFont?
        let contentFont: UIFont?
        let shadowOffset: CGSize?
        
        public init (image: UIImage? = nil, backgroundColor: UIColor, textColor: UIColor, textShadowColor: UIColor? = nil, titleFont: UIFont? = nil, contentFont: UIFont? = nil, shadowOffset: CGSize? = nil){
            self.image = image
            self.backgroundColor = backgroundColor
            self.textColor = textColor
            self.textShadowColor = textShadowColor
            self.titleFont = titleFont
            self.contentFont = contentFont
            self.shadowOffset = shadowOffset
        }
    }
    
    /** The displayed title of this message */
    public let title :String
    
    /** The displayed subtitle of this message */
    public let subtitle :String?
    
    /** The view controller this message is displayed in */
    public let viewController :UIViewController
    
    public let buttonTitle :String?
    
    /** The duration of the displayed message. */
    public var duration :SWMessageDuration = .Automatic
    
    /** The position of the message (top or bottom or as overlay) */
    public var messagePosition :SWMessageNotificationPosition
    public var notificationType :SWMessageNotificationType
    
    /** Is the message currenlty fully displayed? Is set as soon as the message is really fully visible */
    public var messageIsFullyDisplayed = false
    
    
    /** Function to customize style globally, initialized to default style. Priority will be This  customOptions in init > styleForMessageType */
    public static var styleForMessageType :(SWMessageNotificationType) -> SWMessageView.Style = defaultStyleForMessageType
    
    var fadeOut :(() -> Void)?
    
    private let titleLabel = UILabel()
    private lazy var contentLabel = UILabel()
    private var iconImageView :UIImageView?
    private var button :UIButton?
    private let backgroundView = UIView()
    private var textSpaceLeft :CGFloat = 0
    private var textSpaceRight :CGFloat = 0
    private var callback :(()-> Void)?
    private var buttonCallback :(()-> Void)?
    private let padding :CGFloat
    
    /**
     
     Inits the notification view. Do not call this from outside this library.
     
     - Parameter title:  The title of the notification view
     - Parameter subtitle:  The subtitle of the notification view (optional)
     - Parameter image:  A custom icon image (optional), it will override any image specfied in SWMessageView.styleForMessageType, and style
     - Parameter notificationType:  The type (color) of the notification view
     - Parameter duration:  The duration this notification should be displayed (optional)
     - Parameter viewController:  The view controller this message should be displayed in
     - Parameter callback:  The block that should be executed, when the user tapped on the message
     - Parameter buttonTitle:  The title for button (optional)
     - Parameter buttonCallback:  The block that should be executed, when the user tapped on the button
     - Parameter position:  The position of the message on the screen
     - Parameter dismissingEnabled:  Should this message be dismissed when the user taps/swipes it?
     - Parameter style:  Override default/global style
     */
    init(title :String,
         subtitle :String?,
         image :UIImage?,
         type :SWMessageNotificationType,
         duration :SWMessageDuration?,
         viewController :UIViewController,
         callback :(()-> Void)?,
         buttonTitle :String?,
         buttonCallback :(()-> Void)?,
         position :SWMessageNotificationPosition,
         dismissingEnabled :Bool,
         style: SWMessageView.Style? = nil
        )
    {
        self.title = title
        self.subtitle = subtitle
        self.buttonTitle = buttonTitle
        self.duration = duration ?? .Automatic
        self.viewController = viewController
        self.messagePosition = position
        self.callback = callback
        self.buttonCallback = buttonCallback
        let screenWidth: CGFloat = viewController.view.bounds.size.width
        self.padding = messagePosition == .NavBarOverlay ? messageViewMinimumPadding + 10 : messageViewMinimumPadding
        self.notificationType = type
        
        super.init(frame :CGRect.zero)
        
        
        let options = style ?? SWMessageView.styleForMessageType(type)
        let currentImage = image ?? options.image
        
        backgroundColor = UIColor.clearColor()
        backgroundView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        backgroundView.backgroundColor = options.backgroundColor
        addSubview(backgroundView)
        
        let fontColor: UIColor = options.textColor
        textSpaceLeft = padding
        if let currentImage = currentImage {
            textSpaceLeft +=  padding + 20
            let imageView = UIImageView(image: currentImage)
            iconImageView = imageView
            imageView.contentMode = .ScaleAspectFit
            imageView.frame =  CGRectMake(padding + 5, padding, 20, 20)
            
            addSubview(imageView)
        }
        // Set up title label
        titleLabel.text = title
        titleLabel.textColor = fontColor
        titleLabel.backgroundColor = UIColor.clearColor()
        
        titleLabel.font = options.titleFont ?? UIFont.boldSystemFontOfSize(14)
        if let shadowColor = options.textShadowColor,let shadowOffset = options.shadowOffset {
            titleLabel.shadowColor = shadowColor
            titleLabel.shadowOffset = shadowOffset
        }
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .ByWordWrapping
        addSubview(titleLabel)
        
        // Set up content label (if set)
        if subtitle?.characters.count > 0 {
            contentLabel.text = subtitle
            contentLabel.textColor = options.textColor
            contentLabel.backgroundColor = UIColor.clearColor()
            contentLabel.font = options.contentFont ?? UIFont.systemFontOfSize(12)
            contentLabel.shadowColor = titleLabel.shadowColor
            contentLabel.shadowOffset = titleLabel.shadowOffset
            contentLabel.lineBreakMode = titleLabel.lineBreakMode
            contentLabel.numberOfLines = 0
            addSubview(contentLabel)
        }
        
        // Set up button (if set)
        if let buttonTitle = buttonTitle where buttonTitle.characters.count > 0 {
            button = UIButton(type: .Custom)
            button?.setTitle(buttonTitle, forState: .Normal)
            let buttonTitleTextColor = options.textColor
            button?.setTitleColor(buttonTitleTextColor, forState: .Normal)
            button?.titleLabel?.font = UIFont.boldSystemFontOfSize(14.0)
            if let shadowColor = options.textShadowColor,let shadowOffset = options.shadowOffset {
                button?.titleLabel?.shadowColor = shadowColor
                button?.titleLabel?.shadowOffset = shadowOffset
            }
            button?.addTarget(self, action: #selector(SWMessageView.buttonTapped(_:)), forControlEvents: .TouchUpInside)
            button?.contentEdgeInsets = UIEdgeInsetsMake(0.0, 5.0, 0.0, 5.0)
            button?.sizeToFit()
            button?.frame = CGRectMake(screenWidth - padding - button!.frame.size.width, 0.0, button!.frame.size.width, 31.0)
            addSubview(button!)
            textSpaceRight = button!.frame.size.width + padding
        }
        
        let actualHeight: CGFloat = updateHeightOfMessageView()
        // this call also takes care of positioning the labels
        var topPosition: CGFloat = -actualHeight
        if messagePosition == .Bottom {
            topPosition = viewController.view.bounds.size.height
        }
        frame = CGRectMake(0.0, topPosition, screenWidth, actualHeight)
        if messagePosition == .Top {
            autoresizingMask = [.FlexibleWidth, .FlexibleTopMargin, .FlexibleBottomMargin]
        }
        else {
            autoresizingMask = ([.FlexibleWidth, .FlexibleTopMargin, .FlexibleBottomMargin])
        }
        if dismissingEnabled {
            let gestureRec: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(SWMessageView.fadeMeOut))
            gestureRec.direction = (messagePosition == .Top ? .Up : .Down)
            addGestureRecognizer(gestureRec)
            let tapRec: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SWMessageView.fadeMeOut))
            addGestureRecognizer(tapRec)
        }
        if let _ = callback {
            let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SWMessageView.handleTap(_:)))
            tapGesture.delegate = self
            addGestureRecognizer(tapGesture)
        }
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateHeightOfMessageView() -> CGFloat {
        var currentHeight: CGFloat
        let screenWidth: CGFloat = viewController.view.bounds.size.width
        titleLabel.frame = CGRectMake(textSpaceLeft, padding, screenWidth - padding - textSpaceLeft - textSpaceRight, 0.0)
        titleLabel.sizeToFit()
        if subtitle?.characters.count > 0 {
            contentLabel.frame = CGRectMake(textSpaceLeft, titleLabel.frame.origin.y + titleLabel.frame.size.height + 5.0, screenWidth - padding - textSpaceLeft - textSpaceRight, 0.0)
            contentLabel.sizeToFit()
            currentHeight = contentLabel.frame.origin.y + contentLabel.frame.size.height
        }
        else {
            // only the title was set
            currentHeight = titleLabel.frame.origin.y + titleLabel.frame.size.height
        }
        currentHeight += padding
        if let iconImageView = iconImageView {
            // Check if that makes the popup larger (height)
            if iconImageView.frame.origin.y + iconImageView.frame.size.height + padding > currentHeight {
                currentHeight = iconImageView.frame.origin.y + iconImageView.frame.size.height + padding
            }
            else {
                // z-align
                iconImageView.center = CGPointMake(iconImageView.center.x, round(currentHeight / 2.0))
            }
        }
        frame = CGRectMake(0.0, frame.origin.y, frame.size.width, currentHeight)
        if let button = button {
            // z-align button
            button.center = CGPointMake(button.center.x, round(currentHeight / 2.0))
            button.frame = CGRectMake(frame.size.width - textSpaceRight, round((frame.size.height / 2.0) - button.frame.size.height / 2.0), button.frame.size.width, button.frame.size.height)
        }
        var backgroundFrame: CGRect = CGRectMake(0, 0, screenWidth, currentHeight)
        // increase frame of background view because of the spring animation
        if messagePosition == .Top {
            var topOffset: CGFloat = 0.0
            let navigationController: UINavigationController? = viewController as? UINavigationController ?? viewController.navigationController
            
            if let nav = navigationController {
                let isNavBarIsHidden: Bool =  SWMessageView.isNavigationBarInNavigationControllerHidden(nav)
                let isNavBarIsOpaque: Bool = !nav.navigationBar.translucent && nav.navigationBar.alpha == 1
                if isNavBarIsHidden || isNavBarIsOpaque {
                    topOffset = -30.0
                }
            }
            backgroundFrame = UIEdgeInsetsInsetRect(backgroundFrame, UIEdgeInsetsMake(topOffset, 0.0, 0.0, 0.0))
        }
        else if messagePosition == .Bottom {
            backgroundFrame = UIEdgeInsetsInsetRect(backgroundFrame, UIEdgeInsetsMake(0.0, 0.0, -30.0, 0.0))
        }
        backgroundView.frame = backgroundFrame
        return currentHeight
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        updateHeightOfMessageView()
    }
    
    override public func didMoveToWindow() {
        super.didMoveToWindow()
        if duration == .Endless && superview != nil && window == nil {
            // view controller was dismissed, let's fade out
            fadeMeOut()
        }
    }
    
    
    func fadeMeOut() {
        fadeOut?()
    }
    
    func buttonTapped(sender: AnyObject) {
        buttonCallback?()
        fadeMeOut()
    }
    
    func handleTap(tapGesture: UITapGestureRecognizer) {
        if tapGesture.state == .Recognized {
            callback?()
        }
    }
    
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        return touch.view is UIControl
    }
    
    class func isNavigationBarInNavigationControllerHidden(navController: UINavigationController) -> Bool {
        if navController.navigationBarHidden {
            return true
        }
        else if navController.navigationBar.hidden {
            return true
        }
        else {
            return false
        }
    }
}

private class SWBlurView :UIView {
    
    var blurTintColor :UIColor? {
        get {
            return toolbar.barTintColor
        }
        set(newValue) {
            toolbar.barTintColor = newValue
        }
    }
    
    private lazy var toolbar :UIToolbar = {
        let toolbar = UIToolbar(frame: self.bounds)
        toolbar.userInteractionEnabled = false
        toolbar.translucent = false
        toolbar.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        toolbar.setBackgroundImage(nil, forToolbarPosition: .Any, barMetrics: .Default)
        self.addSubview(toolbar)
        return toolbar
    }()
}

private func defaultStyleForMessageType(type: SWMessageNotificationType) -> SWMessageView.Style {
    let contentFontSize = CGFloat(12)
    let titleFontSize = CGFloat(14)
    let shadowOffsetX = 0
    
    func bundledImageNamed(name: String) -> UIImage? {
        let bundle: NSBundle = NSBundle(forClass: SWMessage.self)
        let imagePath: String = bundle.pathForResource(name, ofType: nil) ?? ""
        return UIImage(contentsOfFile: imagePath) ?? UIImage(named: name)
    }
    
    switch type {
    case .Success:
        return SWMessageView.Style(
            image: bundledImageNamed("NotificationBackgroundSuccessIcon.png"),
            backgroundColor: UIColor(hexString: "#76CF67"),
            textColor: UIColor.whiteColor(),
            textShadowColor: UIColor(hexString: "#67B759"),
            titleFont: UIFont.systemFontOfSize(titleFontSize),
            contentFont: UIFont.systemFontOfSize(contentFontSize),
            shadowOffset: CGSize(width: 0, height: -1)
        )
    case .Message:
        return SWMessageView.Style(
            image: nil,
            backgroundColor: UIColor(hexString: "#D4DDDF"),
            textColor: UIColor(hexString: "#727C83"),
            textShadowColor: UIColor(hexString: "#EBEEF1"),
            titleFont: UIFont.systemFontOfSize(titleFontSize),
            contentFont: UIFont.systemFontOfSize(contentFontSize),
            shadowOffset: CGSize(width: 0, height: -1)
        )
    case .Warning:
        return SWMessageView.Style(
            image: bundledImageNamed("NotificationBackgroundWarningIcon.png"),
            backgroundColor: UIColor(hexString: "#DAC43C"),
            textColor: UIColor(hexString: "#484638"),
            textShadowColor: UIColor(hexString: "#E5D87C"),
            titleFont: UIFont.systemFontOfSize(titleFontSize),
            contentFont: UIFont.systemFontOfSize(contentFontSize),
            shadowOffset: CGSize(width: 0, height: 1)
        )
        
    case .Error:
        return SWMessageView.Style(
            image: bundledImageNamed("NotificationBackgroundErrorIcon.png"),
            backgroundColor: UIColor(hexString: "#DD3B41"),
            textColor: UIColor.whiteColor(),
            textShadowColor: UIColor(hexString: "#812929"),
            titleFont: UIFont.systemFontOfSize(titleFontSize),
            contentFont: UIFont.systemFontOfSize(contentFontSize),
            shadowOffset: CGSize(width: 0, height: -1)
        )
    }
}