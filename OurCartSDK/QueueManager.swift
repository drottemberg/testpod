//
//  QueueManager.swift
//  OurCartSDK
//
//  Created by Damien Rottemberg on 10/2/17.
//  Copyright © 2017 OurCart. All rights reserved.
//

import UIKit

class QueueManager: NSObject {

    
    static let sharedInstance = QueueManager()
   
    public let group:DispatchGroup!
    public  let queue:DispatchQueue!
    public  let dispathWorkItems = [DispatchWorkItem]()
    
    override init() {
        self.group = DispatchGroup()
        self.queue = DispatchQueue.init(label: "OurCart", qos: .userInitiated, attributes: .concurrent, autoreleaseFrequency: .inherit, target:nil)
    }
    
    
    func async(item:DispatchWorkItem){
        
         queue.async(group: group, execute: item)
         
        
    }
    
    
    func notify(_ block:(() -> Void)? = nil){
        
        group.notify(queue: queue){
            
            block?()
            
        }
    }
    
}
