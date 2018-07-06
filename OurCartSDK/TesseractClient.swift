//
//  TesseractClient.swift
//  OurCartSDK
//
//  Created by Damien Rottemberg on 9/20/17.
//  Copyright © 2017 OurCart. All rights reserved.
//

import Foundation
import SwiftSoup
import CoreImage
import UIImage_ResizeMagick
import Alamofire
import AWSCore
import AWSS3

class TesseractClient: NSObject, G8TesseractDelegate {
    
    private var tesseract:G8Tesseract?
    
    private static  var instance: TesseractClient? = nil;

    private var params = [String:Any]()
    private var decodedText:String?
    private var receipt:UIImage?
    
    
    
    
    
    
    private var onProgress:((_ progress: UInt) -> Void)?
    
    public  init(language:OCLanguage = .english) {
        super.init()
       /*self.tesseract = G8Tesseract.init()
        self.tesseract?.pageSegmentationMode = .autoOSD
        self.tesseract?.engineMode = .lstmOnly
        self.tesseract?.language = TesseractLang.english.toString()
        self.tesseract?.delegate = self
        self.tesseract?.maximumRecognitionTime = 10000 */
        
        OCLanguage.initLanguage()
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        
        self.tesseract = G8Tesseract.init(language: language.forOCR(), configDictionary: [AnyHashable : Any](), configFileNames: [Any](), absoluteDataPath: documentsPath, engineMode: .lstmOnly)
        
        self.tesseract?.pageSegmentationMode = .autoOSD
        self.tesseract?.delegate = self
        self.tesseract?.maximumRecognitionTime = 10000
        
        
    }
    
