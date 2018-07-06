//
//  ApiManager.swift
//  snapstar
//
//  Created by Nur  on 22/11/2016.
//  Copyright © 2016 SnapStar. All rights reserved.
//

import Alamofire
import SystemConfiguration

/**
 * in charge of sending API requests, receiving responses and channeling them back to the appropriate object
 * - Author: Nur
 */
class ApiManager {
    
    static let sharedInstance = ApiManager()
    
    private let baseUrl = LocalSettingsManager.sharedInstance.getSetting(name: UrlPaths.BASE_URL.rawValue)!
    private var headers: HTTPHeaders = [
        "Accept"      : "application/json",
        "x-api-ver"   : "5",
        "User-Agent"  : "Snapstar-ios/6; \(UIWebView().stringByEvaluatingJavaScript(from: "navigator.userAgent")!)", // TODO: incerement version number every release
        "X-Device-Id" : (UIDevice.current.identifierForVendor?.uuidString)!
    ]
    
    func sendRequest(verb: HTTPMethod, urlPathKey: String, parameters: [String:Any], urlGetParameter: String, completion: @escaping (Dictionary<String, Any>) -> ()) {
        if !isConnectedToNetwork() {
            showNoConnectionDialog()
            return
        }
        
        let controllerUrl = LocalSettingsManager.sharedInstance.getSetting(name: urlPathKey)!
        let builtUrl      = baseUrl + controllerUrl + urlGetParameter
        
//        if UserManager.sharedInstance.getUserObject() != nil {
            headers["x-api-key"] = OCConstant.OC_API_KEY_V1//b930dcf3-65dd-43ff-9430-c5707d75e341" // TODO: switch to prefered api key
//        }
        
        if verb == .get {
            Alamofire.request(builtUrl, headers: headers).responseJSON { (response) in
                if let json = response.result.value {
                    let jsonDictionary = json as! Dictionary<String, Any>
                    if jsonDictionary[keys.code.rawValue] != nil && jsonDictionary[keys.code.rawValue] as! Int == 41000 {
                        self.showRequestFailedDialog()
                    } else {
                        completion(jsonDictionary)
                    }
                }
            }
        } else {
            Alamofire.request(builtUrl, method: verb, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
                if let json = response.result.value {
                    let jsonDictionary = json as! Dictionary<String, Any>
                    if jsonDictionary[keys.code.rawValue] != nil && jsonDictionary[keys.code.rawValue] as! Int == 41000 {
                        self.showRequestFailedDialog()
                    } else {
                        completion(jsonDictionary)
                    }
                }
            }
        }
    }

    func validateSimpleReceiptRequest(text: String, onSuccess: (() -> Void)? = nil,onError errorFunc: ((_ error: OCError) -> Void)? = nil) {
        
        let t = text
        
        if( TesseractClient.getPatterns() == nil){
            errorFunc?(OCError(message: "Invalid Patterns"))
            
            
        }else{
                let patterns = TesseractClient.getPatterns()
                var m = 0
                for s in patterns {
                    do {
                    let regex = try NSRegularExpression(pattern: s, options: [])
                    var nsString = t as NSString
                    
                       var results2 = regex.matches(in: t, options: [], range: NSMakeRange(0, nsString.length))
                   
                        
                        if results2.count > 0 {
                            var isMatch = false
                            for ns in results2 {
                                let nr = ns.numberOfRanges
                                
                                
                                let lastRangeIndex = nr - 1
                                let capturedGroupIndex = ns.rangeAt(lastRangeIndex)
                                if(capturedGroupIndex.length > 0){
                                    let matchedString = nsString.substring(with: capturedGroupIndex)
                                    
                                    
                                    if(matchedString.trim().count > 0 ){
                                        isMatch = true
                                        break
                                    }
                                }
                                
                                
                                
                                
                                
                            }
                            if(isMatch){
                                m = m + 1
                            }
                            
                        }
                        
                        
                       
                    
                    }catch let error {
                        
                        
                    }
                }
                
                if(m >= TesseractClient.getThreshold()){
                    
                    onSuccess?()
                }else{
                    
                    errorFunc?(OCError(message: "Invalid Receipt"))
                    
                    
                }
            
        }
        
        
        
        
        
    }
    
