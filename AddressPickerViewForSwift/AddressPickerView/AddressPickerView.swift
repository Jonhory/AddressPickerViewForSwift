//
//  AddressPickerView.swift
//  AddressPickerViewForSwift
//
//  Created by Jonhory on 2017/3/21.
//  Copyright © 2017年 com.wujh. All rights reserved.
//

import UIKit

struct AddressPickerKey {
    
    static let provinceIdxName = "addressProvinceIdxName"
    static let cityIdxName     = "addressCityIdxName"
    static let regionIdxName   = "addressRegionIdxName"
}

/// 方便开发者修改各种颜色
final class AddressPickerColor {
    
    var cancelBtn = UIColor(red: 102/255.0, green: 102/255.0, blue: 102/255.0, alpha: 1.0)
    var sureBtn = UIColor(red: 5/255.0, green: 5/255.0, blue: 5/255.0, alpha: 1.0)
    var barViewBackground = UIColor.white
    var pickerViewBackground = UIColor(red: 239/255.0, green: 239/255.0, blue: 244/255.0, alpha: 1.0)
    var pickerRowTitle = UIColor(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1.0)
    
    init(cancelBtn: UIColor = UIColor(red: 102/255.0, green: 102/255.0, blue: 102/255.0, alpha: 1.0), sureBtn: UIColor = UIColor(red: 5/255.0, green: 5/255.0, blue: 5/255.0, alpha: 1.0), barViewBackground: UIColor = UIColor.white, pickerViewBackground: UIColor = UIColor(red: 239/255.0, green: 239/255.0, blue: 244/255.0, alpha: 1.0), pickerRowTitle: UIColor = UIColor(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1.0)) {
        self.cancelBtn = cancelBtn
        self.sureBtn = sureBtn
        self.barViewBackground = barViewBackground
        self.pickerViewBackground = pickerViewBackground
        self.pickerRowTitle = pickerRowTitle
    }
}

protocol AddressPickerViewDelegate: class {
    
    func addressSure(province: String?, city: String?, region: String?)
    
    func addressSure(provinceID: Int?, cityID: Int?, regionID: Int?)
}

final class AddressPickerView: UIView {
    
    class Province {
        
        var name: String = ""
        var id: Int = 0
        var cityModelArr: [City] = []
        
        init(name: String, id: Int) {
            self.name = name
            self.id = id
        }
    }
    
    class City {
        
        var name: String = ""
        var id: Int = 0
        var regionModelArr: [Region] = []
        
        init(name: String, id: Int) {
            self.name = name
            self.id = id
        }
    }
    
    class Region {
        
        var name: String = ""
        var id: Int = 0
    }
    
    typealias lastResultBlock = (_ p:Int, _ c:Int, _ r:Int) -> ()
    
    /// 是否自动显示上次的结果，默认是
    var isAutoOpenLast: Bool = true {
        didSet {
            handleIsOpenLasst()
        }
    }
    
    var colorConfig: AddressPickerColor = AddressPickerColor()
    
    let SELFSIZE = UIScreen.main.bounds.size
    let backView = UIButton()
    var pickerView: UIPickerView?
    var barView: UIView?
    var cancelBtn: UIButton?
    var sureBtn: UIButton?
    
    fileprivate let animateTime = 0.68
    fileprivate let barHeight: CGFloat = 49.0
    fileprivate let pickerHeight: CGFloat = 200
    
    weak var delegate:AddressPickerViewDelegate?
    
    /// 数据源初始化
    lazy var dataDict: [String: Any] = [:]
    /// 省字典
    lazy var provincesArr: [String] = []
    /// 省ID字典
    lazy var provinceIDDict: [String: Int] = [:]
    /// 城市字典
    lazy var citysDict: [String: Any] = [:]
    /// 城市ID字典
    lazy var cityIDDict: [String: Int] = [:]
    /// 地区字典
    lazy var regionsDict: [String: Any] = [:]
    /// 地区ID字典
    lazy var regionIDDict: [String: Int] = [:]
    /// 整体数据源
    lazy var provinceModelArr: [Province] = []
    
    //MARK: 初始化
    class func addTo(superView: UIView, colorConfig: AddressPickerColor = AddressPickerColor()) -> AddressPickerView {
        let pickerView = AddressPickerView(frame: CGRect(x: 0, y: superView.frame.height - 249, width: superView.frame.width, height: 249), colorConfig)
        superView.addSubview(pickerView)
        return pickerView
    }
    
