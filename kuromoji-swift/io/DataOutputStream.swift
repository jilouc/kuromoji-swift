//
//  DataOutputStream.swift
//  kuromoji-swift
//
//  Created by Jean-Luc Dagon on 19/11/2016.
//  Copyright © 2016 Cocoapps. All rights reserved.
//

import Foundation

extension OutputStream {
    
    func writeInt32(_ int: UInt32) {
        write([UInt8((int & 0xFF000000) >> 24), UInt8((int & 0xFF0000) >> 16), UInt8((int & 0xFF00) >> 8), UInt8(int & 0xFF)], maxLength: 4)
    }
    
    func writeInt16(_ int: UInt16) {
        write([UInt8((int & 0xFF00) >> 8), UInt8(int & 0xFF)], maxLength: 2)
    }
    
    func writeInt(_ int: Int) {
        writeInt32(UInt32(bitPattern: Int32(int)))
    }
    
    func writeString(_ string: String) {
        let bytes = [UInt8](string.utf8)
        writeInt16(UInt16(bitPattern:Int16(bytes.count)))
        write(bytes, maxLength: bytes.count)
    }
}

extension InputStream {
    
    func readInt32() -> Int32 {
        var bytes: [UInt8] = [UInt8](repeating: 0, count: 4)
        self.read(&bytes, maxLength: 4)
        return Int32(bitPattern: ((UInt32(bytes[0]) << 24) & 0xFF000000) | ((UInt32(bytes[1]) << 16) & 0xFF0000) | ((UInt32(bytes[2]) << 8) & 0xFF00) | ((UInt32(bytes[3])) & 0xFF))
    }
    
    func readInt16() -> Int16 {
        var bytes: [UInt8] = [UInt8](repeating: 0, count: 2)
        self.read(&bytes, maxLength: 2)
        return Int16(bitPattern: ((UInt16(bytes[0]) << 8) & 0xFF00) | (UInt16(bytes[1]) & 0xFF))
    }
    
    func readString() -> String {
        let length = Int(readInt16())
        var bytes = [UInt8](repeating: 0, count: length)
        read(&bytes, maxLength: length)
        return String(bytes: bytes, encoding: .utf8)!
    }
    
    func readInt() -> Int {
        return Int(readInt32())
    }
    
    
}
