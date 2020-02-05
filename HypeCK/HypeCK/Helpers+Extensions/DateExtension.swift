//
//  DateExtension.swift
//  HypeCK
//
//  Created by Marcus Armstrong on 2/4/20.
//  Copyright © 2020 Marcus Armstrong. All rights reserved.
//

import Foundation

extension Date {
    
    func formatToString() -> String {
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        
        return formatter.string(from: self)
    }
}
