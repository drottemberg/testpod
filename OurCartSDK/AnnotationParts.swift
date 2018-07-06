//
//  AnnotationParts.swift
//  snapstar
//
//  Created by Nur  on 26/04/2017.
//  Copyright © 2017 SnapStar. All rights reserved.
//

import UIKit

class AnnotationParts : NSObject {
    
    var annotationParts : Array  = Array<Annotations>()
    var fileName        : String = ""
    
    func add(annotations: Annotations) {
        annotationParts.append(annotations)
    }
    
    func setFileName(fileName: String) {
        self.fileName = fileName
    }
    
    override func asDictionary() -> [String : Any] {
        var dictionary = Dictionary<String, Any>()
        
        dictionary["annotationParts"] = [self.annotationParts[0].asDictionary()]
//        dictionary["fileName"]        = self.fileName
        
        return dictionary
    }
}

extension Array {
    func asDictionary() -> Dictionary<String, Any> {
        var dictionary = Dictionary<String, Any>()
        for i in 0 ..< self.count {
            dictionary["\(i)"] = self[i]
        }
        return dictionary
    }
}
