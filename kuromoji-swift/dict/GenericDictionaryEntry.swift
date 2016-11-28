//
//  GenericDictionaryEntry.swift
//  kuromoji-swift
//
//  Created by Jean-Luc Dagon on 20/11/2016.
//  Copyright © 2016 Cocoapps. All rights reserved.
//

import Foundation

class GenericDictionaryEntry: DictionaryEntryBase {
    
    internal let partOfSpeechFeatures: [String]
    internal let otherFeatures: [String]
    
    init(_ builder: Builder) {
        partOfSpeechFeatures = builder.partOfSpeechFeatures
        otherFeatures = builder.otherFeatures
        super.init(surface: builder.surface, leftId: builder.leftId, rightId: builder.rightId, wordCost: builder.wordCost)
    }
    
    public struct Builder {
        internal var surface: String = ""
        internal var leftId: Int16 = 0
        internal var rightId: Int16 = 0
        internal var wordCost: Int16 = 0
        internal var partOfSpeechFeatures: [String] = []
        internal var otherFeatures: [String] = []
        
        public func build() -> GenericDictionaryEntry {
            return GenericDictionaryEntry(self);
        }
    }
    
    public static func fromCSV(_ record: [String]) -> GenericDictionaryEntry {
        let surface = record[0]
        let leftId = Int16(record[1])!
        let rightId = Int16(record[2])!
        let wordCost = Int16(record[3])!
        let pos = [String](record[4..<10])
        let features = [String](record[10..<record.count])
        
        let builder = Builder(surface: surface, leftId: leftId, rightId: rightId, wordCost: wordCost, partOfSpeechFeatures: pos, otherFeatures: features)
        return builder.build()
    }
}
