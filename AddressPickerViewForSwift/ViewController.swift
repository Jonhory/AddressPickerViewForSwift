//
//  ViewController.swift
//  AddressPickerViewForSwift
//
//  Created by Jonhory on 2017/3/21.
//  Copyright © 2017年 com.wujh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var picker: AddressPickerView?
    let showIDLabel = UILabel()
    let showStrLabel = UILabel()
    let btn = UIButton(type: .custom)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showIDLabel.frame = CGRect(x: 0, y: 0, width: 200, height: 80)
        showIDLabel.numberOfLines = 0
        showIDLabel.textColor = UIColor.red
        showIDLabel.text = "这里展示选中的对应的ID"
        showIDLabel.textAlignment = .center
        showIDLabel.center = CGPoint(x: view.center.x, y: view.center.y - 100)
        view.addSubview(showIDLabel)
        
        showStrLabel.frame = CGRect(x: 0, y: 0, width: 200, height: 30)
        showStrLabel.textColor = UIColor.blue
        showStrLabel.textAlignment = .center
        showStrLabel.text = "这里展示选中的字符串"
        showStrLabel.center = CGPoint(x: view.center.x, y: view.center.y - 150)
        view.addSubview(showStrLabel)
        
        
        picker = AddressPickerView.addTo(superView: view)
        picker?.delegate = self
//        picker?.isAutoOpenLast = false
        picker?.show()

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if picker!.isHidden {
            picker!.show()
        } else {
            picker!.hide()
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController: AddressPickerViewDelegate {
    func addressSure(provinceID: Int?, cityID: Int?, regionID: Int?) {
        var strID = ""
        if let p = provinceID {
            strID += "省：\(p)  "
        }
        if let c = cityID {
            strID += "市：\(c)  "
        }
        if let r = regionID {
            strID += "区：\(r)"
        }
        showIDLabel.text = strID
    }
    
    func addressSure(province: String?, city: String?, region: String?) {
        var p = ""
        var c = ""
        var r = ""
        if province != nil { p = province! }
        if city != nil { c = city! }
        if region != nil { r = region! }
        showStrLabel.text = p + c + r
    }
}
