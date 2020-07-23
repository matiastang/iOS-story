# Runtime

[Objective-C 运行时（苹果官方文档）](https://developer.apple.com/documentation/objectivec/objective-c_runtime?language=objc)
[Objective-C 运行时编程指南（苹果官方文档）](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Introduction/Introduction.html)
[参考博文](https://www.jianshu.com/p/633e5d8386a8)

## 介绍

程序源代码转换为可执行文件，一般需要经过`编译`、`链接`、`运行`。不同的编译语言，在这三个步骤中所进行的操作又有些不同。

`Objective-C` 语言 是一门动态语言。在编译阶段并不知道变量的具体数据类型，也不知道所真正调用的哪个函数。只有在运行时间才检查变量的数据类型，同时在运行时才会根据函数名查找要调用的具体函数。这样在程序没运行的时候，我们并不知道调用一个方法具体会发生什么。

`Objective-C` 语言 把一些决定性的工作从`编译`阶段、链接阶段推迟到`运行时`阶段的机制，使得 `Objective-C` 变得更加灵活。我们甚至可以在程序运行的时候，动态的去修改一个方法的实现，这也为大为流行的『热更新』提供了可能性。

而实现 `Objective-C` 语言 `运行时机制` 的一切基础就是 `Runtime`。

`Runtime` 实际上是一个库，这个库使我们可以在程序运行时动态的`创建对象`、`检查对象`，`修改类和对象的方法`。

## 消息机制的基本原理

`Objective-C` 语言 中，对象方法调用都是类似 `[receiver selector];` 的形式，其本质就是让对象在运行时发送消息的过程。

调用 [receiver selector]; 在『编译阶段』和『运行阶段』分别做了什么？

1. 编译阶段：`[receiver selector];` 方法被编译器转换为:

* `objc_msgSend(receiver，selector) （不带参数）`
* `objc_msgSend(recevier，selector，org1，org2，…)（带参数）`

2. 运行时阶段：消息接受者 `recevier` 寻找对应的 `selector`。

1. 通过 `recevier` 的 `isa` 指针 找到 `recevier` 的 `Class`（类）
2. 在 `Class`（类） 的 `cache`（方法缓存） 的散列表中寻找对应的 `IMP`（方法实现）
3. 如果在 `cache`（方法缓存） 中没有找到对应的 `IMP`（方法实现） 的话，就继续在 `Class`（类） 的 `method list`（方法列表） 中找对应的 `selector`，如果找到，填充到 `cache`（方法缓存） 中，并返回 `selector`；
4. 如果在 `Class`（类） 中没有找到这个 `selector`，就继续在它的 `superClass`（父类）中寻找；
5. 一旦找到对应的 `selector`，直接执行 `recevier` 对应 `selector` 方法实现的 `IMP`（方法实现）。
6. 若找不到对应的 `selector`，消息被转发或者临时向 `recevier` 添加这个 `selector` 对应的实现方法，否则就会发生崩溃。

### objc_msgSend

所有 `Objective-C` 方法调用在编译时都会转化为对 `C` 函数 `objc_msgSend` 的调用。`objc_msgSend(receiver，selector);` 是 `[receiver selector];` 对应的 `C` 函数。

### Class（类）

在 `objc/runtime.h` 中，`Class（类）` 被定义为指向 `objc_class` 结构体 的指针，`objc_class` 结构体 的数据结构如下：
```c
/// An opaque type that represents an Objective-C class.
typedef struct objc_class *Class;

struct objc_class {
    Class _Nonnull isa;                                          // objc_class 结构体的实例指针

#if !__OBJC2__
    Class _Nullable super_class;                                 // 指向父类的指针
    const char * _Nonnull name;                                  // 类的名字
    long version;                                                // 类的版本信息，默认为 0
    long info;                                                   // 类的信息，供运行期使用的一些位标识
    long instance_size;                                          // 该类的实例变量大小;
    struct objc_ivar_list * _Nullable ivars;                     // 该类的实例变量列表
    struct objc_method_list * _Nullable * _Nullable methodLists; // 方法定义的列表
    struct objc_cache * _Nonnull cache;                          // 方法缓存
    struct objc_protocol_list * _Nullable protocols;             // 遵守的协议列表
#endif

};
```
从中可以看出，objc_class 结构体 定义了很多变量：自身的所有实例变量（ivars）、所有方法定义（methodLists）、遵守的协议列表（protocols）等。objc_class 结构体 存放的数据称为 元数据（metadata）。

objc_class 结构体 的第一个成员变量是 isa 指针，isa 指针 保存的是所属类的结构体的实例的指针，这里保存的就是 objc_class 结构体的实例指针，而实例换个名字就是 对象。换句话说，Class（类） 的本质其实就是一个对象，我们称之为 类对象。

### Object（对象）

`objc/objc.h` 中关于 `Object（对象） `的定义。
`Object（对象）`被定义为 `objc_object` 结构体，其数据结构如下：
```c
/// Represents an instance of a class.
struct objc_object {
    Class _Nonnull isa;       // objc_object 结构体的实例指针
};

/// A pointer to an instance of a class.
typedef struct objc_object *id;
```
这里的 id 被定义为一个指向 objc_object 结构体 的指针。从中可以看出 objc_object 结构体 只包含一个 Class 类型的 isa 指针。

换句话说，一个 `Object（对象）`唯一保存的就是它所属` Class（类）` 的地址。当我们对一个对象，进行方法调用时，比如 `[receiver selector];`，它会通过 `objc_object` 结构体的 `isa` 指针 去找对应的 `object_class` 结构体，然后在 `object_class` 结构体 的 `methodLists`（方法列表） 中找到我们调用的方法，然后执行。

### Meta Class（元类）

从上边我们看出，对象（objc_object 结构体） 的 isa 指针 指向的是对应的 类对象（object_class 结构体）。那么 类对象（object_class 结构体）的 isa 指针 又指向什么呢？
object_class 结构体 的 isa 指针 实际上指向的的是 类对象 自身的 Meta Class（元类）。
那么什么是 Meta Class（元类）？
Meta Class（元类） 就是一个类对象所属的 类。一个对象所属的类叫做 类对象，而一个类对象所属的类就叫做 元类。

Runtime 中把类对象所属类型就叫做 Meta Class（元类），用于描述类对象本身所具有的特征，而在元类的 methodLists 中，保存了类的方法链表，即所谓的「类方法」。并且类对象中的 isa 指针 指向的就是元类。每个类对象有且仅有一个与之相关的元类。

在 `消息机制的基本原理` 中我们讲解了 `对象方法的调用过程`，我们是通过对象的 isa 指针 找到 对应的 Class（类）；然后在 Class（类） 的 method list（方法列表） 中找对应的 selector 。

而 `类方法的调用过程` 和对象方法调用差不多，流程如下：

1. 通过类对象 `isa` 指针 找到所属的 `Meta Class`（元类）；
2. 在 `Meta Class`（元类） 的 `method list`（方法列表） 中找到对应的 `selector`;
3. 执行对应的 `selector`。

下面看一个示例：
```objective-c
NSString *testString = [NSString stringWithFormat:@"%d,%s",3, "test"];
```
上边的示例中，stringWithFormat: 被发送给了 NSString 类，NSString 类 通过 isa 指针 找到 NSString 元类，然后在该元类的方法列表中找到对应的 stringWithFormat: 方法，然后执行该方法。

### 实例对象（Object）、类（Class）、Meta Class（元类） 的关系

![实例对象（Object）、类（Class）、Meta Class（元类） 的关系](./img/Object-Class-MetaClass.png)

`isa` 指针：

水平方向上，每一级中的 实例对象 的 isa 指针 指向了对应的 类对象，而 类对象 的 isa 指针 指向了对应的 元类。而所有元类的 isa 指针 最终指向了 NSObject 元类，因此 NSObject 元类 也被称为 根元类。
垂直方向上， 元类 的 isa 指针 和 父类元类 的 isa 指针 都指向了 根元类。而 根元类 的 isa 指针 又指向了自己。

`super_class`指针：

类对象 的 父类指针 指向了 父类的类对象，父类的类对象 又指向了 根类的类对象，根类的类对象 最终指向了 nil。
元类 的 父类指针 指向了 父类对象的元类。父类对象的元类 的 父类指针指向了 根类对象的元类，也就是 根元类。而 根元类 的 父亲指针 指向了 根类对象，最终指向了 nil。

### Method（方法）

`object_class` 结构体 的 `methodLists`（方法列表）中存放的元素就是 `Method（方法）`。

先来看下 `objc/runtime.h` 中，表示 `Method（方法）` 的 `objc_method 结构体` 的数据结构：
```c
/// An opaque type that represents a method in a class definition.
/// 代表类定义中一个方法的不透明类型
typedef struct objc_method *Method;

struct objc_method {
    SEL _Nonnull method_name;                    // 方法名
    char * _Nullable method_types;               // 方法类型
    IMP _Nonnull method_imp;                     // 方法实现
};
```
可以看到，objc_method 结构体 中包含了 method_name（方法名），method_types（方法类型） 和 method_imp（方法实现）。下面，我们来了解下这三个变量。

1. SEL method_name; // 方法名
```c
/// An opaque type that represents a method selector.
typedef struct objc_selector *SEL;
```
SEL 是一个指向 objc_selector 结构体 的指针，但是在 runtime 相关头文件中并没有找到明确的定义。不过，通过测试我们可以得出： SEL 只是一个保存方法名的字符串。
```c
SEL sel = @selector(viewDidLoad);
NSLog(@"%s", sel);              // 输出：viewDidLoad
SEL sel1 = @selector(test);
NSLog(@"%s", sel1);             // 输出：test
```

2. IMP method_imp; // 方法实现
```c
/// A pointer to the function of a method implementation. 
#if !OBJC_OLD_DISPATCH_PROTOTYPES
typedef void (*IMP)(void /* id, SEL, ... */ ); 
#else
typedef id _Nullable (*IMP)(id _Nonnull, SEL _Nonnull, ...); 
#endif
```
IMP 的实质是一个函数指针，所指向的就是方法的实现。IMP用来找到函数地址，然后执行函数。

3. char * method_types; // 方法类型
方法类型 method_types 是个字符串，用来存储方法的参数类型和返回值类型。

到这里， Method 的结构就已经很清楚了，Method 将 SEL（方法名） 和 IMP（函数指针） 关联起来，当对一个对象发送消息时，会通过给出的 SEL（方法名） 去找到 IMP（函数指针） ，然后执行。

## Runtime 消息转发

`消息机制的基本原理` 最后一步中我们提到：若找不到对应的 `selector`，`消息被转发`或者`临时向 recevier 添加这个 selector 对应的实现方法`，否则就会发生崩溃。

当一个方法找不到的时候，`Runtime` 提供了 `消息动态解析`、`消息接受者重定向`、`消息重定向` 等三步处理消息。

### 1. 消息动态解析

Objective-C 运行时会调用 `+resolveInstanceMethod:` 或者 `+resolveClassMethod:`，让你有机会提供一个函数实现。前者在 对象方法未找到时 调用，后者在 类方法未找到时 调用。我们可以通过重写这两个方法，添加其他函数实现，并返回 YES， 那运行时系统就会重新启动一次消息发送的过程。

主要用的的方法如下：
```c
// 类方法未找到时调起，可以在此添加方法实现
+ (BOOL)resolveClassMethod:(SEL)sel;
// 对象方法未找到时调起，可以在此添加方法实现
+ (BOOL)resolveInstanceMethod:(SEL)sel;

/** 
 * class_addMethod    向具有给定名称和实现的类中添加新方法
 * @param cls         被添加方法的类
 * @param name        selector 方法名
 * @param imp         实现方法的函数指针
 * @param types imp   指向函数的返回值与参数类型
 * @return            如果添加方法成功返回 YES，否则返回 NO
 */
BOOL class_addMethod(Class cls, SEL name, IMP imp, 
                const char * _Nullable types);
```
举个例子：
```oc
#import "ViewController.h"
#include "objc/runtime.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 执行 fun 函数
    [self performSelector:@selector(fun)];
}

// 重写 resolveInstanceMethod: 添加对象方法实现
+ (BOOL)resolveInstanceMethod:(SEL)sel {
    if (sel == @selector(fun)) { // 如果是执行 fun 函数，就动态解析，指定新的 IMP
        class_addMethod([self class], sel, (IMP)funMethod, "v@:");
        return YES;
    }
    return [super resolveInstanceMethod:sel];
}

void funMethod(id obj, SEL _cmd) {
    NSLog(@"funMethod"); //新的 fun 函数
}

@end
```
虽然我们没有实现 fun 方法，但是通过重写 resolveInstanceMethod: ，利用 class_addMethod 方法添加对象方法实现 funMethod 方法，并执行。从打印结果来看，成功调起了funMethod 方法。

我们注意到 class_addMethod 方法中的特殊参数 v@:，具体可参考官方文档中关于 [Type Encodings 的说明](https://links.jianshu.com/go?to=https%3A%2F%2Fdeveloper.apple.com%2Flibrary%2Farchive%2Fdocumentation%2FCocoa%2FConceptual%2FObjCRuntimeGuide%2FArticles%2FocrtTypeEncodings.html%23%2F%2Fapple_ref%2Fdoc%2Fuid%2FTP40008048-CH100)

### 2. 消息接受者重定向

当前对象实现了 `-forwardingTargetForSelector:` 或者 `+forwardingTargetForSelector:` 方法，Runtime 就会调用这个方法，允许我们将消息的接受者转发给其他对象。

其中用到的方法：
```
// 重定向类方法的消息接收者，返回一个类或实例对象
+ (id)forwardingTargetForSelector:(SEL)aSelector;
// 重定向方法的消息接收者，返回一个类或实例对象
- (id)forwardingTargetForSelector:(SEL)aSelector;
```
类方法和对象方法消息转发第二步调用的方法不一样，前者是+forwardingTargetForSelector: 方法，后者是 -forwardingTargetForSelector: 方法。
这里+resolveInstanceMethod: 或者 +resolveClassMethod:无论是返回 YES，还是返回 NO，只要其中没有添加其函数实现，运行时都会进行下一步。

```objective-c
#import "ViewController.h"
#include "objc/runtime.h"

@interface Person : NSObject

- (void)fun;

@end

@implementation Person

- (void)fun {
    NSLog(@"fun");
}

@end

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 执行 fun 方法
    [self performSelector:@selector(fun)];
}

+ (BOOL)resolveInstanceMethod:(SEL)sel {
    return YES; // 为了进行下一步 消息接受者重定向
}

// 消息接受者重定向
- (id)forwardingTargetForSelector:(SEL)aSelector {
    if (aSelector == @selector(fun)) {
        return [[Person alloc] init];
        // 返回 Person 对象，让 Person 对象接收这个消息
    }
    
    return [super forwardingTargetForSelector:aSelector];
}
```
可以看到，虽然当前 ViewController 没有实现 fun 方法，+resolveInstanceMethod: 也没有添加其他函数实现。但是我们通过 forwardingTargetForSelector 把当前 ViewController 的方法转发给了 Person 对象去执行了。打印结果也证明我们成功实现了转发。

我们通过 forwardingTargetForSelector 可以修改消息的接收者，该方法返回参数是一个对象，如果这个对象是不是 nil，也不是 self，系统会将运行的消息转发给这个对象执行。否则，继续进行下一步：消息重定向流程。

### 3. 消息重定向

如果经过`消息动态解析`、`消息接受者重定向`，Runtime 系统还是找不到相应的方法实现而无法响应消息，`Runtime` 系统会利用 `-methodSignatureForSelector:` 或者 `+methodSignatureForSelector:` 方法获取函数的`参数`和`返回值类型`。

* 如果 `methodSignatureForSelector:` 返回了一个 `NSMethodSignature 对象（函数签名）`，`Runtime` 系统就会创建一个 `NSInvocation` 对象，并通过 `forwardInvocation:` 消息通知当前对象，给予此次消息发送最后一次寻找 `IMP` 的机会。
* 如果 `methodSignatureForSelector:` 返回 `nil`。则 `Runtime` 系统会发出 `doesNotRecognizeSelector:` 消息，程序也就崩溃了。

所以我们可以在 `forwardInvocation:` 方法中对消息进行转发。

类方法和对象方法消息转发第三步调用的方法同样不一样。
类方法调用的是：
```
+ methodSignatureForSelector:
+ forwardInvocation:
+ doesNotRecognizeSelector:
```
对象方法调用的是：
```
- methodSignatureForSelector:
- forwardInvocation:
- doesNotRecognizeSelector:
```
```objective-c
// 获取类方法函数的参数和返回值类型，返回签名
+ (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector;

// 类方法消息重定向
+ (void)forwardInvocation:(NSInvocation *)anInvocation；

// 获取对象方法函数的参数和返回值类型，返回签名
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector;

// 对象方法消息重定向
- (void)forwardInvocation:(NSInvocation *)anInvocation；
```
```
#import "ViewController.h"
#include "objc/runtime.h"

@interface Person : NSObject

- (void)fun;

@end

@implementation Person

- (void)fun {
    NSLog(@"fun");
}

@end

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 执行 fun 函数
    [self performSelector:@selector(fun)];
}

+ (BOOL)resolveInstanceMethod:(SEL)sel {
    return YES; // 为了进行下一步 消息接受者重定向
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    return nil; // 为了进行下一步 消息重定向
}

// 获取函数的参数和返回值类型，返回签名
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    if ([NSStringFromSelector(aSelector) isEqualToString:@"fun"]) {
        return [NSMethodSignature signatureWithObjCTypes:"v@:"];
    }
    
    return [super methodSignatureForSelector:aSelector];
}

// 消息重定向
- (void)forwardInvocation:(NSInvocation *)anInvocation {
    SEL sel = anInvocation.selector;   // 从 anInvocation 中获取消息
    
    Person *p = [[Person alloc] init];

    if([p respondsToSelector:sel]) {   // 判断 Person 对象方法是否可以响应 sel
        [anInvocation invokeWithTarget:p];  // 若可以响应，则将消息转发给其他对象处理
    } else {
        [self doesNotRecognizeSelector:sel];  // 若仍然无法响应，则报错：找不到响应方法
    }
}
@end
```
可以看到，我们在 -forwardInvocation: 方法里面让 Person 对象去执行了 fun 函数。
既然 -forwardingTargetForSelector: 和 -forwardInvocation: 都可以将消息转发给其他对象处理，那么两者的区别在哪？
区别就在于 -forwardingTargetForSelector: 只能将消息转发给一个对象。而 -forwardInvocation: 可以将消息转发给多个对象。
以上就是 Runtime 消息转发的整个流程。

### 消息发送以及转发机制总结

调用 [receiver selector]; 后，进行的流程：

1. 编译阶段：[receiver selector]; 方法被编译器转换为:

* objc_msgSend(receiver，selector) （不带参数）
* objc_msgSend(recevier，selector，org1，org2，…)（带参数）

2. 运行时阶段：消息接受者 recevier 寻找对应的 selector。

1. 通过 recevier 的 isa 指针 找到 recevier 的 class（类）；
2. 在 Class（类） 的 cache（方法缓存） 的散列表中寻找对应的 IMP（方法实现）；
3. 如果在 cache（方法缓存） 中没有找到对应的 IMP（方法实现） 的话，就继续在 Class（类） 的 method list（方法列表） 中找对应的 selector，如果找到，填充到 cache（方法缓存） 中，并返回 selector；
4. 如果在 class（类） 中没有找到这个 selector，就继续在它的 superclass（父类）中寻找；
5. 一旦找到对应的 selector，直接执行 recevier 对应 selector 方法实现的 IMP（方法实现）。
6. 若找不到对应的 selector，Runtime 系统进入`消息转发机制`。

3. 运行时消息转发阶段：

1. `动态解析`：通过重写 +resolveInstanceMethod: 或者 +resolveClassMethod:方法，利用 class_addMethod方法添加其他函数实现；
2. `消息接受者重定向`：如果上一步添加其他函数实现，可在当前对象中利用 forwardingTargetForSelector: 方法将消息的接受者转发给其他对象；
3. `消息重定向`：如果上一步没有返回值为 nil，则利用 methodSignatureForSelector:方法获取函数的参数和返回值类型。
* 如果 methodSignatureForSelector: 返回了一个 NSMethodSignature 对象（函数签名），Runtime 系统就会创建一个 NSInvocation 对象，并通过 forwardInvocation: 消息通知当前对象，给予此次消息发送最后一次寻找 IMP 的机会。
* 如果 methodSignatureForSelector: 返回 nil。则 Runtime 系统会发出 doesNotRecognizeSelector: 消息，程序也就崩溃了。

## 动态方法交换（Method Swizzling）

[Method Swizzling](https://www.jianshu.com/p/1ab7e611107c)

Method Swizzling 用于改变一个已经存在的 selector 实现。我们可以在程序运行时，通过改变 selector 所在 Class（类）的 method list（方法列表）的映射从而改变方法的调用。其实质就是交换两个方法的 IMP（方法实现）。

上一篇文章中我们知道：Method（方法）对应的是 objc_method 结构体；而 objc_method 结构体 中包含了 SEL method_name（方法名）、IMP method_imp（方法实现）。
```c
// objc_method 结构体
typedef struct objc_method *Method;

struct objc_method {
    SEL _Nonnull method_name;                    // 方法名
    char * _Nullable method_types;               // 方法类型
    IMP _Nonnull method_imp;                     // 方法实现
};
```
Method（方法）、SEL（方法名）、IMP（方法实现）三者的关系可以这样来表示：

在运行时，Class（类） 维护了一个 method list（方法列表） 来确定消息的正确发送。method list（方法列表） 存放的元素就是 Method（方法）。而 Method（方法） 中映射了一对键值对：SEL（方法名）：IMP（方法实现）。

Method swizzling 修改了 method list（方法列表），使得不同 Method（方法）中的键值对发生了交换。比如交换前两个键值对分别为 SEL A : IMP A、SEL B : IMP B，交换之后就变为了 SEL A : IMP B、SEL B : IMP A。

### 使用基础

```objective-c
#import "ViewController.h"
#import <objc/runtime.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self SwizzlingMethod];
    [self originalFunction];
    [self swizzledFunction];
}


// 交换 原方法 和 替换方法 的方法实现
- (void)SwizzlingMethod {
    // 当前类
    Class class = [self class];
    
    // 原方法名 和 替换方法名
    SEL originalSelector = @selector(originalFunction);
    SEL swizzledSelector = @selector(swizzledFunction);
    
    // 原方法结构体 和 替换方法结构体
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    // 调用交换两个方法的实现
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

// 原始方法
- (void)originalFunction {
    NSLog(@"originalFunction");
}

// 替换方法
- (void)swizzledFunction {
    NSLog(@"swizzledFunction");
}

@end
```
```swift
func swizzlingMethod() {
        
    let original = Selector("originalFunction")
    let swizzled = Selector("swizzledFunction")
    
    let originalMethod = class_getInstanceMethod(object_getClass(self), original)
    #if swift(<2.0)
//        备注:dynamicType在Swift 3.0中已经被舍弃,我们可以使用type(of:...)来代替
//            let swizzledMethod = class_getInstanceMethod(self.dynamicType, swizzled)
    #else
        let swizzledMethod = class_getInstanceMethod(type(of: self), swizzled)
    #endif

    method_exchangeImplementations(originalMethod!, swizzledMethod!)
}

@objc func originalFunction() {
    print("\(#function)")
}

@objc func swizzledFunction() {
    print("\(#function)")
}
```
### Method Swizzling 方法一
```c
@implementation UIViewController (Swizzling)

// 交换 原方法 和 替换方法 的方法实现
+ (void)load {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 当前类
        Class class = [self class];
        
        // 原方法名 和 替换方法名
        SEL originalSelector = @selector(originalFunction);
        SEL swizzledSelector = @selector(swizzledFunction);
        
        // 原方法结构体 和 替换方法结构体
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        /* 如果当前类没有 原方法的 IMP，说明在从父类继承过来的方法实现，
         * 需要在当前类中添加一个 originalSelector 方法，
         * 但是用 替换方法 swizzledMethod 去实现它 
         */
        BOOL didAddMethod = class_addMethod(class,
                                            originalSelector,
                                            method_getImplementation(swizzledMethod),
                                            method_getTypeEncoding(swizzledMethod));
        
        if (didAddMethod) {
            // 原方法的 IMP 添加成功后，修改 替换方法的 IMP 为 原始方法的 IMP
            class_replaceMethod(class,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        } else {
            // 添加失败（说明已包含原方法的 IMP），调用交换两个方法的实现
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

// 原始方法
- (void)originalFunction {
    NSLog(@"originalFunction");
}

// 替换方法
- (void)swizzledFunction {
    NSLog(@"swizzledFunction");
}

@end
```
```swift
extension ViewController {
    
    func swizzlingMethodTwo() {
        let original = Selector("originalFunctionTwo")
        let swizzled = Selector("swizzledFunctionTwo")
        
        let originalMethod = class_getInstanceMethod(object_getClass(self), original)
        let swizzledMethod = class_getInstanceMethod(type(of: self), swizzled)
        
        // imp添加成功表示已经不存在，添加失败表示已经存在
        let success = class_addMethod(type(of: self), original, method_getImplementation(swizzledMethod!), method_getTypeEncoding(swizzledMethod!))
        if success {
            class_replaceMethod(type(of: self), swizzled, method_getImplementation(originalMethod!), method_getTypeEncoding(originalMethod!))
        } else {
            method_exchangeImplementations(originalMethod!, swizzledMethod!)
        }
    }
    
    @objc func swizzledFunctionTwo() {
        print("\(#function)")
    }
}

extension UIViewController {
    
    @objc func originalFunctionTwo() {
        print("\(#function)")
    }
}
```
### Method Swizzling 方法二

最大不同之处在于使用了函数指针的方式，使用函数指针最大的好处是可以有效避免命名错误。
```c
#import "UIViewController+PointerSwizzling.h"
#import <objc/runtime.h>

typedef IMP *IMPPointer;

// 交换方法函数
static void MethodSwizzle(id self, SEL _cmd, id arg1);
// 原始方法函数指针
static void (*MethodOriginal)(id self, SEL _cmd, id arg1);

// 交换方法函数
static void MethodSwizzle(id self, SEL _cmd, id arg1) {
    
    // 在这里添加 交换方法的相关代码
    NSLog(@"swizzledFunc");
    
    MethodOriginal(self, _cmd, arg1);
}

BOOL class_swizzleMethodAndStore(Class class, SEL original, IMP replacement, IMPPointer store) {
    IMP imp = NULL;
    Method method = class_getInstanceMethod(class, original);
    if (method) {
        const char *type = method_getTypeEncoding(method);
        imp = class_replaceMethod(class, original, replacement, type);
        if (!imp) {
            imp = method_getImplementation(method);
        }
    }
    if (imp && store) { *store = imp; }
    return (imp != NULL);
}

@implementation UIViewController (PointerSwizzling)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzle:@selector(originalFunc) with:(IMP)MethodSwizzle store:(IMP *)&MethodOriginal];
    });
}

+ (BOOL)swizzle:(SEL)original with:(IMP)replacement store:(IMPPointer)store {
    return class_swizzleMethodAndStore(self, original, replacement, store);
}

// 原始方法
- (void)originalFunc {
    NSLog(@"originalFunc");
}

@end
```

## 获取类详细属性、方法

[获取类详细属性、方法](https://www.jianshu.com/p/aeecc4b4621c)