    convenience init(frame: CGRect, _ colorConfig: AddressPickerColor) {
        self.init(frame: frame)
        self.colorConfig = colorConfig
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isHidden = true
        loadAddressData()
        loadBackView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Load UI
extension AddressPickerView {
    
    fileprivate func handleIsOpenLasst() {
        if isAutoOpenLast {
            getLastIdx(block: {[weak self] (p, c, r)  in
                self?.pickerView?.selectRow(p, inComponent: 0, animated: false)
                self?.pickerView?.reloadComponent(1)
                self?.pickerView?.selectRow(c, inComponent: 1, animated: false)
                self?.pickerView?.reloadComponent(2)
                self?.pickerView?.selectRow(r, inComponent: 2, animated: false)
            })
        } else {
            self.pickerView?.selectRow(0, inComponent: 0, animated: false)
            self.pickerView?.selectRow(0, inComponent: 1, animated: false)
            self.pickerView?.selectRow(0, inComponent: 2, animated: false)
        }
    }
    
    fileprivate func loadBackView() {
        addSubview(backView)
        backView.frame = self.bounds
        backView.addTarget(self, action: #selector(hide), for: .touchUpInside)
    }
    
    fileprivate func loadAddressPicker() {
        if pickerView == nil {
            let dframe = CGRect(x: 0, y: self.bounds.height + barHeight, width: self.bounds.width, height: pickerHeight)
            
            pickerView = UIPickerView(frame: dframe)
            pickerView?.backgroundColor = colorConfig.pickerViewBackground
            pickerView?.delegate = self
            pickerView?.dataSource = self
            addSubview(pickerView!)
            
            barView = UIView()
            barView?.frame = CGRect(x: 0, y: self.bounds.height, width: self.bounds.width, height: barHeight)
            barView?.backgroundColor = colorConfig.barViewBackground
            addSubview(barView!)
            
            cancelBtn = UIButton(type: .custom)
            cancelBtn?.setTitle("取消", for: .normal)
            cancelBtn?.addTarget(self, action: #selector(hide), for: .touchUpInside)
            cancelBtn?.setTitleColor(colorConfig.cancelBtn, for: .normal)
            cancelBtn?.frame = CGRect(x: 0, y: 0, width: 80, height: barHeight)
            barView?.addSubview(cancelBtn!)
            
            sureBtn = UIButton(type: .custom)
            sureBtn?.setTitle("确定", for: .normal)
            sureBtn?.addTarget(self, action: #selector(sure), for: .touchUpInside)
            sureBtn?.setTitleColor(colorConfig.sureBtn, for: .normal)
            sureBtn?.frame = CGRect(x: (barView?.frame.size.width)! - 80, y: 0, width: 80, height: barHeight)
            barView?.addSubview(sureBtn!)
            
            handleIsOpenLasst()
        }
    }
    
}

//MARK: - 加载数据源
extension AddressPickerView {
    
    fileprivate func loadAddressData() {
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
        guard let tmpDict = dictionaryWith(jsonString: addressStr) else {
            return
        }
        self.dataDict = tmpDict
        
        provincesArr = dataDict["province"] as! [String]
        citysDict = dataDict["city"] as! [String : Any]
        regionsDict = dataDict["region"] as! [String : Any]
        
        provinceIDDict = dataDict["provinceID"] as! [String: Int]
        cityIDDict = dataDict["cityID"] as! [String: Int]
        regionIDDict = dataDict["regionID"] as! [String: Int]
        
        let provinceCount = provincesArr.count
        for i in 0..<provinceCount {
            let pName = provincesArr[i]
            let citys = citysDict[pName] as! [String]
            
            let p = Province(name: pName, id: provinceIDDict[pName] ?? 0)
            
            var cityModels: [City] = []
            for cityName in citys {
                let regionArr = regionsDict[cityName] as! [String]
                let cityModel = City(name: cityName, id: cityIDDict[cityName] ?? 0)
                
                var regionModels: [Region] = []
                for regionName in regionArr {
                    let regionModel = Region()
                    regionModel.name = regionName
                    regionModel.id = regionIDDict[regionName] ?? 0
                    regionModels.append(regionModel)
                }
                cityModel.regionModelArr = regionModels
                cityModels.append(cityModel)
            }
            p.cityModelArr = cityModels
            provinceModelArr.append(p)
        }
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
}

//MARK: - Actions
extension AddressPickerView {
    
    func show() {
        isHidden = false
        
        loadAddressPicker()
        
        UIView.animate(withDuration: animateTime) {
            self.pickerView?.frame = CGRect(x: 0, y: self.bounds.height - self.pickerHeight, width: self.bounds.width, height: self.pickerHeight)
            self.barView?.frame = CGRect(x: 0, y: self.bounds.height - self.pickerHeight - self.barHeight, width: self.bounds.width, height: self.barHeight)
        }
    }
    
    func hide() {
        UIView.animate(withDuration: animateTime, animations: {
            self.pickerView?.frame = CGRect(x: 0, y: self.bounds.height + self.barHeight, width: self.bounds.width, height: self.pickerHeight)
            self.barView?.frame = CGRect(x: 0, y: self.bounds.height, width: self.bounds.width, height: self.barHeight)
        }) { (finished) in
            if finished {
                self.isHidden = true
            }
        }
    }
    
    func sure() {
        if delegate != nil {
            let selectP = pickerView!.selectedRow(inComponent: 0)
            var selectC = pickerView!.selectedRow(inComponent: 1)
            var selectR = pickerView!.selectedRow(inComponent: 2)
            let p = provinceModelArr[selectP]
            if selectC > p.cityModelArr.count - 1 {
                selectC = p.cityModelArr.count - 1
            }
            let c = p.cityModelArr[selectC]
            if selectR > c.regionModelArr.count - 1 {
                selectR = c.regionModelArr.count - 1
            }
            var rStr: String? = nil
            var rID: Int? = nil
            if c.regionModelArr.count > 1 {
                let r = c.regionModelArr[selectR]
                rStr = r.name
                rID = r.id
            }
            if isAutoOpenLast {
                saveResult(pIdx: selectP, cIdx: selectC, rIdx: selectR)
            }
            delegate?.addressSure(province: p.name, city: c.name, region: rStr)
            delegate?.addressSure(provinceID: p.id, cityID: c.id, regionID: rID)
        }
        hide()
    }
}

// MARK: - UIPickerViewDelegate
extension AddressPickerView: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return provinceModelArr[row].name
        case 1:
            let selectP = pickerView.selectedRow(inComponent: 0)
            let p = provinceModelArr[selectP]
            if row > p.cityModelArr.count - 1 {
                return nil
            }
            return p.cityModelArr[row].name
        case 2:
            let selectP = pickerView.selectedRow(inComponent: 0)
            let selectC = pickerView.selectedRow(inComponent: 1)
            let p = provinceModelArr[selectP]
            if selectC > p.cityModelArr.count - 1 {
                return nil
            }
            let c = p.cityModelArr[selectC]
            if row > c.regionModelArr.count - 1 {
                return nil
            }
            return c.regionModelArr[row].name
        default: return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            let selectC = pickerView.selectedRow(inComponent: 1)
            let selectR = pickerView.selectedRow(inComponent: 2)
            pickerView.reloadComponent(1)
            pickerView.selectRow(selectC, inComponent: 1, animated: true)
            pickerView.reloadComponent(2)
            pickerView.selectRow(selectR, inComponent: 2, animated: true)
            break
        case 1:
            let selectR = pickerView.selectedRow(inComponent: 2)
            pickerView.reloadComponent(2)
            pickerView.selectRow(selectR, inComponent: 2, animated: true)
            break
        default: break
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label = view as? UILabel
        if label == nil {
            label = UILabel()
            label?.textColor = colorConfig.pickerRowTitle
            label?.adjustsFontSizeToFitWidth = true
            label?.textAlignment = .center
            label?.font = UIFont.systemFont(ofSize: 15)
        }
        label?.text = self.pickerView(pickerView, titleForRow: row, forComponent: component)
        return label!
    }
}

// MARK: - UIPickerViewDataSource
extension AddressPickerView: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return provinceModelArr.count
        case 1:
            let selectP = pickerView.selectedRow(inComponent: 0)
            return provinceModelArr[selectP].cityModelArr.count
        case 2:
            let selectP = pickerView.selectedRow(inComponent: 0)
            let selectC = pickerView.selectedRow(inComponent: 1)
            let p = provinceModelArr[selectP]
            if selectC > p.cityModelArr.count - 1 { return 0 }
            return p.cityModelArr[selectC].regionModelArr.count
        default: return 0
        }
    }
}

// MARK: - UserDefaults
extension AddressPickerView {
    
    func saveResult(pIdx: Int, cIdx: Int, rIdx: Int) {
        UserDefaults.standard.set(pIdx, forKey: AddressPickerKey.provinceIdxName)
        UserDefaults.standard.set(cIdx, forKey: AddressPickerKey.cityIdxName)
        UserDefaults.standard.set(rIdx, forKey: AddressPickerKey.regionIdxName)
    }
    
    func getLastIdx(block: @escaping lastResultBlock) {
        let provinceID = UserDefaults.standard.integer(forKey: AddressPickerKey.provinceIdxName)
        let cityID = UserDefaults.standard.integer(forKey: AddressPickerKey.cityIdxName)
        let regionID = UserDefaults.standard.integer(forKey: AddressPickerKey.regionIdxName)
        
        block(provinceID, cityID, regionID)
    }
}
