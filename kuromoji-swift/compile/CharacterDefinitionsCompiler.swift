//
//  CharacterDefinitionsCompiler.swift
//  kuromoji-swift
//
//  Created by Jean-Luc Dagon on 17/11/2016.
//  Copyright © 2016 Cocoapps. All rights reserved.
//

import Foundation


public class CharacterDefinitionsCompiler: Compiler {
    
    private var categoryDefinitions = [String: [Int]]()
    public var codePointCategories = [Set<String>?]()
    private let outputStream: OutputStream
    
    init(_ output: OutputStream) {
        outputStream = output;
        for _ in 0..<65536 {
            codePointCategories.append(nil)
        }
    }
    
    public func readCharacterDefinition(at filePath: String, encoding: String.Encoding) {

        guard let reader = BufferedStringReader(filePath, encoding: encoding) else {
            return
        }
        
        for line in reader {
            let cleanedLine = line.replace("\\s*#.*", with: "").trimmingCharacters(in: CharacterSet.whitespaces)
            if cleanedLine.characters.count == 0 {
                continue
            }
            
            if isCategoryEntry(cleanedLine) {
                parseCategory(cleanedLine)
            } else {
                parseMapping(cleanedLine)
            }
        }
    }
    
    private func parseCategory(_ line: String) {
        
        let values = line.separatedBySpaces()
        let classname = values[0]
        let invoke = Int(values[1])!
        let group = Int(values[2])!
        let length = Int(values[3])!
        
        assert(!categoryDefinitions.keys.contains(classname))
        
        categoryDefinitions[classname] = [invoke, group, length]
    }
    
    private func parseMapping(_ line: String) {
     
        let values = line.separatedBySpaces()
        assert(values.count >= 2)
        
        let codePointString = values[0]
        let categories = getCategories(values)
        
        if codePointString.contains("..") {
            let codePoints = codePointString.components(separatedBy: "..")
            let lowerCodePoint = Int(codePoints[0].scanHexInt32()!)
            let upperCodePoint = Int(codePoints[1].scanHexInt32()!)
            for i in lowerCodePoint...upperCodePoint {
                addMapping(i, categories)
            }
        } else {
            let codepoint = Int(codePointString.scanHexInt32()!)
            addMapping(codepoint, categories)
        }
    }
    
    private func addMapping(_ codepoint: Int, _ categories: [String]) {
        for category in categories {
            addMapping(codepoint, category)
        }
    }
    
    private func addMapping(_ codepoint: Int, _ category: String) {
        
        var categories = codePointCategories[codepoint]
        if categories == nil {
            categories = Set<String>()
        }
        categories!.insert(category)
        codePointCategories[codepoint] = categories!
    }
    
    private func getCategories(_ values: [String]) -> [String] {
        return [String](values[1..<values.count])
    }
 
    private func isCategoryEntry(_ line: String) -> Bool {
        return !line.hasPrefix("0x");
    }
 
    public func makeCharacterCategoryMap() -> [String: Int] {
        var classMapping = [String: Int]()
        
        for (idx, category) in categoryDefinitions.keys.sorted().enumerated() {
            classMapping[category] = idx
        }
        return classMapping
    }
    
    private func makeCharacterDefinitions() -> [[Int]] {
        let categoryMap = makeCharacterCategoryMap();
        var array = [[Int]](repeating: [], count: categoryMap.count)
        
        for category in categoryDefinitions.keys.sorted() {
            let values = categoryDefinitions[category]!
            assert(values.count == 3)
            let index = categoryMap[category]!
            array[index] = values
        }
        return array
    }
    
    private func makeCharacterMappings() -> [[Int]?] {
        let categoryMap = makeCharacterCategoryMap();
        let size = codePointCategories.count
        var array = [[Int]?](repeating: nil, count: size)
        
        for i in 0..<size {
            let categories = codePointCategories[i]
            if categories != nil {
                let innerSize = categories!.count
                var inner = [Int](repeating: 0, count: innerSize)
                
                for (idx, category) in categories!.sorted().enumerated() {
                    inner[idx] = categoryMap[category]!
                }
                array[i] = inner
            }
            
        }
        return array
    }
    
    private func makeCharacterCategorySymbols() -> [String] {
        let categoryMap = makeCharacterCategoryMap();
        var inverted = [Int: String]()
        
        for (key, value) in categoryMap {
            inverted[value] = key
        }
        var categories = [String?](repeating:nil, count: inverted.count)
        for (index, value) in inverted {
            categories[index] = value
        }
        return categories.flatMap { $0 };
    }
    
    func compile() {
        outputStream.open()
        IntegerArrayIO.writeSparseArray2D(outputStream, array: makeCharacterDefinitions())
        IntegerArrayIO.writeSparseArray2D(outputStream, array: makeCharacterMappings())
        StringArrayIO.writeArray(outputStream, array: makeCharacterCategorySymbols())
        outputStream.close();
    }
}
