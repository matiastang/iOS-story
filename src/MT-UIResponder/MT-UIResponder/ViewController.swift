//
//  ViewController.swift
//  MT-UIResponder
//
//  Created by yunxi on 2020/7/17.
//  Copyright © 2020 matias. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var telTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if telTextField.canBecomeFirstResponder {
            telTextField.becomeFirstResponder()
        }
    }
}

extension ViewController {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let firstResponder = mtGetFirstResponder() {
            print("第一响应者为：\(firstResponder)")
        }
        mtResignFirstResponder()
    }
}

class viewOne: UIView {
    
    // 寻找合适响应的view
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // 是否能够接收事件
        if !self.isUserInteractionEnabled || self.isHidden || self.alpha <= 0.01 {
            return nil
        }
        // 当前点在不在当前视图范围内
        if self.point(inside: point, with: event) {
            return nil
        }
        for subview in self.subviews {
            // 坐标转换成子控件上的坐标
            let subviewPoint = self.convert(point, to: subview)
            // 检测子控件是否有更合适响应的
            if let nextView = subview.hitTest(subviewPoint, with: event) {
                return nextView
            }
        }
        // 没有找到更合适的，那就返回自己
        return self
    }
    
    // 判断点是否在调用这个方法的view上
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        // 可以自定义逻辑改变响应链
        return true
    }
}
