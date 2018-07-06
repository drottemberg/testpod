//
//  OCUtil.swift
//  OurCartSDK
//
//  Created by Damien Rottemberg on 10/2/17.
//  Copyright © 2017 OurCart. All rights reserved.
//

import UIKit

class OCUtil: NSObject {

    
    
    
    public static func getObjectForKey(key:String, defaultValue:Any? = nil ) -> Any? {
        let r = UserDefaults.standard.object(forKey: key)
        if(r == nil){
            return defaultValue
        }else{
            return r
        }
        
    }
    
    static func setObjectForKey(key:String, object: Any){
        UserDefaults.standard.set(_:object, forKey:key)
        UserDefaults.standard.synchronize()
    }
    
    static func removeObjectForKey(key:String){
        UserDefaults.standard.removeObject(forKey:key)
        UserDefaults.standard.synchronize()
    }
    
    
    static func getFlagForKey(key:String) -> Bool {
        return UserDefaults.standard.object(forKey: key) as? Bool ?? false
    }
    
    static func setFlagForKey(key:String, object: Bool){
         UserDefaults.standard.set(_:object, forKey:key)
        UserDefaults.standard.synchronize()
    }
    
    static func getSDKBundle() -> Bundle{
        return Bundle(identifier: OCConstant.SDK_BUNDLE)!
    }
    
    
}
