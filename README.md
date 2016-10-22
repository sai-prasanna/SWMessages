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

## Swift Compatibility

    v0.2.0 -> Swift 2.2
    v0.3.0 -> Swift 3.0

## Carthage
[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate SWMessage into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "sai-prasanna/SWMessages" ~> 0.3.0
```

Run `carthage update` to build the framework and drag the built `SWMessages.framework` into your Xcode project.

## CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate SWMessages into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'SWMessages', '~> 0.3.0'
end
```

Then, run the following command:

```bash
$ pod install
```

## Manually
Copy the source files and asset files from SWMessages directory to your project. It is the only way to make this work in iOS 7.

## Compatibility

**iOS7+**

# Usage

To show notifications use the following code:

```swift
SWMessage.sharedInstance.showNotificationWithTitle(
    "Title",
    subtitle: "Subtitle",
    type: .success
)


// Add a button inside the message
SWMessage.sharedInstance.showNotificationInViewController (
    self,
    title: "Update available",
    subtitle: "Please update our app. We added AI to replace you",
    image: nil,
    type: .success,
    duration: .automatic,
    callback: nil,
    buttonTitle: "Update",
    buttonCallback: { 
      SWMessage.showNotificationWithTitle("Thanks for updating", type: .success)
    },
    atPosition: .top,
    canBeDismissedByUser: true 
)


You can define a default view controller in which the notifications should be displayed:
```swift
SWMessage.sharedInstance.defaultViewController = myNavController
```

You can set custom offset to position message.

```swift
SWMessage.sharedInstance.offsetHeightForMessage = 10.0
```

You can customize a message view, right before it's displayed, like setting an alpha value, or adding a custom subview
```swift
SWMessage.customizeMessageView = { (messageView) in 
    messageView.alpha = ..
    messageView.addSubView(someView)
}
```

You can customize message view for default message types by setting the styleForMessageType callback which takes
the type of message as parameter and returns a SWMessageView.Style struct object.
```swift
SWMessageView.styleForMessageType = { (type)
  ....
  return SWMessageView.Style(...)
}
```



The following properties can be set when creating a new notification:

* **viewController**: The view controller to show the notification in. This might be the navigation controller.
* **title**: The title of the notification view
* **subtitle**: The text that is displayed underneath the title (optional)
* **image**: A custom icon image that is used instead of the default one (optional)
* **type**: The notification type (message, warning, error, success)
* **duration**: The duration the notification should be displayed (automatic, endless, custom)
* **callback**: The block that should be executed, when the user dismissed the message by tapping on it or swiping it to the top.
* **buttonTitle**: The title of button to be shown in right.
* **buttonCallback**: The block that should be executed, when user taps the right button.
* **overrideStyle**: The style override for the particular message

Except the title and the notification type, all of the listed values are optional

If you don't want a detailed description (the text underneath the title) you don't need to set one. The notification will automatically resize itself properly. 


# License
SWMessages is available under the MIT license. See the LICENSE file for more information.
