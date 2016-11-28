//
//  ByteBuffer.swift
//  kuromoji-swift
//
//  Created by Jean-Luc Dagon on 16/11/2016.
//  Copyright © 2016 Cocoapps. All rights reserved.
//

import Foundation

class ByteBuffer {
    public var bufferPointer: UnsafeMutablePointer<UInt8>
    public var buffer: UnsafeMutableBufferPointer<UInt8>
    private var pos: Int = 0
    var size: Int
    
    init(size: Int) {
        self.size = size
        bufferPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: size)
        buffer = UnsafeMutableBufferPointer<UInt8>(start: bufferPointer, count: size)
    }
    
    func position(_ index: Int) {
        pos = index
    }
    
    func put(_ uint16: UInt16) {
        put(uint16, at: pos)
    }
    
    func put(_ uint16: UInt16, at index: Int) {
        put([UInt8((uint16 & 0xFF00) >> 8), UInt8(uint16 & 0x00FF)], at: index)
    }
    
    func put(_ int16: Int16) {
        put(UInt16(bitPattern: int16), at: pos)
    }
    
    func put(_ int16: Int16, at index: Int) {
        put(UInt16(bitPattern: int16), at: index)
    }
    
    func put(_ int: Int) {
        put(int, at: pos)
    }
    
    func put(_ int: Int, at index: Int) {
        put([UInt8((int & 0xFF000000) >> 24), UInt8((int & 0x00FF0000) >> 16), UInt8((int & 0x0000FF00) >> 8),  UInt8(int & 0x000000FF)], at: index)
    }
    
    func put(_ bytes: [UInt8]) {
        put(bytes, at: pos)
    }
    
    func put(_ bytes: [UInt8], at index: Int) {
        for i in 0..<bytes.count {
            buffer[index + i] = bytes[i]
        }
        pos = index + bytes.count
    }
    
    func getInt(at index: Int) -> Int {
        if size < 4 || index >= size - 4 {
            return 0
        }
        let b1 = ((Int(buffer[index])     << 24) & 0xFF000000)
        let b2 = ((Int(buffer[index + 1]) << 16) & 0x00FF0000)
        let b3 = ((Int(buffer[index + 2]) << 8)  & 0x0000FF00)
        let b4 = ((Int(buffer[index + 3]) << 0)  & 0x000000FF)
        return b1 | b2 | b3 | b4
    }
    
    func getUInt16(at index: Int) -> UInt16 {
        if size < 2 || index >= size - 2 {
            return 0
        }
        let b1 = ((UInt16(buffer[index])     << 8) & 0xFF00)
        let b2 = ((UInt16(buffer[index + 1]) << 0) & 0x00FF)
        return (b1 | b2)
    }
    
    
    func getInt16(at index: Int) -> Int16 {
        if size < 2 || index >= size - 2 {
            return 0
        }
        let b1 = (Int16(buffer[index]) << 8) & Int16(bitPattern: 0xFF00)
        let b2 = (Int16(buffer[index + 1]) << 0) & Int16(0x00FF)
        return (b1 | b2)
    }
    
}
