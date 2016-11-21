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
    private var costs: ShortBuffer!
    
    init(_ outputStream: OutputStream) {
        self.outputStream = outputStream
    }
 
    public func readCosts(at filePath: String) {
        
        guard let reader = BufferedReader(filePath, chunkSize: 256, encoding: String.Encoding.utf8) else {
            return
        }
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
        costs = ShortBuffer(size: bufferSize)
        
        for line in reader {
            autoreleasepool {
                let fields = line.components(separatedBy: " ")
                assert(fields.count == 3)
                let forwardId = Int(fields[0])!
                let backwardId = Int(fields[1])!
                let cost = Int16(fields[2])!
                
                putCost(forwardId: forwardId, backwardId: backwardId, cost: cost)
            }
        }
        
    }
    
    func putCost(forwardId: Int, backwardId: Int, cost: Int16) {
        costs.put(cost, at: backwardId + forwardId * cardinality)
    }
    
    func compile() {
        outputStream.open()
        outputStream.writeInt(cardinality)
        outputStream.writeInt(bufferSize * ConnectionCostsCompiler.SHORT_BYTES)
        
        let byteBuffer = ByteBuffer(size: costs.size * ConnectionCostsCompiler.SHORT_BYTES)
        for cost in costs.buffer {
            byteBuffer.put(cost)
        }
        outputStream.write([UInt8](byteBuffer.buffer), maxLength: byteBuffer.size)
        outputStream.close()
    }
}
