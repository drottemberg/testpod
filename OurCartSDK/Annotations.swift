//
//  Annotations.swift
//  snapstar
//
//  Created by Nur  on 26/04/2017.
//  Copyright © 2017 SnapStar. All rights reserved.
//

import UIKit

class Annotations : NSObject {

    var annotations : Array = Array<Annotation>()

    func add(annotation: Annotation) {
        annotations.append(annotation)
    }
    
    func getAnnotations() -> Array<Annotation> {
        return self.annotations
    }
    
    override func asDictionary() -> [String : Any] {
        var dictionary = Dictionary<String, Any>()
        
        var array = Array<Dictionary<String, Any>>()
        
        for annotation in annotations {
            array.append(annotation.asDictionary())
        }
        
        dictionary["annotations"] = array
        
        return dictionary
    }
}
