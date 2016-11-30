//
//  WordIdMapCompilerTests.swift
//  kuromoji-swift
//
//  Created by Jean-Luc Dagon on 30/11/2016.
//  Copyright © 2016 Cocoapps. All rights reserved.
//

import XCTest
import Foundation

class WordIdMapCompilerTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    public func testCompiler() {
        let compiler = WordIdMapCompiler()
        compiler.addMapping(sourceId: 3, wordId: 1)
        compiler.addMapping(sourceId: 3, wordId: 2)
        compiler.addMapping(sourceId: 3, wordId: 3)
        compiler.addMapping(sourceId: 10, wordId: 0)
    
        let wordIdOutput = OutputStream(toMemory: ())
        compiler.write(wordIdOutput)
    
        let wordIdInput = InputStream(data: wordIdOutput.property(forKey: .dataWrittenToMemoryStreamKey) as! Data)
        wordIdInput.open()
        defer {
            wordIdInput.close()
        }
        let wordIds = WordIdMap(wordIdInput)
    
        XCTAssertEqual([1, 2, 3], wordIds.lookUp(3))
        XCTAssertEqual([0], wordIds.lookUp(10))
        XCTAssertEqual([], wordIds.lookUp(1))
    }
    
}
