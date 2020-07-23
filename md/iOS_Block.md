# block

[『Blocks』详尽总结 （二）底层原理](https://www.jianshu.com/p/ba7ab9522cbc)
[《Objective-C 高级编程》干货三部曲（二）：Blocks篇](https://links.jianshu.com/go?to=https%3A%2F%2Fjuejin.im%2Fpost%2F58f40c0a8d6d810064879aaf)

## Blocks 变量语法

```c
int multiplier = 7;
int (^ myBlock)(int)= ^(int num) {
    return num * multiplier;
};
```
这个 Blocks 示例中，myBlock 是声明的块对象，返回类型是 整型值，myBlock 块对象有一个 参数，参数类型为整型值，参数名称为 num。myBlock 块对象的 主体部分 为 return num * multiplier;，包含在 {} 中。

Blocks 规定可以省略好多项目。例如：返回值类型、参数列表。如果用不到，都可以省略。

因为 Block 语法的表达式使用的是它之前声明的局部变量 a、变量 b。Blocks 中，Block 表达式截获所使用的局部变量的值，保存了该变量的瞬时值。所以在第二次执行 Block 表达式时，即使已经改变了局部变量 a 和 b 的值，也不会影响 Block 表达式在执行时所保存的局部变量的瞬时值。

这就是 Blocks 变量截获局部变量值的特性。

在使用 Block 表达式的时候，只能使用保存的局部变量的瞬时值，并不能直接对其进行改写。直接修改编译器会直接报错
如果，我们想在 Block 表达式中，改写 Block 表达式之外声明的局部变量，需要在该局部变量前加上 __block 的修饰符。

ARC 下，通过 __weak 修饰符来消除循环引用
在 ARC 下，可声明附有 __weak 修饰符的变量，并将对象赋值使用。

MRC 下，通过 __block 修饰符来消除循环引用
MRC 下，是不支持 __weak 修饰符的。但是我们可以通过 __block 来消除循环引用。

## blocks本质

__main_block_impl_0 结构体（Block 结构体）相当于 Objective-C 类对象的结构体，isa 指针保存的是所属类的结构体的实例的指针。_NSConcreteStackBlock 相当于 Block 的结构体实例。对象 impl.isa = &_NSConcreteStackBlock; 语句中，将 Block 结构体的指针赋值给其成员变量 isa，相当于 Block 结构体的成员变量 保存了 Block 结构体的指针，这里和 Objective-C 中的对象处理方式是一致的。

也就是说明： Block 的实质就是对象。
Block 跟其他所有的 NSObject 一样，都是对象。果不其然，万物皆对象，古人诚不欺我。

### Blcok 截获局部变量的实质

为什么 Blocks 变量使用的是局部变量的瞬时值，而不是局部变量的当前值呢？

__main_block_impl_0 结构体（Block 结构体）中多了两个成员变量 a 和 b，这两个变量就是 Block 截获的局部变量。 a 和 b 的值来自与 __main_block_impl_0 构造函数中传入的值。

还可以看出 __main_block_func_0（保存 Block 主体部分的结构体）中，变量 a、b 的值使用的 __cself 获取的值。
而 __cself->a、__cself->b 是通过值传递的方式传入进来的，而不是通过指针传递。这也就说明了 a、b 只是 Block 内部的变量，改变 Block 外部的局部变量值，并不能改变 Block 内部的变量值。

在定义 Block 表达式的时候，局部变量使用『值传递』的方式传入 Block 结构体中，并保存为 Block 的成员变量。

而当外部局部变量发生变化的时候，Block 结构体内部对应的的成员变量的值并没有发生改变，所以无论调用几次，Block 表达式结果都没有发生改变。

通过 __block 修饰的局部变量，可以在 Block 的主体部分中改变值。

我们在 __main_block_impl_0 结构体中可以看到： 原 OC 代码中，被 __block 修饰的局部变量 __block int a、__block int b 分别变成了 __Block_byref_a_0、__Block_byref_b_1 类型的结构体指针 a、结构体指针 b。这里使用结构体指针 a 、结构体指针 b 说明 _Block_byref_a_0、__Block_byref_b_1 类型的结构体并不在 __main_block_impl_0 结构体中，而只是通过指针的形式引用，这是为了可以在多个不同的 Block 中使用 __block 修饰的变量。

__Block_byref_a_0、__Block_byref_b_1 类型的结构体声明如下：

```
struct __Block_byref_a_0 {
    void *__isa;
    __Block_byref_a_0 *__forwarding;
    int __flags;
    int __size;
    int a;
};

struct __Block_byref_b_1 {
    void *__isa;
    __Block_byref_b_1 *__forwarding;
    int __flags;
    int __size;
    int b;
};
```

拿第一个 __Block_byref_a_0 结构体定义来说明，__Block_byref_a_0 有 5 个部分：

__isa：标识对象类的 isa 实例变量
__forwarding：传入变量的地址
__flags：标志位
__size：结构体大小
a：存放实变量 a 实际的值，相当于原局部变量的成员变量（和之前不加__block修饰符的时候一致）。
再来看一下 main() 函数中，__block int a、__block int b 的赋值情况。

顺便把代码整理一下，使之简易一点：
```
__Block_byref_a_0 a = {
    (void*)0,
    (__Block_byref_a_0 *)&a, 
    0, 
    sizeof(__Block_byref_a_0), 
    10
};

__Block_byref_b_1 b = {
    0,
    &b, 
    0, 
    sizeof(__Block_byref_b_1), 
    20
};
```
还是拿第一个__Block_byref_a_0 a 的赋值来说明。

可以看到 __isa 指针值传空，__forwarding 指向了局部变量 a 本身的地址，__flags 分配了 0，__size 为结构体的大小，a 赋值为 10。下图用来说明 __forwarding 指针的指向情况。

这下，我们知道 __forwarding 其实就是局部变量 a 本身的地址，那么我们就可以通过 __forwarding 指针来访问局部变量，同时也能对其进行修改了。

来看一下 Block 主体部分对应的 __main_block_func_0 结构体来验证一下。
```
static void __main_block_func_0(struct __main_block_impl_0 *__cself) {
    __Block_byref_a_0 *a = __cself->a; // bound by ref
    __Block_byref_b_1 *b = __cself->b; // bound by ref

    (a->__forwarding->a) = 20;
    (b->__forwarding->b) = 30;

    printf("a = %d, b = %d\n",(a->__forwarding->a), (b->__forwarding->b));
}
```
可以看到 (a->__forwarding->a) = 20; 和 (b->__forwarding->b) = 30; 是通过指针取值的方式来改变了局部变量的值。这也就解释了通过 __block 来修饰的变量，在 Block 的主体部分中改变值的原理其实是：通过『指针传递』的方式。


## Block 的存储区域

通过之前对 Block 本质的探索，我们知道了 Block 的本质是 Objective-C 对象。通过上述代码中 impl.isa = &_NSConcreteStackBlock;，可以知道该 Block 的类名为 NSConcreteStackBlock，根据名称可以看出，该 Block 是存于栈区中的。而与之相关的，还有 _NSConcreteGlobalBlock、_NSConcreteMallocBlock。

### _NSConcreteGlobalBlock

在以下两种情况下使用 Block 的时候，Block 为 NSConcreteGlobalBlock 类对象。

1. 记述全局变量的地方，使用 Block 语法时；
2. Block 语法的表达式中没有截获的自动变量时。
NSConcreteGlobalBlock 类的 Block 存储在`『程序的数据区域』`。因为存放在程序的数据区域，所以即使在变量的作用域外，也可以通过指针安全的使用。

记述全局变量的地方，使用 Block 语法示例代码：
```
void (^myGlobalBlock)(void) = ^{
    printf("GlobalBlock\n");
};

int main() {
    myGlobalBlock();

    return 0;
}
```
通过对应 C++ 源码，我们可以发现：Block 结构体的成员变量 isa 赋值为：impl.isa = &_NSConcreteGlobalBlock;，说明该 Block 为 NSConcreteGlobalBlock 类对象。

### _NSConcreteStackBlock

NSConcreteStackBlock 类的 Block 存储在『栈区』的。如果其所属的变量作用域结束，则该 Block 就会被废弃。如果 Block 使用了 __block 变量，则当 __block 变量的作用域结束，则 __block 变量同样被废弃。

### _NSConcreteMallocBlock

为了解决栈区上的 Block 在变量作用域结束被废弃这一问题，Block 提供了 『复制』 功能。可以将 Block 对象和 __block 变量从栈区复制到堆区上。当 Block 从栈区复制到堆区后，即使栈区上的变量作用域结束时，堆区上的 Block 和 `__block` 变量仍然可以继续存在，也可以继续使用。

此时，『堆区』上的 Block 为 NSConcreteMallocBlock 对象，Block 结构体的成员变量 isa 赋值为：impl.isa = &_NSConcreteMallocBlock;

那么，什么时候才会将 Block 从栈区复制到堆区呢？

这就涉及到了 Block 的自动拷贝和手动拷贝。

### Block 的自动拷贝和手动拷贝

Block 的自动拷贝

在使用 ARC 时，大多数情形下编译器会自动进行判断，自动生成将 Block 从栈上复制到堆上的代码：

1. 将 Block 作为函数返回值返回时，会自动拷贝；
2. 向方法或函数的参数中传递 Block 时，使用以下两种方法的情况下，会进行自动拷贝，否则就需要手动拷贝：
* Cocoa 框架的方法且方法名中含有 usingBlock 等时；
* Grand Central Dispatch（GCD） 的 API。

Block 的手动拷贝

我们可以通过『copy 实例方法（即 alloc / new / copy / mutableCopy）』来对 Block 进行手动拷贝。当我们不确定 Block 是否会被遗弃，需不需要拷贝的时候，直接使用 copy 实例方法即可，不会引起任何的问题。

关于 Block 不同类的拷贝效果总结如下：

Block 类	存储区域	拷贝效果
_NSConcreteStackBlock	栈区	从栈拷贝到堆
_NSConcreteGlobalBlock	程序的数据区域	不做改变
_NSConcreteMallocBlock	堆区	引用计数增加

__block 变量的拷贝
在使用 __block 变量的 Block 从栈复制到堆上时，__block 变量也会受到如下影响：

__block 变量的配置存储区域	Block 从栈复制到堆时的影响
堆区	从栈复制到堆，并被 Block 所持有
栈区	被 Block 所持有
当然，如果不再有 Block 引用该 __block 变量，那么 __block 变量也会被废除。

## weak

[iOS weak 的底层实现原理](http://jefferyfan.com/2019/11/15/programing/iOS/weak/)

![weak](./img/weak-struct.png)
先解释两个单词，referent 是指 weak 变量指向的对象，referrer 是指 weak 变量。

最外层是一个 StripedMap，以 referent 实例地址作为 key，通过哈希，平均映射到 64 个 SideTable 中。
SideTable 中最关键的一个成员是 weak_table，weak_table 的成员 weak_entries 是一个 weak_entry_t 结构体数组，每一个 weak_entry_t 结构体都保存着 referent 地址和指向这个 referent 的所有 weak 变量地址，也就是 referrers 数组。

runtime 源码解释
了解了结构，再来单独聊聊刚刚在汇编中看到的几个函数。

objc_initWeak
通过 referent 去找 SideTable，再遍历 weak_entries 找到对应的 weak entry（ weak_entry_t 结构体），将 weak 变量地址添加到对应的 referrers 数组中。当然，如果没有找到 weak entry，会创建一个。

objc_loadWeak
本身 weak 变量已经指向了 referent。objc_loadWeak 内部检查是否是 tag pointer、是否允许 weak reference 等等条件。并查找是否有对应的 weak entry，如果能找到且各种条件满足，则返回 referent 地址，否则返回 nil。

这里返回的 referent 地址，在 runtime 层已经 retain & autorelease。

objc_destroyWeak
这个函数就是 objc_initWeak 的反向操作，把 weak 变量指针从 referrers 数组中移出。如果 referrers 数组为空，那么也顺带会移除 weak entry。
讲了这么多，那这些 weak 指针置为 nil 的逻辑在哪里呢？
从 NSObject 的 dealloc 源码入手，可以看到最后调用到了 weak_clear_no_lock 方法。

weak_clear_no_lock
这个函数主要逻辑是找到对应的 weak entry，遍历 referrers 数组，将所有的 weak 变量都置为 nil，再将 weak entry 移除掉。