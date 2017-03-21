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
        
        
        

        let picker = AddressPickerView()

        picker.backgroundColor = UIColor.lightGray
        view.addSubview(picker)
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

