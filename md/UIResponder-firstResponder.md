# FirstResponder

firstResponder相关方法
```swift
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
}
```
以上可以知道：

1. 成为第一响应者：

* 点击输入等操作系统自动会查找并设置第一响应者。如果点击输入框则系统自动弹窗键盘。
* 调用响应者的`becomeFirstResponder`方法成为第一响应者，这是我们程序控制的，不用用户触发。

2. 取消第一响应者：

* 调用响应者的`resignFirstResponder`方法取消第一响应者。

这个地方就有一个问题了，我们需要知道第一响应者，才能取消第一响应者，这是一个比较烦的事儿。解决办法就是我们使用`UIApplication`中的`sendAction`方法使应用程序在响应者链中搜索能够执行操作的对象。
[sendAction文档](https://developer.apple.com/documentation/uikit/uicontrol/1618237-sendaction)
```swift
@available(iOS 2.0, *)
open class UIApplication : UIResponder {

    open func sendAction(_ action: Selector, to target: Any?, from sender: Any?, for event: UIEvent?) -> Bool
}
```
添加`UIResponder`扩展功能如下：
```swift
import UIKit

/// 当前第一响应者
private weak var currentFirstResponder: AnyObject?

// MARK: - UIResponder的扩展
public extension UIResponder {
    
    // MARK: - 得到当前的第一响应者
    /// 得到当前的第一响应者
    ///
    /// - Returns: 第一响应者
    func mtGetFirstResponder() -> AnyObject? {
        currentFirstResponder = nil
        // 通过将target设置为nil,让系统自动遍历响应链,让当前第一响应者响应我们自定义的方法
        // [sendAction文档](https://developer.apple.com/documentation/uikit/uicontrol/1618237-sendaction)
        UIApplication.shared.sendAction(#selector(mtSetFirstResponder(_:)), to: nil, from: nil, for: nil)
        return currentFirstResponder
    }
    
    // MARK: - 第一响应者调用的方法
    /// 第一响应者调用的方法
    ///
    /// - Parameter sender: 第一响应者
    @objc private func mtSetFirstResponder(_ sender: AnyObject) {
        currentFirstResponder = self
    }
    
    // MARK: - 移除第一响应者(收起键盘)
    /// 第一响应者失去第一响应者身份
    func mtResignFirstResponder() {
        UIApplication.shared.sendAction(#selector(resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
```
使用如下：
```swift
import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var telTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if telTextField.canBecomeFirstResponder {
            telTextField.becomeFirstResponder()
        }
    }
}

extension ViewController {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let firstResponder = mtGetFirstResponder() {
            print("第一响应者为：\(firstResponder)")
        }
        mtResignFirstResponder()
    }
}
```