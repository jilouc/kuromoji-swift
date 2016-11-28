//
//  CharacterDefinitions.swift
//  kuromoji-swift
//
//  Created by Jean-Luc Dagon on 27/11/2016.
//  Copyright © 2016 Cocoapps. All rights reserved.
//

import Foundation

enum CharacterDefinitionsError: Error {
    case categoryNotFound
}

public class CharacterDefinitions {
    
    static let CHARACTER_DEFINITIONS_FILENAME = "characterDefinitions.bin";
    static let INVOKE = 0;
    static let GROUP = 1;
    
    static let DEFAULT_CATEGORY = "DEFAULT";
    static let LENGTH = 2; // Not used as of now
    
    private let categoryDefinitions: [[Int]?]
    private var codepointMappings: [[Int]?]
    private let categorySymbols: [String]
    lazy private var defaultCategory: [Int] = {
        return try! self.lookupCategories([CharacterDefinitions.DEFAULT_CATEGORY])
    }()
    
    init(categoryDefinitions: [[Int]?],
         codepointMappings: [[Int]?],
         categorySymbols: [String])
    {
        self.categoryDefinitions = categoryDefinitions
        self.codepointMappings = codepointMappings
        self.categorySymbols = categorySymbols
    }
    
    convenience init?(resolver: ResourceResolver) {
        guard let charDefInput = resolver.resolve(CharacterDefinitions.CHARACTER_DEFINITIONS_FILENAME) else {
            return nil
        }
        let definitions = IntegerArrayIO.readSparseArray2D(charDefInput)
        let mappings = IntegerArrayIO.readSparseArray2D(charDefInput)
        let symbols = StringArrayIO.readArray(charDefInput)
        self.init(categoryDefinitions: definitions, codepointMappings: mappings, categorySymbols: symbols)
    }
    
    public func lookupCategory(_ c: Int) -> [Int]? {
        if let mappings = codepointMappings[c] {
            return mappings
        }
        return defaultCategory
    }
    
    public func lookupDefinitions(_ category: Int) -> [Int]? {
        return categoryDefinitions[category]
    }
    
    public func setCategories(_ c: Int, names: [String]) {
        codepointMappings[c] = try! lookupCategories(names)
    }
    
    public func lookupCategories(_ names: [String]) throws -> [Int] {
        var categories = [Int]()
        for category in names {
            guard let categoryIndex = categorySymbols.index(where: {
                $0 == category
            }) else {
                throw CharacterDefinitionsError.categoryNotFound
            }
            categories.append(categoryIndex)
        }
        return categories
    }
    
}
