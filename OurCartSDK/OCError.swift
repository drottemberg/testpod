//
//  OCError.swift
//  OurCartSDK
//
//  Created by Damien Rottemberg on 9/27/17.
//  Copyright © 2017 OurCart. All rights reserved.
//

import UIKit

public class OCError: Error {

    public var code = 500
    public var message : String?
    
    
    init(message:String, code:Int = 500) {
        self.code = code
        self.message = message
    }
    
}
