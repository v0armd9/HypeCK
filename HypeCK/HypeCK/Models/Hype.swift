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
    static let recordTypeKey = "Hype"
    fileprivate static let bodyKey = "body"
    fileprivate static let timestampKey = "timestamp"
}

class Hype {
    
    var body: String
    var timestamp: Date
    var recordID: CKRecord.ID
    
    init(body: String, timestamp: Date = Date(), recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.body = body
        self.timestamp = timestamp
        self.recordID = recordID
    }
}

extension Hype {
    
    convenience init?(ckRecord: CKRecord) {
        
        guard let body = ckRecord[HypeStrings.bodyKey] as? String,
            let timestamp = ckRecord[HypeStrings.timestampKey] as? Date
            else {return nil}
        
        self.init(body: body, timestamp: timestamp, recordID: ckRecord.recordID)
    }
}

extension CKRecord {
    
    convenience init(hype: Hype) {
        self.init(recordType: HypeStrings.recordTypeKey, recordID: hype.recordID)
        
        self.setValuesForKeys([
            HypeStrings.bodyKey : hype.body,
            HypeStrings.timestampKey : hype.timestamp
        ])
        //        self.setValue(hype.body, forKey: HypeStrings.bodyKey)
        //        self.setValue(hype.timestamp, forKey: HypeStrings.timestampKey)
    }
}

extension Hype: Equatable {
    static func == (lhs: Hype, rhs: Hype) -> Bool {
        return lhs.recordID == rhs.recordID
    }
}
