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
        
        self.perform(Selector("test"))
        ViewController.perform(Selector("newClassTest"))
        ViewController.perform(Selector("classTest"))
    }
}

extension ViewController {
    
    // 类方法未找到时调起，可以在此添加方法实现
    override class func resolveClassMethod(_ sel: Selector!) -> Bool {
        let methodSelector = Selector("newClassTest")
        let method = class_getClassMethod(ViewController.self, methodSelector)
        if sel == Selector("classTest") {
            if let newMethod = method {
                let success = class_addMethod(ViewController.self, sel, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))
                print("类方法添加\(success)")
                if success {
                    return true
                }
            }
        }
        return super.resolveClassMethod(sel)
    }
    
    // 对象方法未找到时调起，可以在此添加方法实现
    override class func resolveInstanceMethod(_ sel: Selector!) -> Bool {
        let methodSelector = #selector(self.newTest)
        let method = class_getInstanceMethod(self, methodSelector)
        if sel == Selector("test") {
            if let newMethod = method {
                let success = class_addMethod(ViewController.self, sel, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))
                print("实例方法添加\(success)")
                if success {
                    return true
                }
            }
        }
        return super.resolveInstanceMethod(sel)
    }
    
    @objc class func newClassTest() {
        print("\(#function)")
    }
    
    @objc func newTest() {
        print("\(#function)")
    }
}

