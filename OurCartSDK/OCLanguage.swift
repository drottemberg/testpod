//
//  OCLanguage.swift
//  OurCartSDK
//
//  Created by Damien Rottemberg on 11/7/17.
//  Copyright © 2017 OurCart. All rights reserved.
//

import UIKit

public enum OCLanguage : String{
    case english
    case german
    case hebrew
    case spanish
    
    public func toString() -> String{
        switch self {
        case .english:
            return "English"
        case .german:
            return "German"
        case .hebrew:
            return "Hebrew"
        case .spanish:
            return "Spanish"
        }
    }
    
    
    public func shortCode() -> String{
        switch self {
        case .english:
            return "eng"
        case .german:
            return "deu"
        case .hebrew:
            return "heb"
        case .spanish:
            return "spa"
            
        }
        
    }
    
    public func forOCR() -> String{
        switch self {
        case .english:
            return "eng"
        case .german:
            return "eng+deu"
        case .hebrew:
            return "eng+heb"
        case .spanish:
            return "eng+spa"
            
        }
        
    }
    
    
    public static let allValues = [english, german, spanish, hebrew]
    
    
    func isInstalled() -> Bool{
        
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let mainLangURL = NSURL.init(fileURLWithPath: documentsPath).appendingPathComponent("tessdata", isDirectory: true)
        
        let dest = mainLangURL!.appendingPathComponent(self.shortCode()+".traineddata", isDirectory: false)
        
        
        return (try? dest.checkResourceIsReachable()) ?? false
        
    }
    
    
    static func initLanguage(){
        
        
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let mainLangURL = NSURL.init(fileURLWithPath: documentsPath).appendingPathComponent("tessdata", isDirectory: true)
        
        let bundlePath = Bundle.init(for: OurCart.init().classForCoder)
        let langURL = bundlePath.resourceURL//?.appendingPathComponent("tessdata", isDirectory: true)
        
        do {
            if !( (try? mainLangURL!.checkResourceIsReachable()) ?? false) {
                try FileManager.default.createDirectory(at: mainLangURL!, withIntermediateDirectories: true, attributes: nil)
            }
            if ( (try? langURL!.checkResourceIsReachable()) ?? false) {
                
                let enumerator = FileManager.default.enumerator(atPath: langURL!.path)
                while let element = enumerator?.nextObject() as? String {
                    if(element.range(of: ".traineddata") != nil){
                        let src = langURL!.appendingPathComponent(element, isDirectory: false)
                        let dest = mainLangURL!.appendingPathComponent(element, isDirectory: false)
                        if ( (try? dest.checkResourceIsReachable()) ?? false) {
                            let attrSrc = try FileManager.default.attributesOfItem(atPath: src.path)
                            let fileSizeSrc = attrSrc[FileAttributeKey.size] as! UInt64
                            
                            let attrDest = try FileManager.default.attributesOfItem(atPath: dest.path)
                            let fileSizeDest = attrDest[FileAttributeKey.size] as! UInt64
                            
                            if(fileSizeDest != fileSizeSrc){
                                try FileManager.default.removeItem(at: dest)
                                try FileManager.default.copyItem(at: src, to: dest)
                            }
                        }else{
                            try FileManager.default.copyItem(at: src, to: dest)
                            
                        }
                    }
                }
            }
            
        } catch let error as NSError {
            NSLog("Unable to delete file \(error.debugDescription)")
        }
        
        
        
    }
}
