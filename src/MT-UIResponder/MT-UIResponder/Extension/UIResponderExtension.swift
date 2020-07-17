//
//  UIResponderExtension.swift
//  SaySeal
//
//  Created by 唐道勇 on 2018/3/5.
//  Copyright © 2018年 Beijing Yun Xi Technology Co., Ltd. All rights reserved.
//

import UIKit

/// 当前第一响应者
private weak var currentFirstResponder: AnyObject?

// MARK: - UIResponder的扩展
public extension UIResponder {
    
    // MARK: - 得到当前的第一响应者
    /// 得到当前的第一响应者
    ///
    /// - Returns: 第一响应者
    func mtGetFirstResponder() -> AnyObject? {
        currentFirstResponder = nil
        // 通过将target设置为nil,让系统自动遍历响应链,让当前第一响应者响应我们自定义的方法
        // [sendAction文档](https://developer.apple.com/documentation/uikit/uicontrol/1618237-sendaction)
        UIApplication.shared.sendAction(#selector(mtSetFirstResponder(_:)), to: nil, from: nil, for: nil)
        return currentFirstResponder
    }
    
    // MARK: - 第一响应者调用的方法
    /// 第一响应者调用的方法
    ///
    /// - Parameter sender: 第一响应者
    @objc private func mtSetFirstResponder(_ sender: AnyObject) {
        currentFirstResponder = self
    }
    
    // MARK: - 移除第一响应者(收起键盘)
    /// 第一响应者失去第一响应者身份
    func mtResignFirstResponder() {
        UIApplication.shared.sendAction(#selector(resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
