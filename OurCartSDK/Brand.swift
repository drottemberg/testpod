//
//  Brand.swift
//  snapstar
//
//  Created by Nur  on 04/12/2016.
//  Copyright © 2016 SnapStar. All rights reserved.
//

import UIKit

class Brand {
    
    var name    : String = ""
    var tagline : String = ""
    var logo    : String = ""
    var id      : String = ""
    
    init() {
        
    }
    
    init(dictionary: Dictionary<String, Any?>) {
        self.name    = dictionary["name"]!    is NSNull ? "" : dictionary["name"]    as! String
        self.tagline = dictionary["tagline"]! is NSNull ? "" : dictionary["tagline"] as! String
        self.logo    = dictionary["logo"]!    is NSNull ? "" : dictionary["logo"]    as! String
        self.id      = dictionary["id"]!      is NSNull ? "" : dictionary["id"]      as! String
    }
    
    func logoUrl() -> String {
        let settings   =  LocalSettingsManager.sharedInstance.loadFromDefaults(key: defaults.GENERAL_SERVER_SETTINGS.rawValue) as! Dictionary<String, Any>
        let resources  = settings["resources"] as! Dictionary<String, Any>
        let hostPath   = resources["host"]     as! String
        let rootPath   = resources["rootPath"] as! String
        let brandsPath = resources["brand"]    as! String
        let scale: String
        
        switch UIScreen.main.scale {
        case 2:
            scale = "xhdpi"
        case 3:
            scale = "xxhdpi"
        default:
            scale = "xxhdpi"
        }
        
        let finalUrl = hostPath + rootPath + brandsPath + "/" + scale + "/" + self.logo
        return finalUrl
    }
}
