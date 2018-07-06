//
//  ReceiptPart.swift
//  OurCartSDK
//
//  Created by Damien Rottemberg on 10/2/17.
//  Copyright © 2017 OurCart. All rights reserved.
//

import UIKit
import AWSS3



class ReceiptPart: NSObject {

    public private(set) var image:UIImage!
    
    
    public private(set) var isProcessed = false
    public private(set) var progress:UInt = 0
    public private(set) var dispatchWorkItem:DispatchWorkItem?
    
    
    
    public private(set) var isUploaded = false
    public private(set) var uploadProgress:UInt = 0
    public private(set) var uploadWorkItem:DispatchWorkItem?
    
    
    
    public private(set) var text:String = ""
    public private(set) var annotations = [[String:Any]]()
    public private(set) var partNumber:Int!
   
    public private(set) var filename:NSURL?
    public private(set) var fileUrl:String?
    
    
    
    init(image:UIImage, partNumber:Int) {
        self.image = image
        self.partNumber = partNumber
            }
    
    func process(onSuccess successFunc: (() -> Void)? = nil, onError errorFunc: ((_ error: OCError) -> Void)? = nil, onProgress progressFunc: ((_ progress: UInt) -> Void)? = nil){
        if(dispatchWorkItem == nil){
            self.isProcessed = false
            self.dispatchWorkItem  = DispatchWorkItem.init(block: {
                
                let notified = DispatchSemaphore(value: 0)

                
                
                TesseractClient(language:OurCart.getInstance().defaultLanguage).runOCRWithImage(self.image, onSuccess: { (text, annotation) in
                    if(!(self.dispatchWorkItem?.isCancelled)!){
                        self.progress = 100
                        progressFunc?(100)
                        self.text = text!
                        self.annotations = annotation
                        self.isProcessed = true
                        
                    }
                    notified.signal()
                }, onError: { (error) in
                    notified.signal()
                    
                }, onProgress: { (progress) in
                    if(!(self.dispatchWorkItem?.isCancelled)!){
                        self.progress = progress
                        progressFunc?(progress)
                    }
                    
                })
                
               _ = notified.wait(timeout: DispatchTime.distantFuture)
                
                
            })
             QueueManager.sharedInstance.async(item: dispatchWorkItem!)
        }
    }
    
    
    
    
    func upload(rID:String, onSuccess successFunc: (() -> Void)? = nil, onError errorFunc: ((_ error: OCError) -> Void)? = nil, onProgress progressFunc: ((_ progress: UInt) -> Void)? = nil){
        //if(uploadWorkItem == nil || (uploadWorkItem?.isCancelled)!){
            self.isUploaded = false
            AwsS3Manager.sharedInstance.uploadFile(fileName: "\(rID)_\(self.partNumber!).jpg", image: self.image, successHandler: { (fileName:String) in
                //if(!(self.uploadWorkItem?.isCancelled)!){
                    
                    self.isUploaded = true
                    self.fileUrl = fileName
                    
                //}
                successFunc?()
                //notified.signal()
                
            }, failureHandler: { (error:OCError) in
                
                errorFunc?(error)
                
                //notified.signal()
                
            }, progressHandler: { (progress) in
                //if(!(self.uploadWorkItem?.isCancelled)!){
                    
                    self.uploadProgress = progress
                    progressFunc?(progress)
                //}
            })
        //}
    }
    
    
    
    func cancel(){
        
        dispatchWorkItem?.cancel()
        
    }
    
    func cancelUpload(){
        
        uploadWorkItem?.cancel()
        
    }
    
    
    
    
}
