# iOS 内存管理（MRC、ARC）

[彻底理解 iOS 内存管理（MRC、ARC）](https://www.jianshu.com/p/48665652e4e4)
[内存管理--ARC&MRC&引用计数管理](https://blog.csdn.net/ochenmengo/article/details/105013734)

ARC&MRC


内存管理涉及到以下几个方法：
alloc : 分配对象的内存空间。
retain : 使一个对象的引用计数加1
release : 使对象的引用计数减1
retainCount : 获取当前对象的引用计数值
autorelease : 当前对象会在autoreleasePool结束的时候,调用这个对象的release操作,进行引用计数减1
dealloc : 在MRC中若调用dealloc,需要显示的调用[super dealloc],来释放父类的相关成员变量

MRC
什么是MRC：通过手动引用计数来进行对象的内存管理。
MRC中方法retain / release / retainCount / autoreleaset / dealloc, 除了dealloc外，其他的都是MRC特有的，在ARC中若调用这些方法,会引起编译报错

ARC
什么是ARC：通过自动引用计数来管理内存。


之前我认为编译器为我们在对应的位置自动插入相应的retain和release操作,但不完善



ARC不仅是需要编译器LLVM自动为我们在对应的位置插入相应的retain和release操作,还需要Runtime的功能支持,
然后由编译器LLVM和Runtime来共同协作才能组成ARC的全部功能。
 
ARC中方法alloc/dealloc
ARC中禁止手动调用retain / release / retainCount / dealloc,
ARC可以重写某个对象的delloc方法,但不能在dealloc中显示调用[super dealloc]
ARC中新增weak, strong属性关键字
 
ARC和MRC的区别

MRC手动管理内存,ARC是由编译器LLVM和Runtime协作进行自动引用计数来自动管理内存
MRC可以调用一些引用计数相关方法,但ARC中不能调用
另外,因为ARC是由编译器为我们自动插入retain和release的,说明ARC中有相当一大部分是由MRC的机制和原理组成的，
所以为了更好的理解iOS的内存管理方式，我们需要深入的了解关于引用计数原理来管理内存的一个方式和原理。
比如说ARC里面涉及到了Runtime协作，针对这个点考察比如 `weak变量为什么在对象释放的时候会自动置为nil？`

## ARC

ARC的判断原则
ARC判断一个对象是否需要释放不是通过引用计数来进行判断的，而是通过强指针来进行判断的。那么什么是强指针?

强指针
* 默认所有对象的指针变量都是强指针
* 被__strong修饰的指针
```c
 Person *p1 = [[Person alloc] init];
 __strong  Person *p2 = [[Person alloc] init];
```
弱指针
* 被__weak修饰的指针
```
__weak  Person *p = [[Person alloc] init];
```
ARC如何通过强指针来判断？
只要还有一个强指针变量指向对象，对象就会保持在内存中

ARC下@property参数
`strong` : 用于OC对象，相当于MRC中的`retain`
`weak` : 用于OC对象，相当于MRC中的`assign`
`assign` : 用于基本数据类型，跟MRC中的`assign`一样
