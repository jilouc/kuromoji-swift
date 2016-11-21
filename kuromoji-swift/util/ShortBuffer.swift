//
//  ShortBuffer.swift
//  kuromoji-swift
//
//  Created by Jean-Luc Dagon on 20/11/2016.
//  Copyright © 2016 Cocoapps. All rights reserved.
//

import Foundation

class ShortBuffer {
    public var bufferPointer: UnsafeMutablePointer<Int16>
    public var buffer: UnsafeMutableBufferPointer<Int16>
    private var pos: Int = 0
    let size: Int
    
    
    init(size: Int) {
        self.size = size
        bufferPointer = UnsafeMutablePointer<Int16>.allocate(capacity: size)
        buffer = UnsafeMutableBufferPointer<Int16>(start: bufferPointer, count: size)
    }
    
    deinit {
        bufferPointer.deallocate(capacity: size)
    }
    
    func position(_ index: Int) {
        pos = index
    }
    
    func putByte(_ byte: Int8) {
        putByte(byte, at: pos)
    }
    
    func putByte(_ byte: Int8, at index: Int) {
        put([Int16(byte)], at: index)
    }
    
    func put(_ int16: Int16) {
        put(int16, at: pos)
    }
    
    func put(_ int16: Int16, at index: Int) {
        put([int16], at: index)
    }
    
    func put(_ int: Int) {
        put(int, at: pos)
    }
    
    func put(_ int: Int, at index: Int) {
        put([Int16((int & 0xFFFF0000) >> 16), Int16(int & 0x0000FFFF)], at: index)
    }
    
    func put(_ shorts: [Int16]) {
        put(shorts, at: pos)
    }
    
    func put(_ shorts: [Int16], at index: Int) {
        for i in index..<(index + shorts.count) {
            buffer[index] = shorts[i - index]
        }
        pos = index + shorts.count
    }
    
    /*func getInt(at index: Int) -> Int32 {
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
    */
}
