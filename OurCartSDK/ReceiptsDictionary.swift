//
//  ReceiptsDictionary.swift
//  snapstar
//
//  Created by Nur  on 29/12/2016.
//  Copyright © 2016 SnapStar. All rights reserved.
//

import UIKit

public class ReceiptsDictionary: NSObject {
    
    var receiptKey:String = ""
    var receiptId: String = ""
    var purchaseDate: String = ""
    var purchaseTime: String = ""
    var validReceipt: Bool = true
    var total: String = ""
    var storeId: Int = -1
    var retailerName: String = ""
    var brandCount: Int = -1
    var brandsStarsSum: Int = -1
    var receiptItems: [ReceiptItem] = [ReceiptItem]()
    
    init(key: String, dictionary: Dictionary<String, Any>) {
        receiptKey   = key
        if dictionary.isEmpty {
            return
        }
        receiptId    = dictionary["receiptId"]        is NSNull ? "" : dictionary["receiptId"]      as! String
        purchaseDate = dictionary["purchaseDate"]     is NSNull ? "" : dictionary["purchaseDate"]   as! String
        purchaseTime = dictionary["purchaseTime"]     is NSNull ? "" : dictionary["purchaseTime"]   as! String
        validReceipt = dictionary["validReceipt"]     is NSNull ? false : dictionary["validReceipt"] as! Bool
        total        = dictionary["total"]            is NSNull ? "" : dictionary["total"]          as! String
        storeId      = dictionary["storeId"]          is NSNull ? -1 : dictionary["storeId"]        as! CLong
        retailerName = dictionary["retailerName"]     is NSNull ? "" : dictionary["retailerName"]   as! String
        brandCount   = dictionary["brandCount"]       is NSNull ? -1 : dictionary["brandCount"]     as! CLong
        brandsStarsSum = dictionary["brandsStarsSum"] is NSNull ? -1 : dictionary["brandsStarsSum"] as! CLong
        receiptItems = ReceiptsDictionary.receiptsItemsFromDictionary(dictionary:dictionary)
    }
    
    private static func receiptsItemsFromDictionary(dictionary: Dictionary<String, Any>) -> [ReceiptItem]{
        if dictionary["receiptItems"] is NSNull {
            return [ReceiptItem]() // return empty array
        } else {
            var returnArray = [ReceiptItem]()
            
            // extract the array
            let receiptItemsArray = (dictionary["receiptItems"]!) as! NSArray
            
            // init receipt items
            for receipt in receiptItemsArray {
                returnArray.append(ReceiptItem.init(dictionary: receipt as! Dictionary<String, Any>))
            }
            
            return returnArray
        }
    }
}
