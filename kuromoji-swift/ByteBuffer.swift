//
//  ByteBuffer.swift
//  kuromoji-swift
//
//  Created by Jean-Luc Dagon on 16/11/2016.
//  Copyright © 2016 Cocoapps. All rights reserved.
//

import Foundation

struct ByteBuffer {
    public var buffer: [UInt8]
    private var pos: Int = 0
    var size: Int {
        get {
            return buffer.count
        }
    }
    
    init(size: Int) {
        buffer = [UInt8](repeating: 0, count: size)
    }
    
    mutating func position(_ index: Int) {
        pos = index
    }
    
    mutating func put(_ uint16: UInt16) {
        put(uint16, at: pos)
    }
    
    mutating func put(_ uint16: UInt16, at index: Int) {
        put([UInt8((uint16 & 0xFF00) >> 8), UInt8(uint16 & 0x00FF)], at: index)
    }
    
    mutating func put(_ int: Int) {
        put(int, at: pos)
    }
    
    mutating func put(_ int: Int, at index: Int) {
        put([UInt8((int & 0xFF000000) >> 24), UInt8((int & 0x00FF0000) >> 16), UInt8((int & 0x0000FF00) >> 8),  UInt8(int & 0x000000FF)], at: index)
    }
    
    mutating func put(_ bytes: [UInt8]) {
        put(bytes, at: pos)
    }
    
    mutating func put(_ bytes: [UInt8], at index: Int) {
        buffer.replaceSubrange(index..<(index + bytes.count), with: bytes)
        pos = index + bytes.count
    }
    
    func getInt(at index: Int) -> UInt32 {
        if size < 4 || index >= size - 4 {
            return 0
        }
        let b1 = ((UInt32(buffer[index])     << 24) & 0xFF000000)
        let b2 = ((UInt32(buffer[index + 1]) << 16) & 0x00FF0000)
        let b3 = ((UInt32(buffer[index + 2]) << 8)  & 0x0000FF00)
        let b4 = ((UInt32(buffer[index + 3]) << 0)  & 0x000000FF)
        return (b1 | b2 | b3 | b4)
    }
    
    func getUInt16(at index: Int) -> UInt16 {
        if size < 2 || index >= size - 2 {
            return 0
        }
        let b1 = ((UInt16(buffer[index])     << 8) & 0xFF00)
        let b2 = ((UInt16(buffer[index + 1]) << 0) & 0x00FF)
        return (b1 | b2)
    }
    
}
