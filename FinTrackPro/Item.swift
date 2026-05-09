//
//  Item.swift
//  FinTrackPro
//
//  Created by Mauricio Argumedo on 8/5/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
