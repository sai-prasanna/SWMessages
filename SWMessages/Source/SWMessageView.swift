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
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


private let messageViewMinimumPadding :CGFloat = 15.0

open class SWMessageView :UIView , UIGestureRecognizerDelegate {
    
    public struct Style {
        let image: UIImage?
        let backgroundColor: UIColor
        let textColor: UIColor
        let textShadowColor: UIColor?
        let titleFont: UIFont?
        let contentFont: UIFont?
        let shadowOffset: CGSize?
    }
    
    /** The displayed title of this message */
    open let title :String
    
    /** The displayed subtitle of this message */
    open let subtitle :String?
    
    /** The view controller this message is displayed in */
    open let viewController :UIViewController
    
    open let buttonTitle :String?
    
    /** The duration of the displayed message. */
    open var duration :SWMessageDuration = .automatic
    
    /** The position of the message (top or bottom or as overlay) */
    open var messagePosition :SWMessageNotificationPosition
    open var notificationType :SWMessageNotificationType
    
    /** Is the message currenlty fully displayed? Is set as soon as the message is really fully visible */
    open var messageIsFullyDisplayed = false
    
    
    /** Function to customize style globally, initialized to default style. Priority will be This  customOptions in init > styleForMessageType */
    open static var styleForMessageType :(SWMessageNotificationType) -> SWMessageView.Style = defaultStyleForMessageType
    
    var fadeOut :(() -> Void)?
    
    fileprivate let titleLabel = UILabel()
    fileprivate lazy var contentLabel = UILabel()
    fileprivate var iconImageView :UIImageView?
    fileprivate var button :UIButton?
    fileprivate let backgroundView = UIView()
    fileprivate var textSpaceLeft :CGFloat = 0
    fileprivate var textSpaceRight :CGFloat = 0
    fileprivate var callback :(()-> Void)?
    fileprivate var buttonCallback :(()-> Void)?
    fileprivate let padding :CGFloat
    
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
        self.duration = duration ?? .automatic
        self.viewController = viewController
        self.messagePosition = position
        self.callback = callback
        self.buttonCallback = buttonCallback
        let screenWidth: CGFloat = viewController.view.bounds.size.width
        self.padding = messagePosition == .navBarOverlay ? messageViewMinimumPadding + 10 : messageViewMinimumPadding
        self.notificationType = type
        
        super.init(frame :CGRect.zero)
        
        
        let options = style ?? SWMessageView.styleForMessageType(type)
        let currentImage = image ?? options.image
        
        backgroundColor = UIColor.clear
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundView.backgroundColor = options.backgroundColor
        addSubview(backgroundView)
        
        let fontColor: UIColor = options.textColor
        textSpaceLeft = padding
        if let currentImage = currentImage {
            textSpaceLeft +=  padding + 20
            let imageView = UIImageView(image: currentImage)
            iconImageView = imageView
            imageView.contentMode = .scaleAspectFit
            imageView.frame =  CGRect(x: padding + 5, y: padding, width: 20, height: 20)
            
            addSubview(imageView)
        }
        // Set up title label
        titleLabel.text = title
        titleLabel.textColor = fontColor
        titleLabel.backgroundColor = UIColor.clear
        
        titleLabel.font = options.titleFont ?? UIFont.boldSystemFont(ofSize: 14)
        if let shadowColor = options.textShadowColor,let shadowOffset = options.shadowOffset {
            titleLabel.shadowColor = shadowColor
            titleLabel.shadowOffset = shadowOffset
        }
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        addSubview(titleLabel)
        
        // Set up content label (if set)
        if subtitle?.characters.count > 0 {
            contentLabel.text = subtitle
            contentLabel.textColor = options.textColor
            contentLabel.backgroundColor = UIColor.clear
            contentLabel.font = options.contentFont ?? UIFont.systemFont(ofSize: 12)
            contentLabel.shadowColor = titleLabel.shadowColor
            contentLabel.shadowOffset = titleLabel.shadowOffset
            contentLabel.lineBreakMode = titleLabel.lineBreakMode
            contentLabel.numberOfLines = 0
            addSubview(contentLabel)
        }
        
