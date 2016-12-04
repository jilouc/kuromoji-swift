//
//  TokenInfoBufferCompilerTests.swift
//  kuromoji-swift
//
//  Created by Jean-Luc Dagon on 30/11/2016.
//  Copyright © 2016 Cocoapps. All rights reserved.
//

import XCTest

class TokenInfoBufferCompilerTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testReadAndWriteFromBuffer() {
        let shorts = [Int16](0..<10)
        
        let buffer = ByteBuffer(size: shorts.count * 2 + 2)
        buffer.put(Int16(shorts.count))
        for s in shorts {
            buffer.put(s)
        }
    
        buffer.position(0)
        
        let count = buffer.getInt16()
        XCTAssertEqual(Int(count), shorts.count)
        
        var readShorts = [Int16]()
        for _ in 0..<10 {
            readShorts.append(buffer.getInt16())
        }
        
        XCTAssertEqual(shorts, readShorts)
    }
    
    func testReadAndLookUpTokenInfo() {
        var tokenInfo = [Int16]()
        var features = [Int]()
        
        let tokenInfos: [Int16] = [1, 2, 3]
        let featureInfos: [Int] = [73, 99]
    
        tokenInfo.append(1)
        tokenInfo.append(2)
        tokenInfo.append(3)
        
        features.append(73)
        features.append(99)
        
        var entry = BufferEntry()
        entry.tokenInfo = tokenInfo
        entry.features = features
        entry.tokenInfos = tokenInfos
        entry.featureInfos = featureInfos
    
        let bufferEntries = [entry]
        
        let tokenInfoOutput = OutputStream(toMemory: ())
        let compiler = TokenInfoBufferCompiler(tokenInfoOutput, entries: bufferEntries)
        compiler.compile()
        
        let tokenInfoInput = InputStream(data: tokenInfoOutput.property(forKey: .dataWrittenToMemoryStreamKey) as! Data)
        tokenInfoInput.open()
        defer {
            tokenInfoInput.close()
        }
        let tokenInfoBuffer = TokenInfoBuffer(tokenInfoInput)
        
        XCTAssertEqual(99, tokenInfoBuffer.lookupFeature(0, 1))
        XCTAssertEqual(73, tokenInfoBuffer.lookupFeature(0, 0))
    }
    
    func testCompleteLookUp() {
        let resultMap = [
            73: "hello",
            42: "今日は",
            99: "素敵な世界"
        ]
        
        let tokenInfo: [Int16] = [1, 2, 3]
        let featureInfo: [Int] = [73, 99]
        
        var entry = BufferEntry()
        entry.tokenInfo = tokenInfo
        entry.features = featureInfo
        
        let bufferEntries = [entry]
        
        let tokenInfoOutput = OutputStream(toMemory: ())
        let compiler = TokenInfoBufferCompiler(tokenInfoOutput, entries: bufferEntries)
        compiler.compile()
        
        let tokenInfoInput = InputStream(data: tokenInfoOutput.property(forKey: .dataWrittenToMemoryStreamKey) as! Data)
        tokenInfoInput.open()
        defer {
            tokenInfoInput.close()
        }
        let tokenInfoBuffer = TokenInfoBuffer(tokenInfoInput)
        
        let result = tokenInfoBuffer.lookupEntry(0)
        XCTAssertEqual("hello", resultMap[result.featureInfos[0]])
        XCTAssertEqual("素敵な世界", resultMap[result.featureInfos[1]]);
    }
}
