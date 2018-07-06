//
//  API.swift
//  sdk
//
//  Created by Nur  on 28/05/2017.
//  Copyright © 2017 OurCart. All rights reserved.
//

import UIKit
import AWSCore

/// main class for API calls and customization of the OurCart SDK
public class OurCart : NSObject {
    
    
    private static  var instance: OurCart? = nil;
    
    
    
    
    public static func getInstance() -> OurCart{
        if(instance == nil){
            instance = OurCart();
            OCLanguage.initLanguage()
            
            
            
            ReceiptManager.sharedInstance.reset()
        }
        return instance!
    }
    
   
    public var defaultLanguage:OCLanguage! {
        get {
            return OCLanguage(rawValue: OCUtil.getObjectForKey(key: OCConstant.DICT_KEY_LANG, defaultValue: OCLanguage.english.rawValue) as! String)!
        }
        set {
             OCUtil.setObjectForKey(key: OCConstant.DICT_KEY_LANG, object: newValue.rawValue)
        }
    }
    
   
    
     
    public func checkQuality(images: [UIImage], onSuccess successFunc: (() -> Void)? = nil, onError errorFunc: ((_ error: OCError) -> Void)? = nil, onProgress progressFunc: ((_ progress: UInt) -> Void)? = nil) {
        ReceiptManager.sharedInstance.reset()
        
        TesseractClient.initSettings(onSuccess: {
            for image in images {
                
                let imgFinal = image.fixedOrientation()
                
                ReceiptManager.sharedInstance.addPart(image: imgFinal)
                
            }
            
            
            ReceiptManager.sharedInstance.process(onSuccess: {
                ApiManager.sharedInstance.validateSimpleReceiptRequest(text: ReceiptManager.sharedInstance.getFullText(), onSuccess: {
                    
                    successFunc?()
                    
                }, onError: { (error:OCError) in
                    DispatchQueue.main.async {
                        errorFunc?(error)
                    }
                })
            }, onError: { (error:OCError) in
                DispatchQueue.main.async {
                    errorFunc?(error)
                }
            }) { (progress) in
                //if(progress != 100){
                    DispatchQueue.main.async {
                        progressFunc?(progress)
                    }
                //}
            }
        }) { (error) in
            
            errorFunc?(error)
        }
        
        
        
        
    }
        
    
}