        // Set up button (if set)
        if let buttonTitle = buttonTitle , buttonTitle.characters.count > 0 {
            button = UIButton(type: .custom)
            button?.setTitle(buttonTitle, for: UIControlState())
            let buttonTitleTextColor = options.textColor
            button?.setTitleColor(buttonTitleTextColor, for: UIControlState())
            button?.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14.0)
            if let shadowColor = options.textShadowColor,let shadowOffset = options.shadowOffset {
                button?.titleLabel?.shadowColor = shadowColor
                button?.titleLabel?.shadowOffset = shadowOffset
            }
            button?.addTarget(self, action: #selector(SWMessageView.buttonTapped(_:)), for: .touchUpInside)
            button?.contentEdgeInsets = UIEdgeInsetsMake(0.0, 5.0, 0.0, 5.0)
            button?.sizeToFit()
            button?.frame = CGRect(x: screenWidth - padding - button!.frame.size.width, y: 0.0, width: button!.frame.size.width, height: 31.0)
            addSubview(button!)
            textSpaceRight = button!.frame.size.width + padding
        }
        
        let actualHeight: CGFloat = updateHeightOfMessageView()
        // this call also takes care of positioning the labels
        var topPosition: CGFloat = -actualHeight
        if messagePosition == .bottom {
            topPosition = viewController.view.bounds.size.height
        }
        frame = CGRect(x: 0.0, y: topPosition, width: screenWidth, height: actualHeight)
        if messagePosition == .top {
            autoresizingMask = [.flexibleWidth, .flexibleTopMargin, .flexibleBottomMargin]
        }
        else {
            autoresizingMask = ([.flexibleWidth, .flexibleTopMargin, .flexibleBottomMargin])
        }
        if dismissingEnabled {
            let gestureRec: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(SWMessageView.fadeMeOut))
            gestureRec.direction = (messagePosition == .top ? .up : .down)
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
        titleLabel.frame = CGRect(x: textSpaceLeft, y: padding, width: screenWidth - padding - textSpaceLeft - textSpaceRight, height: 0.0)
        titleLabel.sizeToFit()
        if subtitle?.characters.count > 0 {
            contentLabel.frame = CGRect(x: textSpaceLeft, y: titleLabel.frame.origin.y + titleLabel.frame.size.height + 5.0, width: screenWidth - padding - textSpaceLeft - textSpaceRight, height: 0.0)
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
                iconImageView.center = CGPoint(x: iconImageView.center.x, y: round(currentHeight / 2.0))
            }
        }
        frame = CGRect(x: 0.0, y: frame.origin.y, width: frame.size.width, height: currentHeight)
        if let button = button {
            // z-align button
            button.center = CGPoint(x: button.center.x, y: round(currentHeight / 2.0))
            button.frame = CGRect(x: frame.size.width - textSpaceRight, y: round((frame.size.height / 2.0) - button.frame.size.height / 2.0), width: button.frame.size.width, height: button.frame.size.height)
        }
        var backgroundFrame: CGRect = CGRect(x: 0, y: 0, width: screenWidth, height: currentHeight)
        // increase frame of background view because of the spring animation
        if messagePosition == .top {
            var topOffset: CGFloat = 0.0
            let navigationController: UINavigationController? = viewController as? UINavigationController ?? viewController.navigationController
            
            if let nav = navigationController {
                let isNavBarIsHidden: Bool =  SWMessageView.isNavigationBarInNavigationControllerHidden(nav)
                let isNavBarIsOpaque: Bool = !nav.navigationBar.isTranslucent && nav.navigationBar.alpha == 1
                if isNavBarIsHidden || isNavBarIsOpaque {
                    topOffset = -30.0
                }
            }
            backgroundFrame = UIEdgeInsetsInsetRect(backgroundFrame, UIEdgeInsetsMake(topOffset, 0.0, 0.0, 0.0))
        }
        else if messagePosition == .bottom {
            backgroundFrame = UIEdgeInsetsInsetRect(backgroundFrame, UIEdgeInsetsMake(0.0, 0.0, -30.0, 0.0))
        }
        backgroundView.frame = backgroundFrame
        return currentHeight
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        let _ = updateHeightOfMessageView()
    }
    
    override open func didMoveToWindow() {
        super.didMoveToWindow()
        if duration == .endless && superview != nil && window == nil {
            // view controller was dismissed, let's fade out
            fadeMeOut()
        }
    }
    
    
    func fadeMeOut() {
        fadeOut?()
    }
    
    func buttonTapped(_ sender: AnyObject) {
        buttonCallback?()
        fadeMeOut()
    }
    
    func handleTap(_ tapGesture: UITapGestureRecognizer) {
        if tapGesture.state == .recognized {
            callback?()
        }
    }
    
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view is UIControl
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
    
    fileprivate lazy var toolbar :UIToolbar = {
        let toolbar = UIToolbar(frame: self.bounds)
        toolbar.isUserInteractionEnabled = false
        toolbar.isTranslucent = false
        toolbar.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        toolbar.setBackgroundImage(nil, forToolbarPosition: .any, barMetrics: .default)
        self.addSubview(toolbar)
        return toolbar
    }()
}

