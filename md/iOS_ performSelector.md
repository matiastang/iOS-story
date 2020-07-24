# performSelector

[iOS performSelector 各个方法原理讲解](https://www.jianshu.com/p/1cb1d33208ba)

- (void)performSelector:(SEL)aSelector withObject:(nullable id)anArgument afterDelay:(NSTimeInterval)delay; 其实就是在内部创建了 NSTimer ，然后添加到当前的runloop上面，之所以没有调用，是因为子线程的runloop默认是不开启的

run 之所以要放在后面，是因为，run只是要尝试开启当前线程的runloop，但是当前线程如果没有任何事件(source、timer、observer)的话，也并不会开启成功，所以这就是为什么要放在后面的原因。

performSelector 执行的线程就是当前的线程，当我们没有提交当前的runloop的时候，是不会阻塞的，因为perform这个方法是在当前线程中执行的，所以当我们提交run的时候，检测到有source事件，也就是timer事件，会在当前线程阻塞去执行timer，当timer执行完毕之后，继续向下执行。