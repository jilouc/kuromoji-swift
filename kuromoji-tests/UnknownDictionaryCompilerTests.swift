//
//  UnknownDictionaryCompilerTests.swift
//  kuromoji-swift
//
//  Created by Jean-Luc Dagon on 28/11/2016.
//  Copyright © 2016 Cocoapps. All rights reserved.
//

import XCTest

class UnknownDictionaryCompilerTests: XCTestCase {
    
    var categoryIdMap: [Int: String]!
    var unknownDictionary: UnknownDictionary!
    var characterDefinition: CharacterDefinitions!
    
    override func setUp() {
        super.setUp()
        
        let bundle = Bundle.init(for: type(of: self))
        
        let charDefOutput = OutputStream(toMemory: ())
        let charDefCompiler = CharacterDefinitionsCompiler(charDefOutput)
        charDefCompiler.readCharacterDefinition(at: bundle.path(forResource: "char", ofType: "def")!, encoding: .japaneseEUC)
        charDefCompiler.compile()
        
        let categoryIdMap = charDefCompiler.makeCharacterCategoryMap()
        
        let unkDefOutput = OutputStream(toMemory: ())
        let unkDefCompiler = UnknownDictionaryCompiler(categoryMap: categoryIdMap, outputStream: unkDefOutput)
        unkDefCompiler.readUnknownDefinitions(at: bundle.path(forResource: "unk", ofType: "def")!, encoding: .japaneseEUC)
        unkDefCompiler.compile()
        
        let charDefInput = InputStream(data: charDefOutput.property(forKey: .dataWrittenToMemoryStreamKey) as! Data)
        charDefInput.open()
        defer {
            charDefInput.close()
        }
        let definitions = IntegerArrayIO.readSparseArray2D(charDefInput)
        let mappings = IntegerArrayIO.readSparseArray2D(charDefInput)
        let symbols = StringArrayIO.readArray(charDefInput)
        characterDefinition = CharacterDefinitions(categoryDefinitions: definitions, codepointMappings: mappings, categorySymbols: symbols)
        
        let unkDefInput = InputStream(data: unkDefOutput.property(forKey: .dataWrittenToMemoryStreamKey) as! Data)
        unkDefInput.open()
        defer {
            unkDefInput.close()
        }
        
        let costs = IntegerArrayIO.readArray2D(unkDefInput)
        let references = IntegerArrayIO.readArray2D(unkDefInput)
        let features = StringArrayIO.readArray2D(unkDefInput)
        unknownDictionary = UnknownDictionary(characterDefinition: characterDefinition,
                                              entries: references,
                                              costs: costs,
                                              features: features)
        
    }
    
    override func tearDown() {
        unknownDictionary = nil
        super.tearDown()
    }
    
    public func testCostsAndFeatures() {
        let categories = characterDefinition.lookupCategory(Int(("一" as Character).unicodeScalarCodePoint))!
        
        // KANJI & KANJINUMERIC
        XCTAssertEqual(2, categories.count)
        XCTAssertEqual([5, 6], categories)
        
        // KANJI entries
        XCTAssertEqual([2, 3, 4, 5, 6, 7], unknownDictionary.lookupWordIds(categories[0]))
        
        // KANJI feature variety
        XCTAssertEqual(["名詞", "一般", "*", "*", "*", "*", "*"], unknownDictionary.getAllFeatures(2))
        XCTAssertEqual(["名詞", "サ変接続", "*", "*", "*", "*", "*"], unknownDictionary.getAllFeatures(3))
        XCTAssertEqual(["名詞", "固有名詞", "地域", "一般", "*", "*", "*"], unknownDictionary.getAllFeatures(4))
        XCTAssertEqual(["名詞", "固有名詞", "組織", "*", "*", "*", "*"], unknownDictionary.getAllFeatures(5))
        XCTAssertEqual(["名詞", "固有名詞", "人名", "一般", "*", "*", "*"], unknownDictionary.getAllFeatures(6))
        XCTAssertEqual(["名詞", "固有名詞", "人名", "一般", "*", "*", "*"], unknownDictionary.getAllFeatures(6))
        
        // KANJINUMERIC entry
        XCTAssertEqual([29], unknownDictionary.lookupWordIds(categories[1]))
        
        // KANJINUMERIC costs
        XCTAssertEqual(1295, unknownDictionary.getLeftId(29))
        XCTAssertEqual(1295, unknownDictionary.getRightId(29))
        XCTAssertEqual(27473, unknownDictionary.getWordCost(29))
        
        // KANJINUMERIC features
        XCTAssertEqual(["名詞", "数", "*", "*", "*", "*", "*"], unknownDictionary.getAllFeatures(29))
    }
}
