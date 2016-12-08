//
//  ConnectionCostsCompiler.swift
//  kuromoji-swift
//
//  Created by Jean-Luc Dagon on 20/11/2016.
//  Copyright © 2016 Cocoapps. All rights reserved.
//

import Foundation

class ConnectionCostsCompiler : Compiler {
    
    private static let SHORT_BYTES: Int = MemoryLayout<UInt16>.size / MemoryLayout<UInt8>.size
    private var cardinality: Int = 0
    private var bufferSize: Int = 0
    private let outputStream: OutputStream
    private var costs: [Int16]!
    
    init(_ outputStream: OutputStream) {
        self.outputStream = outputStream
    }
 
    
    public func readCosts(at filePath: String) {
        guard let inputStream = InputStream(fileAtPath: filePath) else {
            return
        }
        readCosts(inputStream)
    }
    
    public func readCosts(_ inputStream: InputStream) {
    
        let reader = BufferedStringReader(inputStream, encoding: .utf8, chunkSize: 256)
        
        guard let firstLine = reader.nextLine() else {
            return
        }
        let cardinalities = firstLine.separatedBySpaces()
        assert(cardinalities.count == 2)
        
        let forwardSize = Int(cardinalities[0])!
        let backwardSize = Int(cardinalities[1])!
        
        assert(forwardSize == backwardSize)
        assert(forwardSize > 0)
        assert(backwardSize > 0)
        
        cardinality = backwardSize
        bufferSize = forwardSize * backwardSize
        costs = [Int16](repeating: 0, count: bufferSize)
        
        for line in reader {
            autoreleasepool {
                let fields = line.unicodeScalars.split(separator: " ")
                assert(fields.count == 3)
                let forwardId = Int(String(fields[0]))!
                let backwardId = Int(String(fields[1]))!
                let cost = Int16(String(fields[2]))!
                putCost(forwardId: forwardId, backwardId: backwardId, cost: cost)
            }
        }
        
    }
    
    func putCost(forwardId: Int, backwardId: Int, cost: Int16) {
        costs[backwardId + forwardId * cardinality] = cost
    }
    
    func compile() {
        outputStream.open()
        outputStream.writeInt(cardinality)
        outputStream.writeInt(bufferSize)
        for cost in costs {
            outputStream.writeInt16(cost)
        }
        outputStream.close()
    }
}
