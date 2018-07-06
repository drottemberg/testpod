//
//  LocalSettingsManager.swift
//  snapstar
//
//  Created by Nur  on 22/11/2016.
//  Copyright © 2016 SnapStar. All rights reserved.
//

import UIKit

/**
 * in charge of CRUDing to the user's settings - info.plist's and user defaults
 * @author Nur
 */
class LocalSettingsManager {

    /**
     * lazy singleton
     * @author Nur
     */
    static  let sharedInstance = LocalSettingsManager()
    private let infoPlist      = OCUtil.getSDKBundle().infoDictionary
    
    func updateEulaFromServer() {
        ApiManager.sharedInstance.sendRequest(verb: .get, urlPathKey: UrlPaths.URL_PATH_SETTINGS_EULA.rawValue, parameters: [:], urlGetParameter: "", completion:{(jsonDictionary: Dictionary<String, Any>) in
            if jsonDictionary[keys.code.rawValue] == nil {
                self.saveToDefaults(object: jsonDictionary.removeNulls(), key: defaults.EULA_SETTINGS.rawValue)
            }
        })
    }
    
    func updateSettingsFromServer(completionExternal: @escaping () -> ()) {
        ApiManager.sharedInstance.sendRequest(verb: .get, urlPathKey: UrlPaths.URL_PATH_SETTINGS_FROM_SERVER.rawValue, parameters: [:], urlGetParameter: "", completion: {(jsonDictionary: Dictionary<String, Any>) in
            if jsonDictionary[keys.code.rawValue] == nil {
                self.saveToDefaults(object: jsonDictionary.removeNulls(), key: defaults.GENERAL_SERVER_SETTINGS.rawValue)
                completionExternal()
            }
        })
    }
    
    
    
    /**
     * get a setting from the dev/prod info.plist by name (root in hierarchy)
     * @author Nur
     */
    func getSetting(name: String) -> String? {
        return (infoPlist![name] as! String?)!
    }
    
    func saveToDefaults(object: Any?, key: String) {
        UserDefaults.standard.set(object!, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    func loadFromDefaults(key: String) -> Any? {
        return UserDefaults.standard.object(forKey: key)
    }
    
    func incrementLaunchesCounter() {
        if self.loadFromDefaults(key: defaults.APP_LAUNCHES_COUNTER.rawValue) != nil  {
            let currentLaunches = self.loadFromDefaults(key: defaults.APP_LAUNCHES_COUNTER.rawValue) as! Int
            self.saveToDefaults(object: currentLaunches + 1, key: defaults.APP_LAUNCHES_COUNTER.rawValue)
        } else {
            self.saveToDefaults(object: 1, key: defaults.APP_LAUNCHES_COUNTER.rawValue)
        }
    }
    
    func getDeviceIDFA() -> String {
        return UIDevice.current.identifierForVendor!.uuidString
    }
}

extension Dictionary {
    func removeNulls() -> Dictionary {
        var dictionaryCopy = self
        let keysToRemove = self.keys.filter { self[$0]! is NSNull }
        for key in keysToRemove {
            dictionaryCopy.removeValue(forKey: key)
        }
        return dictionaryCopy
    }
}
