//
//  ReceiptItem.swift
//  snapstar
//
//  Created by Nur  on 29/12/2016.
//  Copyright © 2016 SnapStar. All rights reserved.
//

import UIKit

class ReceiptItem: NSObject {

    var serialNumber        : Int = -1
    var brand               : Brand = Brand()
    var desc                : String = ""
    var brandOfferStars     : Int = -1
    var brandOfferQuantity  : Int = -1
    var receiptQuantity     : Int = -1
    
    init(dictionary: Dictionary<String, Any>) {
        serialNumber       = dictionary["serialNumber"]   is NSNull ? -1 : dictionary["serialNumber"]    as! CLong
        brand              = dictionary["brand"] is NSNull ? Brand() : Brand.init(dictionary: dictionary["brand"] as! Dictionary<String, Any>)
        desc               = dictionary["desc"]              is NSNull ? "" : dictionary["desc"]      as! String
        brandOfferStars    = dictionary["brandOfferStars"]   is NSNull ? -1 : dictionary["brandOfferStars"]    as! CLong
        brandOfferQuantity = dictionary["brandOfferQuantity"]   is NSNull ? -1 : dictionary["brandOfferQuantity"]    as! CLong
        receiptQuantity    = dictionary["receiptQuantity"]   is NSNull ? -1 : dictionary["receiptQuantity"]    as! CLong
    }
}