    func validateReceiptRequest(parameters: [String:Any], onSuccess: ((_ receipt:OCReceipt?) -> Void)? = nil,onError errorFunc: ((_ error: OCError) -> Void)? = nil) {
        
        let controllerUrl = LocalSettingsManager.sharedInstance.getSetting(name: UrlPaths.URL_PATH_SEND_GOOGLE_VISION_JSON_FOR_VALIDATION.rawValue)!
        let builtUrl      = baseUrl + controllerUrl
        
        headers["x-api-key"] = OCConstant.OC_API_KEY_V1
        
        Alamofire.request(builtUrl, method: HTTPMethod.post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            
            let json = response.result.value as? [String: Any]
            
            if(json != nil){
                let valid = json!["valid"] as! Bool
                
                var snapshotsHeaders = json!["snapshotHeaders"]
                
                if(snapshotsHeaders is NSNull){
                    errorFunc?(OCError(message: "Invalid Receipt"))
                    return;
                }
                
                if(valid){
                    
                    let r = OCReceipt(data: snapshotsHeaders as! [String : Any])
                    onSuccess?(r)
                    
                }else{
                    
                    errorFunc?(OCError(message: "Invalid Receipt"))
                    
                }
            }else{
                
                errorFunc?(OCError(message: "Invalid Receipt"))
            }
            
        }
        
    }
    
    
    func uploadReceiptPartsRequest(parameters: [String:Any], onSuccess: ((String) -> Void)? = nil,onError errorFunc: ((_ error: OCError) -> Void)? = nil) {
        
        let controllerUrl = LocalSettingsManager.sharedInstance.getSetting(name: UrlPaths.URL_PATH_UPLOADED_RECEIPT_TO_S3.rawValue)!
        let builtUrl      = LocalSettingsManager.sharedInstance.getSetting(name: UrlPaths.BASE_URL_DEV.rawValue)! + controllerUrl
        
        headers["x-api-key"] = OCConstant.OC_API_KEY_V2
        
        Alamofire.request(builtUrl, method: HTTPMethod.post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            
            let json = response.result.value as? [String: Any]
            
            if(json != nil){
                
                var rid = json!["rid"]
                
                if(rid is NSNull){
                    errorFunc?(OCError(message: "Upload Failed"))
                    return;
                }else{
                    
                    
                    onSuccess?( rid as! String)
                    
                }
            }else{
                
                errorFunc?(OCError(message: "Upload Failed"))
            }
            
        }
        
    }
    
    
    
    
    
    
    
    private func showNoConnectionDialog() {
//        let appDelegate  = UIApplication.shared.delegate
//        let rootViewController = appDelegate.window!.rootViewController
//        
//        DialogsDisplayManager.sharedInstance.displayDialogWithButtonHandler(title: "Unable to Connect", message: "Please check your internet connection and try again", buttonTitle: "OK", handler: { _ in
//            // do nothing
//        }, viewController: rootViewController!)
    }
    
    private func showRequestFailedDialog() {
//        let appDelegate  = UIApplication.shared.delegate
//        let rootViewController = appDelegate.window!.rootViewController
//        
//        DialogsDisplayManager.sharedInstance.displayDialogWithButtonHandler(title: "Upgrade Version",
//                                                                            message: "We built some new stuff that requires you to upgrade the app in order to use it. Please upgrade the app and come right back!",
//                                                                            buttonTitle: "Upgrade",
//                                                                            handler: { _ in
//                                                                                // open the appstore
//                                                                                if let url = URL(string: "itms-apps://"), UIApplication.shared.canOpenURL(url) {
//                                                                                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
//                                                                                }
//        },
//                                                                            viewController: rootViewController!)
    }
    
    private func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }
    
}
