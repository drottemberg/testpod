//
//  Annotation.swift
//  snapstar
//
//  Created by Nur  on 26/04/2017.
//  Copyright © 2017 SnapStar. All rights reserved.
//

import UIKit

class Annotation : NSObject {

    var vertices : Array = Array<Dictionary<String, Int>>()
    var word             = "" // not called "description" because it's a ~'keyword'
    
    init(vertices: Array<Dictionary<String, Int>>, word: String) {
        self.vertices = vertices
        self.word = word
    }
    
    override func asDictionary() -> [String : Any] {
        var dictionary = Dictionary<String, Any>()
        dictionary["description"] = self.word
        
        var array = Array<Dictionary<String, Int>>()
        
        for vertex in vertices {
            if (vertex["x"] != nil), (vertex["y"] != nil){
                array.append(["x":vertex["x"]!, "y":vertex["y"]!])
            }
        }
        
        dictionary["vertices"]    = array
        
        return dictionary
    }
}

extension NSObject {
    func asDictionary() -> [String:Any] {
        var dict = [String:Any]()
        let otherSelf = Mirror(reflecting: self)
        for child in otherSelf.children {
            if let key = child.label {
                dict[key] = child.value
            }
        }
        return dict
    }
}
