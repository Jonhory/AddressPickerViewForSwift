//
//  ViewController.swift
//  AddressPickerViewForSwift
//
//  Created by Jonhory on 2017/3/21.
//  Copyright © 2017年 com.wujh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let filePath = Bundle.main.path(forResource: "address", ofType: "json")
        
        if filePath == nil { print("搜索不到文件"); return }
        do {
            let addressStr = try String.init(contentsOfFile: filePath!, encoding: .utf8)
            print(addressStr)
        } catch  {
            print("encoding error = ",error)
        }
        

        
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

