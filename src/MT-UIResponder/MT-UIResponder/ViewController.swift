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
