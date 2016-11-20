//
//  DictionaryEntryBase.swift
//  kuromoji-swift
//
//  Created by Jean-Luc Dagon on 20/11/2016.
//  Copyright © 2016 Cocoapps. All rights reserved.
//

import Foundation

public class DictionaryEntryBase {
    
    internal let surface: String
    internal let leftId: UInt16
    internal let rightId: UInt16
    internal let wordCost: UInt32
    
    init(surface: String, leftId: UInt16, rightId: UInt16, wordCost: UInt32) {
        self.surface = surface
        self.leftId = leftId
        self.rightId = rightId
        self.wordCost = wordCost
    }
    
}
