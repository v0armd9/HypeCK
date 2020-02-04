//
//  Hype.swift
//  HypeCK
//
//  Created by Marcus Armstrong on 2/4/20.
//  Copyright © 2020 Marcus Armstrong. All rights reserved.
//

import Foundation
import CloudKit

struct HypeStrings {
    fileprivate static let recordTypeKey = "Hype"
    fileprivate static let bodyKey = "body"
    fileprivate static let timestampKey = "timestamp"
}

class Hype {
    
    var body: String
    var timestamp: Date
    
    init(body: String, timestamp: Date = Date()) {
        self.body = body
        self.timestamp = timestamp
    }
}

extension Hype {
    
    convenience init?(ckRecord: CKRecord) {
        
        guard let body = ckRecord[HypeStrings.bodyKey] as? String,
            let timestamp = ckRecord[HypeStrings.timestampKey] as? Date
            else {return nil}
        
        self.init(body: body, timestamp: timestamp)
    }
}

extension CKRecord {
    
    convenience init(hype: Hype) {
        self.init(recordType: HypeStrings.recordTypeKey)
        
        self.setValuesForKeys([
            HypeStrings.bodyKey : hype.body,
            HypeStrings.timestampKey : hype.timestamp
        ])
        //        self.setValue(hype.body, forKey: HypeStrings.bodyKey)
        //        self.setValue(hype.timestamp, forKey: HypeStrings.timestampKey)
    }
}