    public static func getInstance() -> TesseractClient{
        if(instance == nil){
            instance = TesseractClient();
        }
        return instance!
    }
    
    
    

    
    static func downloadLanguagePack(language: OCLanguage, onSuccess: (() -> Void)? = nil,onError errorFunc: ((_ error: OCError) -> Void)? = nil,onProgress progressFunc: ((_ progress: UInt) -> Void)? = nil) {
        
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let mainLangURL = NSURL.init(fileURLWithPath: documentsPath).appendingPathComponent("tessdata", isDirectory: true)
       
        OCLanguage.initLanguage()
        
        
        let destination = { (temporaryURL:URL, response:HTTPURLResponse) -> (URL, DownloadRequest.DownloadOptions) in
            let directoryURLs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            

            
            
            if !directoryURLs.isEmpty {
                
                let tmp = directoryURLs[0].appendingPathComponent(response.suggestedFilename!)
                
                do {
                    if ( (try? tmp.checkResourceIsReachable()) ?? false) {
                        try FileManager.default.removeItem(at: tmp)
                    }
                }catch{}
                return (tmp, [])
            }
            
            return (temporaryURL, [])
        }
        
        
        
        
        
        
        let element = language.shortCode()+".traineddata"
        
        Alamofire.download(
            "http://demoji.co/lang/"+element,
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: nil,
            to: destination).downloadProgress(closure: { (progress) in
                
                
                progressFunc?( UInt(progress.fractionCompleted*100.0))
                
            }).response(completionHandler: { (response) in
                DispatchQueue.main.async {
                    
                    if(response.error != nil){
                        errorFunc?(OCError(message:response.error!.localizedDescription))
                    }else{
                        
                        if(response.response?.statusCode != 200){
                            
                            do {
                                try FileManager.default.removeItem(at: response.destinationURL!)
                            } catch {}
                            do {
                                try FileManager.default.removeItem(at: response.temporaryURL!)
                            } catch {}
                            
                            
                            errorFunc?(OCError(message:"Language Pack doen't exist"))
                            
                        }else{
                            
                            do {
                                
                                let src = response.destinationURL!
                                
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
                                
                                do {
                                    try FileManager.default.removeItem(at: response.destinationURL!)
                                } catch {}
                                do {
                                    try FileManager.default.removeItem(at: response.temporaryURL!)
                                } catch {}
                                
                                
                                onSuccess?()
                            } catch let error as NSError {
                                errorFunc?(OCError(message:error.localizedDescription))
                            }
                            
                            
                        }
                        
                        
                        
                        
                        
                    }
                }
                
            })
    }
    
    
    static func getThreshold() -> Int {
        
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let mainLangURL = NSURL.init(fileURLWithPath: documentsPath).appendingPathComponent("ocsettings", isDirectory: true)
        
        let settingsURL = mainLangURL?.appendingPathComponent("settings", isDirectory: false)
        
        
        if ( (try? settingsURL!.checkResourceIsReachable()) ?? false) {
            
            
            do {
                let data = try Data(contentsOf: settingsURL!, options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? [String: AnyObject] {
                    return jsonResult["threshold"] as! Int
                }else{
                    return 5
                }
            } catch {
                return 5
            }
            
            
        }else{
            return 100
        }
        
    }
    
    static func getPatterns() -> [String] {
        let result = [String]()
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let mainLangURL = NSURL.init(fileURLWithPath: documentsPath).appendingPathComponent("ocsettings", isDirectory: true)
        
        let settingsURL = mainLangURL?.appendingPathComponent("patterns", isDirectory: false)
        
        
        if ( (try? settingsURL!.checkResourceIsReachable()) ?? false) {
            
            
            do {
                let data = try String(contentsOf: settingsURL!, encoding: String.Encoding.utf8)
                return data.components(separatedBy: "\r\n")
            } catch {
                return result
            }
            
            
        }else{
            return result
        }
        
    }
    
    
    static func initSettings(onSuccess successFunc: (() -> Void)? = nil, onError errorFunc: ((_ error: OCError) -> Void)? = nil){
        
        
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let mainLangURL = NSURL.init(fileURLWithPath: documentsPath).appendingPathComponent("ocsettings", isDirectory: true)
        
        let settingsURL = mainLangURL?.appendingPathComponent("settings", isDirectory: false)
        let patternsURL = mainLangURL?.appendingPathComponent("patterns", isDirectory: false)
        
        do {
            if !( (try? mainLangURL!.checkResourceIsReachable()) ?? false) {
                try FileManager.default.createDirectory(at: mainLangURL!, withIntermediateDirectories: true, attributes: nil)
            }
            if ( (try? mainLangURL!.checkResourceIsReachable()) ?? false) {
                
                var awsManager = AWSServiceManager.default()
                awsManager?.defaultServiceConfiguration = AwsS3Manager.getSettingsConfiguration()
                
                
                var awmss3 = AWSS3.default()
                //awmss3.configuration = configuration!
                
                let downloadRequest = AWSS3TransferManagerDownloadRequest()
                downloadRequest?.bucket = "ourcart.platform.sdk"
                
                let objectRequest = AWSS3GetObjectRequest()
                objectRequest?.bucket = "ourcart.platform.sdk"
            
                
                //if !( (try? settingsURL!.checkResourceIsReachable()) ?? false) {
                    
                    objectRequest?.key = "settings"
                    
                    awmss3.getObject(objectRequest!).continueWith(
                        block: {
                            (task) -> AnyObject! in
                            
                            if let error = task.error
                            {
                                print("Error: \(error.localizedDescription)")
                            }
                            
                            if let result = task.result
                            {
                                 let output = result as AWSS3GetObjectOutput
                                
                                do {
                                    
                                if ( (try? settingsURL!.checkResourceIsReachable()) ?? false) {
                                    
                                    try FileManager.default.removeItem(at: settingsURL!)
                                }
                            } catch let error as NSError {
                                NSLog("Unable to delete file \(error.debugDescription)")
                            }
                                let fileData = output.body as! Data
                                FileManager.default.createFile(atPath: settingsURL!.path, contents: fileData, attributes: nil)
                                
                            }
                            
                            return nil;
                    })
                    
                    
                //}else{
                    TesseractClient.getThreshold()
                //}
                
                //if !( (try? patternsURL!.checkResourceIsReachable()) ?? false) {
                    
                    objectRequest?.key = "patterns"
                    
                    awmss3.getObject(objectRequest!).continueWith(
                        block: {
                            (task) -> AnyObject! in
                            
                            if let error = task.error
                            {
                                print("Error: \(error.localizedDescription)")
                                errorFunc?(OCError(message: error.localizedDescription))
                            }
                            
                            if let result = task.result
                            {
                                let output = result as AWSS3GetObjectOutput
                                do {
                                    
                                if ( (try? patternsURL!.checkResourceIsReachable()) ?? false) {
                                    
                                    try FileManager.default.removeItem(at: patternsURL!)
                                }
                                } catch let error as NSError {
                                    NSLog("Unable to delete file \(error.debugDescription)")
                                }
                                
                                let fileData = output.body as! Data
                                
                                FileManager.default.createFile(atPath: patternsURL!.path, contents: fileData, attributes: nil)
                                successFunc?()
                            }
                            
                            return nil;
                    })
                    
                    
                //}else{
                    //TesseractClient.getPatterns()
                //}
                
                
               
                
                
            }
            
        } catch let error as NSError {
            NSLog("Unable to delete file \(error.debugDescription)")
        }
        
        
        
    }
    

    
    
    
    
    public func runOCRWithImage(_ image:UIImage, onSuccess successFunc: ((_ text:String?, _ params:[[String:Any]]) -> Void)? = nil, onError errorFunc: ((_ error: OCError) -> Void)? = nil, onProgress progressFunc: ((_ progress: UInt) -> Void)? = nil){
        
        self.onProgress = progressFunc
       
        
        self.params = [String:Any]()
         self.decodedText = nil
        
        self.receipt = image.fixedOrientation()
        
        let tmp = self.receipt!.resizedImage(byMagick: "1280x1280")
        let s = self.receipt?.size
        let s2 = tmp?.size
        
        let result = tmp//detect(self.receipt!)
        
        
        
        
        tesseract?.image = result
        
        
        if(tesseract?.isEngineConfigured)!{
            DispatchQueue.global(qos: .userInitiated).async {
        
                
                
                
                
                
                let start = Date()
                _ = self.tesseract?.recognize()
                let end = Date()
                
                
                
                DispatchQueue.main.async {
                    
                    
                    let myString = self.tesseract?.recognizedText.trim()
                    
                    let regex = try! NSRegularExpression(pattern: "([\n])\\1+", options: NSRegularExpression.Options.caseInsensitive)
                    let range = NSMakeRange(0, (myString?.characters.count)!)
                    let modString = regex.stringByReplacingMatches(in: myString!, options: [], range: range, withTemplate: "\n\n")
                    
                    self.decodedText = modString
                    
                    let html = self.tesseract?.recognizedHOCR(forPageNumber: 0)
                    
                    
                    do{
                        
                        let doc: Document = try SwiftSoup.parse(html!)
                        let els: Elements = try! doc.select(".ocrx_word")
                        
                        
                        var annotationParts = [String:Any]()
                        
                        
                        var annotations = [[String:Any]]()
                        
                        
                        for element: Element in els.array(){
                            
                            
                            var vertices = [[String:Int]]()
                            
                            
                            let attr = try? element.attr("title")
                            let word = try? element.text()
                            
                            if(word != nil && word!.trim().characters.count > 0){
                                
                                if(attr != nil){
                                    
                                    
                                    let arr = attr!.characters.split(separator: ";")
                                    let box = String(arr[0]).characters.split(separator: " ");
                                    
                                    
                                    
                                    if(box.count == 5){
                                        let x1 = Int(String(box[1]))
                                        let y1 = Int(String(box[2]))
                                        let x2 = Int(String(box[3]))
                                        let y2 = Int(String(box[4]))
                                        
                                        
                                        var annotation = [String:Any]()
                                        
                                        annotation["description"] = word!.trim()
                                        
                                        
                                        
                                        var p1 = [String:Int]()
                                        p1["x"] = x1
                                        p1["y"] = y1
                                        vertices.append(p1)
                                        
                                        p1 = [String:Int]()
                                        p1["x"] = x2
                                        p1["y"] = y1
                                        vertices.append(p1)
                                        
                                        p1 = [String:Int]()
                                        p1["x"] = x2
                                        p1["y"] = y2
                                        vertices.append(p1)
                                        
                                        p1 = [String:Int]()
                                        p1["x"] = x1
                                        p1["y"] = y2
                                        vertices.append(p1)
                                        
                                        annotation["vertices"] = vertices
                                        
                                        annotations.append(annotation)
                                        
                                    }
                                    
                                    
                                    
                                    
                                }
                                
                                
                                
                            }
                            
                            
                            
                        }
                        
                        annotationParts["annotations"] = annotations
                        
                        var anp = [[String:Any]]()
                        anp.append(annotationParts)
                        
                        
                        self.params["annotationParts"] = anp

                    
                        _ = round((end.timeIntervalSince1970 - start.timeIntervalSince1970)*100)/100.0
                        
                    
                    
                    
                    
                        if(successFunc != nil){
                            successFunc!(self.decodedText, annotations)
                        }
                    
                    
                    
                    }catch Exception.Error( _, let message){
                        if(errorFunc != nil){
                            errorFunc!(OCError(message: message))
                        }
                    }catch{
                        if(errorFunc != nil){
                            errorFunc!(OCError(message: "Error"))
                        }
                    }
                    
                    
                    
                    
                    
                    
                }
            }
        }else{
            if(errorFunc != nil){
                errorFunc!(OCError(message: "Tesseract not initialized"))
            }
        }
        
        
    }
    
    
    
    
    public func detect(_ srcImage:UIImage) -> UIImage{
        
        var minX:CGFloat? = nil
        var maxX:CGFloat? = nil
        var minY:CGFloat? = nil
        var maxY:CGFloat? = nil
        
        
        
        let detector = CIDetector(ofType: CIDetectorTypeText,
                                  context: nil,
                                  options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])!
        
        var imageBounds:CGRect?
        
        
        guard let cgimage = srcImage.cgImage else {fatalError()}
        let image = CIImage(cgImage: cgimage)
        
        let options = [CIDetectorReturnSubFeatures: true]
        guard let features = detector.features(in: image, options: options) as? [CITextFeature] else {fatalError()}
        
        let scaleX = CGFloat(1.0)
        let scaleY = CGFloat(1.0)
        
        for feature in features {
           
            guard let subFeatures = feature.subFeatures as? [CITextFeature] else {fatalError()}
            for _ in subFeatures {
                //subFeature.drawRectOnView(imageView, color: UIColor.yellow.withAlphaComponent(0.8), borderWidth: 1.0, scaleX: scaleX, scaleY:scaleY)
            }
            
            if(minX == nil){
                minX = min(feature.topLeft.x, feature.bottomRight.x)
            }else{
                minX = min(minX!, min(feature.topLeft.x, feature.bottomRight.x))
            }
            
            if(maxX == nil){
                maxX = max(feature.topLeft.x, feature.bottomRight.x)
            }else{
                maxX = max(maxX!, max(feature.topLeft.x, feature.bottomRight.x))
            }
            
            if(minY == nil){
                minY = min(feature.topLeft.y, feature.bottomRight.y)
            }else{
                minY = min(minY!, min(feature.topLeft.y, feature.bottomRight.y))
            }
            
            if(maxY == nil){
                maxY = max(feature.topLeft.y, feature.bottomRight.y)
            }else{
                maxY = max(maxY!, max(feature.topLeft.y, feature.bottomRight.y))
            }
            
            let minx = min(feature.topLeft.x, feature.bottomRight.x)
            let miny = min(feature.topLeft.y, feature.bottomRight.y)
            let maxx = max(feature.topLeft.x, feature.bottomRight.x)
            let maxy = max(feature.topLeft.y, feature.bottomRight.y)
            
            let tmpBound = CGRect(x: minx, y: maxy, width: abs(maxx-minx), height: abs(maxy-miny))
            
            
            _ = CGRect(
                x: max(0,tmpBound.origin.x-10/scaleX),
                y:  max(0,(srcImage.size.height - tmpBound.origin.y)-10/scaleY),
                width: min(srcImage.size.width,tmpBound.size.width+20/scaleX),
                height: min(srcImage.size.height,tmpBound.size.height+20/scaleY))
        }
        
        if(minX  == nil || minY == nil){
            
            let tmp = srcImage.resizedImage(byMagick: "800x800")
            let s = tmp?.size
            return tmp!
            
            
        }else{
            
            imageBounds = CGRect(x: minX!, y: maxY!, width: abs(maxX!-minX!), height: abs(maxY!-minY!))
            
            
            //drawRectOnView(rect: imageBounds!, view: imageView, color: UIColor.red.withAlphaComponent(0.8), borderWidth: 2.0, scaleX: scaleX, scaleY:scaleY)
            
            //let imgSize = self.imgReceipt.image!.size
            
            let rct = CGRect(
                x: max(0,imageBounds!.origin.x-10/scaleX),
                y:  max(0,(srcImage.size.height - imageBounds!.origin.y)-10/scaleY),
                width: min(srcImage.size.width,imageBounds!.size.width+20/scaleX),
                height: min(srcImage.size.height,imageBounds!.size.height+20/scaleY))
            
            
            
            
            
            
            
            
            let selectedImage = srcImage.cropMe(rect: rct).resizedImage(byMagick: "800x800")
            
           return selectedImage!
            
        }
    }
    
    
    public func progressImageRecognition(for tesseract: G8Tesseract!) {
        DispatchQueue.main.async {
            
            if(self.onProgress != nil){
                self.onProgress?(tesseract.progress)
            }
        }
    }
    
    public func shouldCancelImageRecognition(for tesseract: G8Tesseract!) -> Bool {
        return false
    }
    
}





private extension UIImage{
    
    
    func cropMe(rect:CGRect) -> UIImage{
        
        
        let origin = CGPoint(x:-rect.origin.x, y:-rect.origin.y);
        
        var img = UIImage();
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, self.scale);
        self.draw(at: origin)
        img = UIGraphicsGetImageFromCurrentImageContext()!;
        UIGraphicsEndImageContext();
        
        return img;
    }
    
        
}



