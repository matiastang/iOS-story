# UIResponder

```swift
import Foundation
import UIKit
import _SwiftUIKitOverlayShims

//
//  UIResponder.h
//  UIKit
//
//  Copyright (c) 2005-2018 Apple Inc. All rights reserved.
//

public typealias UITextAttributesConversionHandler = ([NSAttributedString.Key : Any]) -> [NSAttributedString.Key : Any]

@available(iOS 13.0, *)
public enum UIEditingInteractionConfiguration : Int {

    
    case none = 0

    case `default` = 1 // Default
}

public protocol UIResponderStandardEditActions : NSObjectProtocol {

    
    @available(iOS 3.0, *)
    optional func cut(_ sender: Any?)

    @available(iOS 3.0, *)
    optional func copy(_ sender: Any?)

    @available(iOS 3.0, *)
    optional func paste(_ sender: Any?)

    @available(iOS 3.0, *)
    optional func select(_ sender: Any?)

    @available(iOS 3.0, *)
    optional func selectAll(_ sender: Any?)

    @available(iOS 3.2, *)
    optional func delete(_ sender: Any?)

    @available(iOS 5.0, *)
    optional func makeTextWritingDirectionLeftToRight(_ sender: Any?)

    @available(iOS 5.0, *)
    optional func makeTextWritingDirectionRightToLeft(_ sender: Any?)

    @available(iOS 6.0, *)
    optional func toggleBoldface(_ sender: Any?)

    @available(iOS 6.0, *)
    optional func toggleItalics(_ sender: Any?)

    @available(iOS 6.0, *)
    optional func toggleUnderline(_ sender: Any?)

    
    @available(iOS 7.0, *)
    optional func increaseSize(_ sender: Any?)

    @available(iOS 7.0, *)
    optional func decreaseSize(_ sender: Any?)

    
    @available(iOS 13.0, *)
    optional func updateTextAttributes(conversionHandler: ([NSAttributedString.Key : Any]) -> [NSAttributedString.Key : Any])
}

@available(iOS 2.0, *)
open class UIResponder : NSObject, UIResponderStandardEditActions {

    // 下一级响应者
    open var next: UIResponder? { get }

    // 能否成为第一响应者
    open var canBecomeFirstResponder: Bool { get } // default is NO

    // 成为第一响应者
    open func becomeFirstResponder() -> Bool

    // 能否取消第一响应者
    open var canResignFirstResponder: Bool { get } // default is YES

    // 取消第一响应者
    open func resignFirstResponder() -> Bool

    // 是否为第一响应者
    open var isFirstResponder: Bool { get }

    
    // Generally, all responders which do custom touch handling should override all four of these methods.
    // Your responder will receive either touchesEnded:withEvent: or touchesCancelled:withEvent: for each
    // touch it is handling (those touches it received in touchesBegan:withEvent:).
    // *** You must handle cancelled touches to ensure correct behavior in your application.  Failure to
    // do so is very likely to lead to incorrect behavior or crashes.
    open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)

    open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)

    open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)

    open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?)

    @available(iOS 9.1, *)
    open func touchesEstimatedPropertiesUpdated(_ touches: Set<UITouch>)

    
    // Generally, all responders which do custom press handling should override all four of these methods.
    // Your responder will receive either pressesEnded:withEvent or pressesCancelled:withEvent: for each
    // press it is handling (those presses it received in pressesBegan:withEvent:).
    // pressesChanged:withEvent: will be invoked for presses that provide an analog value
    // (like thumbsticks or analog push buttons)
    // *** You must handle cancelled presses to ensure correct behavior in your application.  Failure to
    // do so is very likely to lead to incorrect behavior or crashes.
    @available(iOS 9.0, *)
    open func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?)

    @available(iOS 9.0, *)
    open func pressesChanged(_ presses: Set<UIPress>, with event: UIPressesEvent?)

    @available(iOS 9.0, *)
    open func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?)

    @available(iOS 9.0, *)
    open func pressesCancelled(_ presses: Set<UIPress>, with event: UIPressesEvent?)

    
    @available(iOS 3.0, *)
    open func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?)

    @available(iOS 3.0, *)
    open func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?)

    @available(iOS 3.0, *)
    open func motionCancelled(_ motion: UIEvent.EventSubtype, with event: UIEvent?)

    
    @available(iOS 4.0, *)
    open func remoteControlReceived(with event: UIEvent?)

    
    @available(iOS 3.0, *)
    open func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool

    // Allows an action to be forwarded to another target. By default checks -canPerformAction:withSender: to either return self, or go up the responder chain.
    @available(iOS 7.0, *)
    open func target(forAction action: Selector, withSender sender: Any?) -> Any?

    
    // Overrides for menu building and validation
    @available(iOS 13.0, *)
    open func buildMenu(with builder: UIMenuBuilder)

    @available(iOS 13.0, *)
    open func validate(_ command: UICommand)

    
    @available(iOS 3.0, *)
    open var undoManager: UndoManager? { get }

    
    // Productivity editing interaction support for undo/redo/cut/copy/paste gestures
    @available(iOS 13.0, *)
    open var editingInteractionConfiguration: UIEditingInteractionConfiguration { get }
}

extension UIResponder {

    @available(iOS 7.0, *)
    open var keyCommands: [UIKeyCommand]? { get } // returns an array of UIKeyCommand objects<
}

extension UIResponder {

    
    // Called and presented when object becomes first responder.  Goes up the responder chain.
    @available(iOS 3.2, *)
    open var inputView: UIView? { get }

    @available(iOS 3.2, *)
    open var inputAccessoryView: UIView? { get }

    
    /// This method is for clients that wish to put buttons on the Shortcuts Bar, shown on top of the keyboard.
    /// You may modify the returned inputAssistantItem to add to or replace the existing items on the bar.
    /// Modifications made to the returned UITextInputAssistantItem are reflected automatically.
    /// This method should not be overridden. Goes up the responder chain.
    @available(iOS 9.0, *)
    open var inputAssistantItem: UITextInputAssistantItem { get }

    
    // For viewController equivalents of -inputView and -inputAccessoryView
    // Called and presented when object becomes first responder.  Goes up the responder chain.
    @available(iOS 8.0, *)
    open var inputViewController: UIInputViewController? { get }

    @available(iOS 8.0, *)
    open var inputAccessoryViewController: UIInputViewController? { get }

    
    /* When queried, returns the current UITextInputMode, from which the keyboard language can be determined.
     * When overridden it should return a previously-queried UITextInputMode object, which will attempt to be
     * set inside that app, but not persistently affect the user's system-wide keyboard settings. */
    @available(iOS 7.0, *)
    open var textInputMode: UITextInputMode? { get }

    /* When the first responder changes and an identifier is queried, the system will establish a context to
     * track the textInputMode automatically. The system will save and restore the state of that context to
     * the user defaults via the app identifier. Use of -textInputMode above will supersede use of -textInputContextIdentifier. */
    @available(iOS 7.0, *)
    open var textInputContextIdentifier: String? { get }

    // This call is to remove stored app identifier state that is no longer needed.
    @available(iOS 7.0, *)
    open class func clearTextInputContextIdentifier(_ identifier: String)

    
    // If called while object is first responder, reloads inputView, inputAccessoryView, and textInputMode.  Otherwise ignored.
    @available(iOS 3.2, *)
    open func reloadInputViews()
}
extension UIKeyCommand {

    
    @available(iOS 7.0, *)
    public class let inputUpArrow: String

    @available(iOS 7.0, *)
    public class let inputDownArrow: String

    @available(iOS 7.0, *)
    public class let inputLeftArrow: String

    @available(iOS 7.0, *)
    public class let inputRightArrow: String

    @available(iOS 7.0, *)
    public class let inputEscape: String

    @available(iOS 8.0, *)
    public class let inputPageUp: String

    @available(iOS 8.0, *)
    public class let inputPageDown: String

    @available(iOS 13.4, *)
    public class let inputHome: String

    @available(iOS 13.4, *)
    public class let inputEnd: String

    
    @available(iOS 13.4, *)
    public class let f1: String

    @available(iOS 13.4, *)
    public class let f2: String

    @available(iOS 13.4, *)
    public class let f3: String

    @available(iOS 13.4, *)
    public class let f4: String

    @available(iOS 13.4, *)
    public class let f5: String

    @available(iOS 13.4, *)
    public class let f6: String

    @available(iOS 13.4, *)
    public class let f7: String

    @available(iOS 13.4, *)
    public class let f8: String

    @available(iOS 13.4, *)
    public class let f9: String

    @available(iOS 13.4, *)
    public class let f10: String

    @available(iOS 13.4, *)
    public class let f11: String

    @available(iOS 13.4, *)
    public class let f12: String
}

extension UIResponder : UIUserActivityRestoring {

    @available(iOS 8.0, *)
    open var userActivity: NSUserActivity?

    @available(iOS 8.0, *)
    open func updateUserActivityState(_ activity: NSUserActivity)

    @available(iOS 8.0, *)
    open func restoreUserActivityState(_ activity: NSUserActivity)
}

extension UIResponder : UIPasteConfigurationSupporting {
}
```
[UIResponder](https://www.jianshu.com/p/2253d41a8541)