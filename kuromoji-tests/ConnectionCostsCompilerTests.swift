//
//  ConnectionCostsCompilerTests.swift
//  kuromoji-swift
//
//  Created by Jean-Luc Dagon on 04/12/2016.
//  Copyright © 2016 Cocoapps. All rights reserved.
//

import XCTest

class ConnectionCostsCompilerTests: XCTestCase {
    
    var connectionCosts: ConnectionCosts!

    override func setUp() {
        super.setUp()
    
        let bundle = Bundle.init(for: type(of: self))
        let outputStream = OutputStream(toMemory: ())
        
        let costs = "" +
            "3 3\n" +
            "0 0 1\n" +
            "0 1 2\n" +
            "0 2 3\n" +
            "1 0 4\n" +
            "1 1 5\n" +
            "1 2 6\n" +
            "2 0 7\n" +
            "2 1 8\n" +
            "2 2 9\n"
        
        let costsCompilerInput = InputStream(data: costs.data(using: .utf8)!)
        costsCompilerInput.open()
        defer {
            costsCompilerInput.close()
        }
        
        let compiler = ConnectionCostsCompiler(outputStream)
        compiler.readCosts(costsCompilerInput)
        compiler.compile()
        
        let costsInput = InputStream(data: outputStream.property(forKey: .dataWrittenToMemoryStreamKey) as! Data)
        costsInput.open()
        defer {
            costsInput.close()
        }
        
        connectionCosts = ConnectionCosts(costsInput)
    }
    
    func testCosts() {
        var cost = 1;
        
        for i in 0..<3 {
            for j in 0..<3 {
                XCTAssertEqual(cost, connectionCosts.get(forwardId: i, backwardId: j))
                cost += 1
            }
        }
    }
    
    

}
