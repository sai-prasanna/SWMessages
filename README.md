SWMessages
==========
This is port of [TSMessages](https://github.com/KrauseFx/TSMessages) library to Swift. The iOS6 design option is dropped.

This library provides an easy to use class to show little notification views on the top of the screen.

The notification moves from the top of the screen underneath the navigation bar and stays there for a few seconds, depending on the length of the displayed text. To dismiss a notification before the time runs out, the user can swipe it to the top or just tap it.

There are 4 different types already set up for you: Success, Error, Warning, Message (take a look at the screenshots)

**Take a look at the Example project to see how to use this library.** 

## Screenshots

<img src="http://i.imgur.com/ENNJ4Ey.png" alt="Success" width="200px" />
<img src="http://i.imgur.com/RL2R48J.png" alt="Error" width="200px"/>
<img src="http://i.imgur.com/4ex1Mky.png" alt="Error" width="200px"/>

# Installation

## From Carthage
SWMessages is available through [Carthage](https://github.com/Carthage/Carthage). To install
it, simply add the following line to your Cartfile:

github "saiprasanna/SWMessages"

## Manually
Copy the source files and asset files from SWMessages directory to your project. It is the only way to make this work in iOS 7.

## Compatibility

**iOS7+**

# Usage

To show notifications use the following code:

```swift
SWMessage.showNotificationWithTitle(
"Title",
subtitle: "Subtitle",
type: .Success
)


// Add a button inside the message
SWMessage.showNotificationInViewController (
self,
title: "Update available",
subtitle: "Please update our app. We added AI to replace you",
image: nil,
type: .Success,
duration: .Automatic,
callback: nil,
buttonTitle: "Update",
buttonCallback: { 
SWMessage.showNotificationWithTitle("Thanks for updating", type: .Success)
},
atPosition: .Top,
canBeDismissedByUser: true 
)


// Use a custom design file
SWMessage.addCustomDesignFromFileWithName("AlternativeDesign.json")
```

You can define a default view controller in which the notifications should be displayed:
```swift
SWMessage.defaultViewController = myNavController
```

You can set custom offset to position message.

```swift
SWMessage.offsetHeightForMessage = 10.0
```

You can customize a message view, right before it's displayed, like setting an alpha value, or adding a custom subview
```swift
SWMessage.customizeMessageView = { (messageView) in 
messageView.alpha = ..
messageView.addSubView(someView)
}
```

You can customize message view elements using UIAppearance
```swift
import UIKit
import SWMessages

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

var window: UIWindow?

func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

SWMessageView.appearance().titleFont = UIFont.systemFontOfSize(17)
SWMessageView.appearance().titleTextColor = UIColor.whiteColor()
SWMessageView.appearance().contentFont = UIFont.systemFontOfSize(15)
SWMessageView.appearance().contentTextColor  = UIColor.whiteColor()
SWMessageView.appearance().errorIcon = UIImage(named: "errorIcon")
SWMessageView.appearance().successIcon = UIImage(named: "successIcon")
SWMessageView.appearance().warningIcon = UIImage(named: "warningIcon")
SWMessageView.appearance().messageIcon = UIImage(named: "messageIcon")
return true
}
...
}
```



The following properties can be set when creating a new notification:

* **viewController**: The view controller to show the notification in. This might be the navigation controller.
* **title**: The title of the notification view
* **subtitle**: The text that is displayed underneath the title (optional)
* **image**: A custom icon image that is used instead of the default one (optional)
* **type**: The notification type (Message, Warning, Error, Success)
* **duration**: The duration the notification should be displayed (Automatic, Endless, Custom)
* **callback**: The block that should be executed, when the user dismissed the message by tapping on it or swiping it to the top.
* **buttonTitle**: The title of button to be shown in right.
* **buttonCallback**: The block that should be executed, when user taps the right button. 

Except the title and the notification type, all of the listed values are optional

If you don't want a detailed description (the text underneath the title) you don't need to set one. The notification will automatically resize itself properly. 



# License
SWMessages is available under the MIT license. See the LICENSE file for more information.
