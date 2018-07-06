//
//  AwsS3Manager.swift
//  snapstar
//
//  Created by Nur  on 19/12/2016.
//  Copyright © 2016 SnapStar. All rights reserved.
//

import UIKit
import AWSS3

class AwsS3Manager: NSObject {
    
    
    
    
    static let sharedInstance = AwsS3Manager()
    
    static func getUploadConfiguration() -> AWSServiceConfiguration {
        
        let accessKey = OCConstant.S3_ACCESS_KEY
        let secretKey = OCConstant.S3_SECRET_KEY
        let awsStaticCredentials = AWSStaticCredentialsProvider.init(accessKey: accessKey, secretKey: secretKey)
        let configuration = AWSServiceConfiguration.init(region: .USEast1, credentialsProvider: awsStaticCredentials)
        
        return configuration!
        
    }
    
    static func getSettingsConfiguration() -> AWSServiceConfiguration {
        
        let accessKey = OCConstant.S3_ACCESS_KEY_2
        let secretKey = OCConstant.S3_SECRET_KEY_2
        let awsStaticCredentials = AWSStaticCredentialsProvider.init(accessKey: accessKey, secretKey: secretKey)
        let configuration = AWSServiceConfiguration.init(region: .EUCentral1, credentialsProvider: awsStaticCredentials)
        
        return configuration!
        
    }
    
    func uploadFile(fileName:String, image:UIImage,
                    successHandler: ((String) -> Void)? = nil,
                    failureHandler: ((OCError) -> Void)? = nil,
                    progressHandler:  ((UInt) -> Void)? = nil) {
        
        var filePath:URL? = nil
        
        AWSServiceManager.default().defaultServiceConfiguration = AwsS3Manager.getUploadConfiguration()
        
        
        if(image != nil){
            if let data = UIImageJPEGRepresentation(image.resizedImage(withMaximumSize: CGSize(width: 1280, height: 100000)), 1) {
                filePath = NSURL.init(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
                try? data.write(to: filePath!)
            }
        }

        if(filePath == nil){
            failureHandler?(OCError(message: "Can't generate image"))
            return
        }
        
        
    
    
        let bucketName = self.getBucketNameFromSettings()
    
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest?.bucket = bucketName
        
       
        uploadRequest?.key = fileName
        uploadRequest?.body = filePath!
        uploadRequest?.contentType = "image/jpeg"
        
        uploadRequest?.uploadProgress = {(bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) -> Void in
            let i = UInt(Float(totalBytesSent)/Float(totalBytesExpectedToSend)*100.0)
            progressHandler?(i)
            
        }
        
        let transferManger = AWSS3TransferManager.default()
        
        let awsTask:AWSTask = (transferManger.upload(uploadRequest!))
        
        awsTask.continueWith(block: {awsTask in
            if awsTask.error != nil {
                failureHandler?(OCError(message:awsTask.error!.localizedDescription))
            } else {
                awsTask.result
                successHandler?("https://s3.amazonaws.com/"+bucketName+"/"+fileName)
            }
            return nil
        })
    }
    
    private func getBucketNameFromSettings() -> String {
        let settingsDictionary  = LocalSettingsManager.sharedInstance.loadFromDefaults(key: defaults.GENERAL_SERVER_SETTINGS.rawValue) as! Dictionary<String, Any>
        let resourcesDictionary = settingsDictionary["resources"]    as! Dictionary<String, Any>
        let rootPath            = resourcesDictionary["rootPath"]    as! String
        let receiptsPath        = resourcesDictionary["receiptPath"] as! String
        let bucketName          = rootPath.replacingOccurrences(of: "/", with: "").appending(receiptsPath)
        
        return bucketName
    }
    
}

extension String {
   
}
