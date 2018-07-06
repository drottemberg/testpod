//
//  OCReceipt.swift
//  OurCartSDK
//
//  Created by Damien Rottemberg on 9/27/17.
//  Copyright © 2017 OurCart. All rights reserved.
//

import UIKit

class OCReceipt: NSObject {

    
    var purchaseTime:String?
    var receiptSubTotal:String?
    var purchaseDate:String?
    var storeName:String?
    var storePhone:String?
    var storePhone2:String?
    var storeBusinessNumber:String?
    var receiptTotal:String?
    
    
    init(data:[String:Any]) {
        super.init()
        self.build(data: data)
    }
    
    func build(data: [String : Any]) {
        if let d = data["purchaseTime"] { self.purchaseTime = d as? String}
        if let d = data["receiptSubTotal"] { self.receiptSubTotal = d as? String}
        if let d = data["purchaseDate"] { self.purchaseDate = d as? String}
        if let d = data["storeName"] { self.storeName = d as? String}
        if let d = data["storePhone"] { self.storePhone = d as? String}
        if let d = data["storePhone2"] { self.storePhone2 = d as? String}
        if let d = data["storeBusinessNumber"] { self.storeBusinessNumber = d as? String}
        if let d = data["receiptTotal"] { self.receiptTotal = d as? String}
        
        
        
    }
    
    override var description: String {
        
        var json = [String:Any]()
        json["purchaseTime"] = purchaseTime
        json["purchaseDate"] = purchaseDate
        json["receiptSubTotal"] = receiptSubTotal
        json["receiptTotal"] = receiptTotal
        json["storeName"] = storeName
        json["storePhone"] = storePhone
        json["storePhone2"] = storePhone2
        json["storeBusinessNumber"] = storeBusinessNumber
        
        return json.description
    }
    
    
    
}
