# Swift

## @_silgen_name

[@_silgen_name](https://stackoverflow.com/questions/35030998/what-is-silgen-name-in-swift-language)

```swift
@_silgen_name("ytcpsocket_connect") private func c_ytcpsocket_connect(_ host:UnsafePointer<Byte>,port:Int32,timeout:Int32) -> Int32
```
如上：使用`@_silgen_name`属性将`c`中的`ytcpsocket_connect`函数重命名为`c_ytcpsocket_connect`，在后续的使用中可以直接使用`c_ytcpsocket_connect`函数。
`@_silgen_name`属性**仅供编译器内部**使用，并且实际上并不等效于C的asm属性，因为它不会将调用约定更改为与C兼容。一般在将Swift移植到其他平台时会用到。

## Mirror
[深度探究HandyJSON(二) Mirror 的原理](https://www.jianshu.com/p/da0ccff0b531)

## isMember、isKind、is

[playground测试](https://github.com/matiastang/iOS-story/tree/master/src/Swift-isMember%E3%80%81isKind%E3%80%81is.playground)
`isMember`和`isKind`是`NSObject` 的方法，在 `Swift` 中只有 `NSObject` 的子类可以调用。
* `isMember` 用来判断该对象是否为指定类的对象
* `isKind` 用来判断该对象是否为指定类或者指定类的子类的对象
* 在 Swift中如果类不是NSObject的子类时，可以使用`is`确定其类型。
is在功能上相当于isKind，不同的是它不仅可以用于class类型上,也可以用于Swift的其他类型,如struct活enum上
如果类型推断已经可以确定是is操作符中的类型，则会提示：`is' test is always true`

```swift
import UIKit

var str = "Hello, playground"
class ClassA: NSObject {
    
}
class ClassB: ClassA {
    
}
class ClassC {
    
}
let a = ClassA()
let b = ClassB()
let c = ClassC()

//isMember和isKind是`NSObject` 的方法，在 Swift 中只有 NSObject 的子类可以调用

//isMember 用来判断该对象是否为指定类的对象
print("\(a.isMember(of: ClassA.self))")
print("\(b.isMember(of: ClassA.self))")
//print("\(c.isMember(of: ClassC.self))")

//isKind 用来判断该对象是否为指定类或者指定类的子类的对象
print("\(a.isKind(of: ClassA.self))")
print("\(b.isKind(of: ClassA.self))")
//print("\(c.isKind(of: ClassC.self))")

//在 Swift中如果类不是NSObject的子类时，可以使用`is`确定其类型。
//is在功能上相当于isKind，不同的是它不仅可以用于class类型上,也可以用于Swift的其他类型,如struct活enum上
//如果类型推断已经可以确定是is操作符中的类型，则会提示：`is' test is always true`
print("\(a.isMember(of: ClassA.self))")
print("\(b.isKind(of: ClassA.self))")
print("\(c is ClassC)")
```