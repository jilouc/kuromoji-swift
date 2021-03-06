//
//  CharacterDefinitionsCompilerTests.swift
//  kuromoji-swift
//
//  Created by Jean-Luc Dagon on 27/11/2016.
//  Copyright © 2016 Cocoapps. All rights reserved.
//

import XCTest

class CharacterDefinitionsCompilerTests: XCTestCase {

    var categoryIdMap: [Int: String]!
    var characterDefinition: CharacterDefinitions!
    
    override func setUp() {
        super.setUp()
        
        let bundle = Bundle.init(for: type(of: self))
        let outputStream = OutputStream(toMemory: ())
        
        let compiler = CharacterDefinitionsCompiler(outputStream)
        compiler.readCharacterDefinition(at: bundle.path(forResource: "char", ofType: "def")!, encoding: .japaneseEUC)
        
        categoryIdMap = _invert(compiler.makeCharacterCategoryMap())
        compiler.compile()

        let charDefInput = InputStream(data: outputStream.property(forKey: .dataWrittenToMemoryStreamKey) as! Data)
        charDefInput.open()
        defer {
            charDefInput.close()
        }
        let definitions = IntegerArrayIO.readSparseArray2D(charDefInput)
        let mappings = IntegerArrayIO.readSparseArray2D(charDefInput)
        let symbols = StringArrayIO.readArray(charDefInput)
        characterDefinition = CharacterDefinitions(categoryDefinitions: definitions, codepointMappings: mappings, categorySymbols: symbols)
        
    }
    
    override func tearDown() {
        categoryIdMap = nil
        characterDefinition = nil
        super.tearDown()
    }

    func testCharacterCategories() {
        assertCharacterCategories(characterDefinition, "\u{0000}", ["DEFAULT"])
        assertCharacterCategories(characterDefinition, "〇", ["SYMBOL", "KANJI", "KANJINUMERIC"])
        assertCharacterCategories(characterDefinition, " ", ["SPACE"])
        assertCharacterCategories(characterDefinition, "。", ["SYMBOL"])
        assertCharacterCategories(characterDefinition, "A", ["ALPHA"])
        assertCharacterCategories(characterDefinition, "Ａ", ["ALPHA"])
    }
    
    func testAddCategoryDefinitions() {
        assertCharacterCategories(characterDefinition, "・", ["KATAKANA"])
        characterDefinition.setCategories(Int(("・" as Character).unicodeScalarCodePoint), names: ["SYMBOL", "KATAKANA"])
        assertCharacterCategories(characterDefinition, "・", ["KATAKANA", "SYMBOL"])
        assertCharacterCategories(characterDefinition, "・", ["SYMBOL", "KATAKANA"])
    }

    func assertCharacterCategories(_ characterDefinition: CharacterDefinitions, _ c: Character, _ categories: [String]?) {
        guard let categoryIds = characterDefinition.lookupCategory(Int(c.unicodeScalarCodePoint)) else {
            XCTAssertNil(categories)
            return
        }
        guard let categories = categories else {
            XCTAssert(false)
            return
        }
        XCTAssertEqual(categories.count, categoryIds.count)
        for categoryId in categoryIds {
            let category = categoryIdMap[categoryId]!
            XCTAssertTrue(categories.contains(category))
        }
    }
    
    func _invert(_ dict: [String: Int]) -> [Int: String] {
        var inverted = [Int: String]()
        dict.forEach { item in
            inverted[item.value] = item.key
        }
        return inverted
    }

}
