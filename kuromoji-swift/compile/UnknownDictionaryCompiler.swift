//
//  UnknownDictionaryCompiler.swift
//  kuromoji-swift
//
//  Created by Jean-Luc Dagon on 20/11/2016.
//  Copyright © 2016 Cocoapps. All rights reserved.
//

import Foundation

class UnknownDictionaryCompiler: Compiler {
    
    private let outputStream: OutputStream
    private let categoryMap: [String: Int]
    private var dictionaryEntries = [GenericDictionaryEntry]()
    
    init(categoryMap: [String: Int], outputStream: OutputStream) {
        self.categoryMap = categoryMap
        self.outputStream = outputStream
    }
    
    public func readUnknownDefinitions(at filePath: String, encoding: String.Encoding) {
        
        guard let reader = BufferedReader(filePath, encoding: encoding) else {
            return
        }
        let entries = reader.flatMap { line in
            return GenericDictionaryEntry.fromCSV(CSVParser(line).parse().first!)
        }
        dictionaryEntries.append(contentsOf: entries)
    }
    
    public func makeCosts() -> [[Int]] {
        return dictionaryEntries.map { entry in
            [Int(entry.leftId), Int(entry.rightId), Int(entry.wordCost)]
        }
    }
    
    public func makeFeatures() -> [[String]] {
        return dictionaryEntries.map { entry in
            entry.partOfSpeechFeatures + entry.otherFeatures
        }
    }
    
    public func makeCategoryReferences() -> [[Int]] {
        var entries = [[Int]?](repeatElement(nil, count: categoryMap.count))
        for category in categoryMap.keys.sorted() {
            let categoryId = categoryMap[category]!
            entries[categoryId] = getEntryIndices(category)
        }
        let finalEntries = entries.flatMap { $0 }
        assert(finalEntries.count == categoryMap.count)
        return finalEntries
    }
    
    public func getEntryIndices(_ surface: String) -> [Int] {
        return dictionaryEntries.enumerated().flatMap { entry in
            if entry.element.surface == surface {
                return entry.offset
            }
            return nil
        }
    }
    
    func compile() {
        outputStream.open()
        IntegerArrayIO.writeArray2D(outputStream, array: makeCosts())
        IntegerArrayIO.writeArray2D(outputStream, array: makeCategoryReferences())
        StringArrayIO.writeArray2D(outputStream, array: makeFeatures())
        outputStream.close()
    }
    
}