private func defaultStyleForMessageType(_ type: SWMessageNotificationType) -> SWMessageView.Style {
    let contentFontSize = CGFloat(12)
    let titleFontSize = CGFloat(14)
    let shadowOffsetX = 0
    
    func bundledImageNamed(_ name: String) -> UIImage? {
        let bundle: Bundle = Bundle(for: SWMessage.self)
        let imagePath: String = bundle.path(forResource: name, ofType: nil) ?? ""
        return UIImage(contentsOfFile: imagePath) ?? UIImage(named: name)
    }
    
    switch type {
    case .success:
        return SWMessageView.Style(
            image: bundledImageNamed("NotificationBackgroundSuccessIcon.png"),
            backgroundColor: UIColor(hexString: "#76CF67"),
            textColor: UIColor.white,
            textShadowColor: UIColor(hexString: "#67B759"),
            titleFont: UIFont.systemFont(ofSize: titleFontSize),
            contentFont: UIFont.systemFont(ofSize: contentFontSize),
            shadowOffset: CGSize(width: 0, height: -1)
        )
    case .message:
        return SWMessageView.Style(
            image: nil,
            backgroundColor: UIColor(hexString: "#D4DDDF"),
            textColor: UIColor(hexString: "#727C83"),
            textShadowColor: UIColor(hexString: "#EBEEF1"),
            titleFont: UIFont.systemFont(ofSize: titleFontSize),
            contentFont: UIFont.systemFont(ofSize: contentFontSize),
            shadowOffset: CGSize(width: 0, height: -1)
        )
    case .warning:
        return SWMessageView.Style(
            image: bundledImageNamed("NotificationBackgroundWarningIcon.png"),
            backgroundColor: UIColor(hexString: "#DAC43C"),
            textColor: UIColor(hexString: "#484638"),
            textShadowColor: UIColor(hexString: "#E5D87C"),
            titleFont: UIFont.systemFont(ofSize: titleFontSize),
            contentFont: UIFont.systemFont(ofSize: contentFontSize),
            shadowOffset: CGSize(width: 0, height: 1)
        )
        
    case .error:
        return SWMessageView.Style(
            image: bundledImageNamed("NotificationBackgroundErrorIcon.png"),
            backgroundColor: UIColor(hexString: "#DD3B41"),
            textColor: UIColor.white,
            textShadowColor: UIColor(hexString: "#812929"),
            titleFont: UIFont.systemFont(ofSize: titleFontSize),
            contentFont: UIFont.systemFont(ofSize: contentFontSize),
            shadowOffset: CGSize(width: 0, height: -1)
        )
    }
}
