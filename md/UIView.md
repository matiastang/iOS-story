# UIView

```swift
extension UIView {

    open var frame: CGRect

    open var bounds: CGRect

    open var center: CGPoint

    open var transform: CGAffineTransform

    @available(iOS 12.0, *)
    open var transform3D: CATransform3D

    @available(iOS 4.0, *)
    open var contentScaleFactor: CGFloat

    open var isMultipleTouchEnabled: Bool

    open var isExclusiveTouch: Bool

    open func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView?

    open func point(inside point: CGPoint, with event: UIEvent?) -> Bool
    // 将像素point由point所在视图转换到目标视图view中，返回在目标视图view中的像素值
    open func convert(_ point: CGPoint, to view: UIView?) -> CGPoint
    // 将像素point从view中转换到当前视图中，返回在当前视图中的像素值
    open func convert(_ point: CGPoint, from view: UIView?) -> CGPoint
    // 将rect由rect所在视图转换到目标视图view中，返回在目标视图view中的rect
    open func convert(_ rect: CGRect, to view: UIView?) -> CGRect
    // 将rect从view中转换到当前视图中，返回在当前视图中的rect
    open func convert(_ rect: CGRect, from view: UIView?) -> CGRect

    open var autoresizesSubviews: Bool

    open var autoresizingMask: UIView.AutoresizingMask

    open func sizeThatFits(_ size: CGSize) -> CGSize

    open func sizeToFit()
}
```