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
    internal let leftId: Int16
    internal let rightId: Int16
    internal let wordCost: Int16
    
    init(surface: String, leftId: Int16, rightId: Int16, wordCost: Int16) {
        self.surface = surface
        self.leftId = leftId
        self.rightId = rightId
        self.wordCost = wordCost
    }
    
}
