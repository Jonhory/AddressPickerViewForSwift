//
//  AddressPickerView.swift
//  AddressPickerViewForSwift
//
//  Created by Jonhory on 2017/3/21.
//  Copyright © 2017年 com.wujh. All rights reserved.
//

import UIKit


class AddressPickerView: UIView {

    let SELFSIZE = UIScreen.main.bounds.size
    
    var dataDict: [String: Any]?
    var provincesArr: [String]?
    var citysDict: [String: Any]?
    var regionsDict: [String: Any]?
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: SELFSIZE.width, height: 215))
        loadAddressData()
    }
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    //MARK: - 加载数据源
    private func loadAddressData() {
        let filePath = Bundle.main.path(forResource: "address", ofType: "json")
        if filePath == nil {
            print("加载数据源失败，请检查文件路径")
            return
        }
        var addressStr: String? = nil
        do {
            addressStr = try String.init(contentsOfFile: filePath!, encoding: .utf8)
        } catch {
            print("encoding error = ",error)
            return
        }
        dataDict = dictionaryWith(jsonString: addressStr)
        if dataDict == nil { return }
        
        provincesArr = dataDict!["province"] as! [String]?
        citysDict = dataDict!["city"] as! [String : Any]?
        regionsDict = dataDict!["region"] as! [String : Any]?
        
        print(provincesArr)
    }
    
    private func dictionaryWith(jsonString: String?) -> [String: Any]? {
        var dic: [String: Any]? = nil
        if jsonString != nil {
            let jsonData = jsonString!.data(using: .utf8)
            if jsonData != nil {
                do {
                    let dicc = try JSONSerialization.jsonObject(with: jsonData!, options: .mutableContainers)
                    dic = dicc as? [String: Any]
                } catch {
                    print("json error:",error)
                }
            }
        }
        return dic
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
