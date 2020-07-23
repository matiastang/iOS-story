# category

[category](https://www.jianshu.com/p/b08bbe3613ab)
[深入理解Objective-C：Category](https://tech.meituan.com/2015/03/03/diveintocategory.html)

## 介绍

Category（分类） 是 Objective-C 2.0 添加的语言特性，主要作用是为已经存在的类添加方法。Category 可以做到在既不子类化，也不侵入一个类的源码的情况下，为原有的类添加新的方法，从而实现扩展一个类或者分离一个类的目的。在日常开发中我们常常使用 Category 为已有的类扩展功能。

虽然继承也能为已有类增加新的方法，而且还能直接增加属性，但继承关系增加了不必要的代码复杂度，在运行时，也无法与父类的原始方法进行区分。所以我们可以优先考虑使用自定义 Category（分类）。

通常 Category（分类）有以下几种使用场景：

* 把类的不同实现方法分开到不同的文件里。
* 声明私有方法。
* 模拟多继承。
* 将 framework 私有方法公开化。

Category（分类）和 Extension（扩展）

Category（分类）看起来和 Extension（扩展）有点相似。Extension（扩展）有时候也被称为 匿名分类。但两者实质上是不同的东西。 Extension（扩展）是在编译阶段与该类同时编译的，是类的一部分。而且 Extension（扩展）中声明的方法只能在该类的 @implementation 中实现，这也就意味着，你无法对系统的类（例如 NSString 类）使用 Extension（扩展）。

而且和 Category（分类）不同的是，Extension（扩展）不但可以声明方法，还可以声明成员变量，这是 Category（分类）所做不到的。

为什么 Category（分类）不能像 Extension（扩展）一样添加成员变量？

因为 Extension（扩展）是在编译阶段与该类同时编译的，就是类的一部分。既然作为类的一部分，且与类同时编译，那么就可以在编译阶段为类添加成员变量。

而 Category（分类）则不同， Category（分类）的特性是：可以在运行时阶段动态地为已有类添加新行为。 Category（分类）是在运行时期间决定的。而成员变量的内存布局已经在编译阶段确定好了，如果在运行时阶段添加成员变量的话，就会破坏原有类的内存布局，从而造成可怕的后果，所以 Category（分类）无法添加成员变量。

## Category 的实质

Object（对象） 和 Class（类） 的实质分别是 objc_object 结构体 和 objc_class 结构体，这里 Category 也不例外，在 objc-runtime-new.h 中，Category（分类）被定义为 category_t 结构体。category_t 结构体 的数据结构如下：

```c
typedef struct category_t *Category;

struct category_t {
    const char *name;                                // 类名
    classref_t cls;                                  // 类，在运行时阶段通过 clasee_name（类名）对应到类对象
    struct method_list_t *instanceMethods;           // Category 中所有添加的对象方法列表
    struct method_list_t *classMethods;              // Category 中所有添加的类方法列表
    struct protocol_list_t *protocols;               // Category 中实现的所有协议列表
    struct property_list_t *instanceProperties;      // Category 中添加的所有属性
};
```
从 Category（分类）的结构体定义中也可以看出， Category（分类）可以为类添加对象方法、类方法、协议、属性。同时，也能发现 Category（分类）无法添加成员变量。

### Category 的 C++ 源码

想要了解 Category 的本质，我们需要借助于 Category 的 C++ 源码。
首先呢，我们需要写一个继承自 NSObject 的 Person 类，还需要写一个 Person+Additon 的分类。在分类中添加对象方法，类方法，属性，以及代理。

例如下边代码中这样：

```c
/********************* Person+Addition.h 文件 *********************/

#import "Person.h"

// PersonProtocol 代理
@protocol PersonProtocol <NSObject>

- (void)PersonProtocolMethod;

+ (void)PersonProtocolClassMethod;

@end

@interface Person (Addition) <PersonProtocol>

/* name 属性 */
@property (nonatomic, copy) NSString *personName;

// 类方法
+ (void)printClassName;

// 对象方法
- (void)printName;

@end

/********************* Person+Addition.m 文件 *********************/

#import "Person+Addition.h"

@implementation Person (Addition)

+ (void)printClassName {
    NSLog(@"printClassName");
}

- (void)printName {
    NSLog(@"printName");
}

#pragma mark - <PersonProtocol> 方法

- (void)PersonProtocolMethod {
    NSLog(@"PersonProtocolMethod");
}

+ (void)PersonProtocolClassMethod {
    NSLog(@"PersonProtocolClassMethod");
}
```

Category 由 OC 转 C++ 源码方法如下：

1. 在项目中添加 Person 类文件 Person.h 和 Person.m，Person 类继承自 NSObject 。
2. 在项目中添加 Person 类的 Category 文件 Person+Addition.h 和 Person+Addition.m，并在 Category 中添加的相关对象方法，类方法，属性，以及代理。
3. 打开『终端』，执行 cd XXX/XXX 命令，其中 XXX/XXX 为 Category 文件 所在的目录。
4. 继续在终端执行 clang -rewrite-objc Person+Addition.m
5. 执行完命令之后，Person+Addition.m 所在目录下就会生成一个 Person+Addition.cpp 文件，这就是我们需要的 Category（分类） 相关的 C++ 源码。

Category 的相关 C++ 源码在文件的最底部。我们删除其他无关代码，只保留 Category 有关的代码，大概就会剩下差不多 200 多行代码。下边我们根据 Category 结构体 的不同结构，分模块来讲解一下。

### Category 的实质总结

下面我们来总结一下 Category 的本质：

Category 的本质就是 _category_t 结构体 类型，其中包含了以下几部分：

* _method_list_t 类型的『对象方法列表结构体』；
* _method_list_t 类型的『类方法列表结构体』；
* _protocol_list_t 类型的『协议列表结构体』；
* _prop_list_t 类型的『属性列表结构体』。
_category_t 结构体 中不包含 _ivar_list_t 类型，也就是不包含『成员变量结构体』。

## Category（分类）和 Class（类）的 +load 方法

Category（分类）中的的方法、属性、协议附加到类上的操作，是在 + load 方法执行之前进行的。也就是说，在 + load 方法执行之前，类中就已经加载了 Category（分类）中的的方法、属性、协议。

而 Category（分类）和 Class（类）的 + load 方法的调用顺序规则如下所示：

1. 先调用主类，按照编译顺序，顺序地根据继承关系由父类向子类调用；
2. 调用完主类，再调用分类，按照编译顺序，依次调用；ıÏÏ
3. + load 方法除非主动调用，否则只会调用一次。
通过这样的调用规则，我们可以知道：主类的 + load 方法调用一定在分类 + load 方法调用之前。但是分类 + load 方法调用顺序并不不是按照继承关系调用的，而是依照编译顺序确定的，这也导致了 + load 方法的调用顺序并不一定确定。一个顺序可能是：父类 -> 子类 -> 父类类别 -> 子类类别，也可能是 父类 -> 子类 -> 子类类别 -> 父类类别。

## Category 与关联对象

之前我们提到过，在 Category 中虽然可以添加属性，但是不会生成对应的成员变量，也不能生成 getter、setter 方法。因此，在调用 Category 中声明的属性时会报错。

那么就没有办法使用 Category 中的属性了吗？

答案当然是否定的。

我们可以自己来实现 getter、setter 方法，并借助关联对象（Objective-C Associated Objects）来实现 getter、setter 方法。关联对象能够帮助我们在运行时阶段将任意的属性关联到一个对象上。具体需要用到以下几个方法：

```c
// 1. 通过 key : value 的形式给对象 object 设置关联属性
void objc_setAssociatedObject(id object, const void *key, id value, objc_AssociationPolicy policy);

// 2. 通过 key 获取关联的属性 object
id objc_getAssociatedObject(id object, const void *key);

// 3. 移除对象所关联的属性
void objc_removeAssociatedObjects(id object);
```
UIImage 分类中增加网络地址属性
```
/********************* UIImage+Property.h 文件 *********************/

#import <UIKit/UIKit.h>

@interface UIImage (Property)

/* 图片网络地址 */
@property (nonatomic, copy) NSString *urlString;

// 用于清除关联对象
- (void)clearAssociatedObjcet;

@end

/********************* UIImage+Property.m 文件 *********************/

#import "UIImage+Property.h"
#import <objc/runtime.h>

@implementation UIImage (Property)

// set 方法
- (void)setUrlString:(NSString *)urlString {
    objc_setAssociatedObject(self, @selector(urlString), urlString, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

// get 方法
- (NSString *)urlString {
    return objc_getAssociatedObject(self, @selector(urlString));
}

// 清除关联对象
- (void)clearAssociatedObjcet {
    objc_removeAssociatedObjects(self);
}

@end
```
测试：
```
UIImage *image = [[UIImage alloc] init];
image.urlString = @"http://www.image.png";

NSLog(@"image urlString = %@",image.urlString);

[image clearAssociatedObjcet];
NSLog(@"image urlString = %@",image.urlString);
```
