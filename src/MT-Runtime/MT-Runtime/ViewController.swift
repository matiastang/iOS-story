//
//  ViewController.swift
//  MT-Runtime
//
//  Created by yunxi on 2020/7/22.
//  Copyright © 2020 matias. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
//        self.perform(Selector("test"))
//        ViewController.perform(Selector("newClassTest"))
//        ViewController.perform(Selector("classTest"))
//        self.perform(Selector("testTwo"))
//        ViewController.perform(Selector("classTestThree"))
//        self.perform(Selector("testThree"))
        
//        self.swizzlingMethod()
//        self.originalFunction()
//        self.swizzledFunction()
        
        self.swizzlingMethodTwo()
        self.originalFunctionTwo()
        self.swizzledFunctionTwo()
    }
    
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//    }
    
    // 处理收件人无法识别的消息。
    override class func doesNotRecognizeSelector(_ aSelector: Selector!) {
        print("类消息无法处理\(String(describing: aSelector))")
    }
    
    // 处理收件人无法识别的消息。
    override func doesNotRecognizeSelector(_ aSelector: Selector!) {
        print("实例消息无法处理\(String(describing: aSelector))")
    }
}

extension ViewController {
    
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
}

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

// MARK: - 消息动态解析
extension ViewController {

//    // 类方法未找到时调起，可以在此添加方法实现(动态地为类方法的给定选择器提供实现。)
//    override class func resolveClassMethod(_ sel: Selector!) -> Bool {
//        let methodSelector = #selector(self.newClassTest)//Selector("newClassTest")
//        let method = class_getClassMethod(self, methodSelector)
//        print("\(class_copyMethodList(ViewController.self, nil))")
//        if sel == Selector("classTest") {
//            if let newMethod = method {
//                let success = class_addMethod(ViewController.self, sel, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))
//                print("类方法添加\(success)")
//                print("\(class_copyMethodList(ViewController.self, nil))")
//                if success {
//                    return true
//                }
//            }
//        }
//        return super.resolveClassMethod(sel)
//    }
//
//    // 对象方法未找到时调起，可以在此添加方法实现(为实例方法的给定选择器动态提供实现。)
//    override class func resolveInstanceMethod(_ sel: Selector!) -> Bool {
//        let methodSelector = #selector(self.newTest)
//        let method = class_getInstanceMethod(self, methodSelector)
//        if sel == Selector("test") {
//            if let newMethod = method {
//                let success = class_addMethod(ViewController.self, sel, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))
//                print("实例方法添加\(success)")
//                if success {
//                    return true
//                }
//            }
//        }
//        return super.resolveInstanceMethod(sel)
//    }
//
//    @objc class func newClassTest() {
//        print("动态解析类方法\(#function)")
//    }
//
//    @objc func newTest() {
//        print("动态解析实例方法\(#function)")
//    }
}

// MARK: - 消息接收者重定向
extension ViewController {
    
//    // 重定向类方法的消息接收者，返回一个类(返回无法识别的消息应首先定向到的对象。)
//    override class func forwardingTarget(for aSelector: Selector!) -> Any? {
//        if aSelector == Selector("classTest") {
//            return Person.self// swift中类必须要继承NSObject及其子类
//        }
//        return UIViewController.forwardingTarget(for: aSelector)
//    }
//
//    // 重定向方法的消息接收者，返回一个实例对象(返回无法识别的消息应首先定向到的对象。)
//    override func forwardingTarget(for aSelector: Selector!) -> Any? {
//        if aSelector == Selector("testTwo") {
//            return Person()
//        }
//        return super.forwardingTarget(for: aSelector)
//    }
}

class Person: NSObject {
    
    @objc class func classTest() {
        print("类方法消息接收者重定向\(#function)")
    }
    
    @objc func testTwo() {
        print("实例方法消息接收者重定向\(#function)")
    }
}

// MARK: - 消息重定向
extension ViewController {
    
    // 查找并返回由给定选择器标识的实例方法的实现的地址。
    override class func instanceMethod(for aSelector: Selector!) -> IMP! {
        if aSelector == Selector("testThree") {
            let methodSelector = Selector("newTestThree")
            let method = class_getClassMethod(ViewController.self, methodSelector)
            if let newMethod = method {
                return method_getImplementation(newMethod)
            }
        }
        return super.instanceMethod(for: aSelector)
    }
    
    // 查找并返回方法的接收者实现的地址，因此可以将其称为函数。
    override class func method(for aSelector: Selector!) -> IMP! {
        if aSelector == Selector("classTestThree") {
            let methodSelector = Selector("newClassTestThree")
            let method = class_getClassMethod(ViewController.self, methodSelector)
            if let newMethod = method {
                return method_getImplementation(newMethod)
            }
        }
        return UIViewController.method(for: aSelector)
    }
    
    // 查找并返回方法的接收者实现的地址，因此可以将其称为函数。
    override func method(for aSelector: Selector!) -> IMP! {
        if aSelector == Selector("testThree") {
            let methodSelector = Selector("newTestThree")
            let method = class_getClassMethod(ViewController.self, methodSelector)
            if let newMethod = method {
                return method_getImplementation(newMethod)
            }
        }
        return super.method(for: aSelector)
    }
    
    @objc class func newClassTestThree() {
        print("消息重定向类方法\(#function)")
    }
    
    @objc func newTestThree() {
        print("消息重定向实例方法\(#function)")
    }
}
