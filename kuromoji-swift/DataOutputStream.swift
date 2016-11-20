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
    
    func writeString(_ string: String, encoding: String.Encoding = .utf8) {
        let bytes = [UInt8](string.utf8)
        writeInt16(UInt16(bitPattern:Int16(bytes.count)))
        write(bytes, maxLength: bytes.count)
    }
}
