# iOS UIViewController中的parentViewController、presentedViewController和presentingViewController

[iOS之ViewController容器篇](https://www.jianshu.com/p/f82da0662c8a)

## parentViewController

UIViewController的parentViewController属性在iOS5下发生了改变

原来的应用在iOS5下做了调试，发现一个弹出的模式窗口的parentViewController属性一直返回nil，查了一下Apple的文档，发现iOS5下UIViewController的parentViewController属性已经发生了变化，所有模式窗口的parentViewController属性都会返回nil，要获得模式窗口的父窗口，需要使用新的presentingViewController属性，同时增加的还有presentedViewController属性。

## presented

当前视图`present`出的`VC`。

## presenting

`present`出当前视图的`VC`。