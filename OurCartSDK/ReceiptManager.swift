//
//  Receipt.swift
//  OurCartSDK
//
//  Created by Damien Rottemberg on 10/2/17.
//  Copyright © 2017 OurCart. All rights reserved.
//

import UIKit

class ReceiptManager: NSObject {
    
    static let sharedInstance = ReceiptManager()
    
    
    
    public var parts = [ReceiptPart]()
    
    public var annotationParts = [String:Any]()
    
    public var isProcessed = false
    public var isUploaded = false
    
    public var isFinishedProcess = false
    
    
    public private(set) var refID:String?
    public private(set) var receiptID:String?
    
    public var country = "US"
    
    
    
    override init() {
        
        super.init()
        refID = getUniqID()
    }
    
    
    
    
    func addPart(image:UIImage){
        let p = ReceiptPart(image: image, partNumber: parts.count+1)
        parts.append(p)
        p.process(onSuccess: {
            self.updateProcessed()
        }, onError: {(error) in
            
        }, onProgress: {(progress) in
            self.getProgress()
        })
    }
    
    
    
    func hasParts() -> Bool {
        return parts.count > 0
    }
    
    func getLastPart() -> ReceiptPart? {
        return (hasParts()) ? parts[parts.count - 1] : nil
    }
    
    
    func upload(onSuccess successFunc: (() -> Void)? = nil, onError errorFunc: ((_ error: OCError) -> Void)? = nil, onProgress progressFunc: ((_ progress: UInt) -> Void)? = nil){
        
        var hasErrors = false;
        
        var isFinished = false;
        
        
        
        var c = 0
        var tmp = -1
        
        DispatchQueue.global(qos: .background).async {
            // while(c < self.parts.count && hasErrors == false){
            // if(tmp != c){
            //     tmp = c
            for part in self.parts {
                let notified = DispatchSemaphore(value: 0)
                
                part.upload(rID: self.refID!, onSuccess: {
                    self.updateUploaded()
                    // c = c + 1
                    notified.signal()
                }, onError: { (error) in
                    self.cancelUpload()
                    isFinished = true
                    hasErrors = true
                    errorFunc?(error)
                    notified.signal()
                    
                }, onProgress: { (progress) in
                    self.getUploadedProgress()
                    DispatchQueue.main.async {
                        progressFunc?(self.getUploadedProgress())
                    }
                })
                
                _ = notified.wait(timeout: DispatchTime.distantFuture)
                
                if(hasErrors){
                    break
                }
                // }
            }
            
            isFinished = true
            if(!hasErrors){
                progressFunc?(self.getUploadedProgress())
                
                
                ApiManager.sharedInstance.uploadReceiptPartsRequest(parameters: self.getUploadedParts(), onSuccess: { (rID) in
                    
                    
                    self.receiptID = rID
                    
                    successFunc?()
                    
                }, onError: { (error) in
                    
                    errorFunc?(error)
                    
                })
            }
            
            
        }
        
        
        
        
        /* QueueManager.sharedInstance.notify() {
         isFinished = true
         DispatchQueue.main.async {
         
         if(!hasErrors){
         progressFunc?(self.getUploadedProgress())
         
         
         ApiManager.sharedInstance.uploadReceiptPartsRequest(parameters: self.getUploadedParts(), onSuccess: { (rID) in
         
         
         self.receiptID = rID
         
         successFunc?()
         
         }, onError: { (error) in
         
         errorFunc?(error)
         
         })
         }
         
         
         
         }
         }*/
        
        
        
    }
    
    
    
    
    
    
    
    func process(onSuccess successFunc: (() -> Void)? = nil, onError errorFunc: ((_ error: OCError) -> Void)? = nil, onProgress progressFunc: ((_ progress: UInt) -> Void)? = nil){
        
        self.isFinishedProcess = false;
        
        QueueManager.sharedInstance.notify() {
            self.isFinishedProcess = true
            DispatchQueue.main.async {
                progressFunc?(self.getProgress())
                successFunc?()
            }
        }
        
        DispatchQueue.global(qos: .background).async {
            
            let f = self.isFinishedProcess
            let g = self.getProgress()
            
            if !f || g != 100 {
                DispatchQueue.main.async {
                    progressFunc?(self.getProgress())
                }
            }
        }
        
        
        
        
        
        
    }
    
    
    func reset(){
        for r in parts {
            r.cancel()
        }
        parts.removeAll()
        refID = self.getUniqID()
    }
    
    func cancelUpload(){
        for r in parts {
            r.cancelUpload()
        }
    }
    
    func removePart(){
        
        if(parts.count > 0){
            let p = parts.popLast()
            p?.cancel()
        }
    }
    
    private func updateProcessed(){
        
        if(parts.count == 0){
            isProcessed = true
        }else{
            for r in parts {
                isProcessed = isProcessed && r.isProcessed
            }
        }
    }
    
    func getProgress() -> UInt {
        var result:UInt = 0
        if(parts.count == 0){
            result = 100
        }else if(isProcessed){
            result = 100
        }else{
            
            for r in parts {
                if(r.isProcessed){
                    result = result + 100
                }else{
                    result = result + r.progress
                }
            }
        }
        
        
        result = min(100,UInt(Double(result) / Double(parts.count)))
        print(result)
        return result
    }
    
    
    
    private func updateUploaded(){
        
        if(parts.count == 0){
            isUploaded = true
        }else{
            for r in parts {
                isUploaded = isUploaded && r.isUploaded
            }
        }
    }
    
    func getUploadedProgress() -> UInt {
        var result:UInt = 0
        if(parts.count == 0){
            result = 100
        }else if(isUploaded){
            result = 100
        }else{
            
            for r in parts {
                if(r.isUploaded){
                    result = result + 100
                }else{
                    result = result + r.uploadProgress
                }
            }
        }
        
        
        result = min(100,UInt(Double(result) / Double(parts.count)))
        print(result)
        return result
    }
    
    func getUploadedParts() -> [String:Any]{
        
        var result = [String:Any]();
        
        result["skid"] = self.refID!
        result["country"] = self.country
        
        var ps = [String]()
        
        for r in parts {
            ps.append(r.fileUrl!)
        }
        
        
        result["parts"] = ps
        
        do{
            
            
            try print(String.init(data: JSONSerialization.data(withJSONObject: result, options: .prettyPrinted), encoding: .utf8))
        }catch{}
        
        
        
        return result
        
        
    }
    
    func getAnnotationParts() -> [String:Any]{
        
        var result = [[String:Any]]();
        
        for r in parts {
            result.append(["annotations":r.annotations])
        }
        
        
        let p = ["annotationParts":result]
        
        /*do{
            
            
            try print(String.init(data: JSONSerialization.data(withJSONObject: p, options: .prettyPrinted), encoding: .utf8))
        }catch{}
        */
        
        
        return p
        
        
    }
    
    
    func getFullText() -> String{
        
        var result = "";
        
        for r in parts {
            result = result + r.text
        }
        
        
      
        
        
        
        return result
        
        
    }
    
    private func getUniqID() -> String {
        
        return "\(UUID().uuidString) \(Date.timeIntervalSinceReferenceDate)".hash()
        
    }
    
    
    
}

