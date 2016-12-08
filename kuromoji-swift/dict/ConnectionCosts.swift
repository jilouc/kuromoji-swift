//
//  ConnectionCosts.swift
//  kuromoji-swift
//
//  Created by Jean-Luc Dagon on 05/12/2016.
//  Copyright © 2016 Cocoapps. All rights reserved.
//

import Foundation

class ConnectionCosts {
    
    public static let CONNECTION_COSTS_FILENAME = "connectionCosts.bin"
    private var size: Int
    private var costs: [Int16]
    
    required init(size: Int, costs: [Int16]) {
        self.size = size
        self.costs = costs
    }
    
    convenience init(_ inputStream: InputStream) {
        let size = inputStream.readInt()
        let bufferSize = inputStream.readInt()
        var costsBuffer = [Int16](repeating: 0, count: bufferSize)
        for i in 0..<bufferSize {
            costsBuffer[i] = inputStream.readInt16()
        }
        self.init(size: size, costs: costsBuffer)
    }
    
    public func get(forwardId: Int, backwardId: Int) -> Int {
        return Int(costs[backwardId + forwardId * size])
    }
    
    
}
