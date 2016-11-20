//
//  StringValueMapBuffer.swift
//  kuromoji-swift
//
//  Created by Jean-Luc Dagon on 14/11/2016.
//  Copyright © 2016 Cocoapps. All rights reserved.
//

import Foundation

class StringValueMapBuffer {
    
    private static let INTEGER_BYTES: Int = MemoryLayout<UInt32>.size / MemoryLayout<UInt8>.size
    private static let SHORT_BYTES: Int = MemoryLayout<UInt16>.size / MemoryLayout<UInt8>.size
    private static let KATAKANA_FLAG: UInt16 = 0x8000
    private static let KATAKANA_LENGTH_MASK: UInt16 = 0x7fff
    private static let KATAKANA_BASE: UInt32 = UInt32(("\u{3000}" as Character).unicodeScalarCodePoint)
    
    public var buffer = ByteBuffer(size: 0)
    private var size: Int = 0;
    
    init(_ features: [Int: String]) {
        put(features)
    }
    
    init(_ inputStream: InputStream) {
        var readBuffer: UnsafeMutablePointer<UInt8>?
        inputStream.getBuffer(&readBuffer, length: &size)
        if readBuffer != nil {
            buffer = ByteBuffer(size: size)
            buffer.put([UInt8](UnsafeBufferPointer(start: readBuffer, count: size)))
        }
    }
    
    public func get(_ key: Int) -> String {
        assert(key >= 0 && key < size);
        
        let keyIndex = (key + 1) * StringValueMapBuffer.INTEGER_BYTES;
        let valueIndex = Int(buffer.getInt(at: keyIndex))
        var length = buffer.getUInt16(at: valueIndex)
        
        if ((length & StringValueMapBuffer.KATAKANA_FLAG) != 0) {
            length &= StringValueMapBuffer.KATAKANA_LENGTH_MASK
            return getKatakanaString(valueIndex + StringValueMapBuffer.SHORT_BYTES, length: Int(length))
        } else {
            return getString(valueIndex + StringValueMapBuffer.SHORT_BYTES, length: Int(length))
        }
    }
    
    public func getKatakanaString(_ valueIndex: Int, length: Int) -> String {
        var string = String()
        for byte in buffer.buffer[valueIndex..<(valueIndex + length)] {
            string.append(Character(UnicodeScalar(UInt32(byte) + StringValueMapBuffer.KATAKANA_BASE)!));
        }
        return string
    }
    
    public func getString(_ valueIndex: Int, length: Int) -> String {
        return String(bytes: buffer.buffer[valueIndex..<(valueIndex+length)], encoding: .utf16)!;
    }
    
    public func write(_ output: OutputStream) {
        output.write(buffer.buffer, maxLength: buffer.size);
    }
    
    public func put(_ strings: [Int: String]) {
        let bufferSize = calculateSize(strings);
        size = strings.count;
    
        buffer = ByteBuffer(size: bufferSize)
        buffer.put(size, at: 0); // Set entries
    
        var keyIndex = StringValueMapBuffer.INTEGER_BYTES; // First key index is past size
        var entryIndex = keyIndex + size * StringValueMapBuffer.INTEGER_BYTES;
    
        for (_, string) in strings {
            buffer.put(entryIndex, at: keyIndex)
            entryIndex = put(entryIndex, string)
            keyIndex += StringValueMapBuffer.INTEGER_BYTES
        }
    }
    
    public func calculateSize(_ values: [Int: String]) -> Int {
        var size = StringValueMapBuffer.INTEGER_BYTES + values.count * StringValueMapBuffer.INTEGER_BYTES;
        
        for (_, value) in values {
            size += StringValueMapBuffer.SHORT_BYTES + getByteSize(value);
        }
        return size;
    }
        
    public func getByteSize(_ string: String) -> Int {
        if string.isKatakana() {
            return string.unicodeScalars.count;
        }
        return getBytes(string).count;
    }
    
    private func put(_ index: Int, _ value: String) -> Int {
        let katakana = value.isKatakana()
        let length: UInt16
        let bytes: [UInt8]
        if (katakana) {
            bytes = getKatakanaBytes(value);
            length = (UInt16(bytes.count) | StringValueMapBuffer.KATAKANA_FLAG)
        } else {
            bytes = getBytes(value);
            length = UInt16(bytes.count);
        }
    
        assert(Int32(bytes.count) < UINT16_MAX)
        
        buffer.position(index)
        buffer.put(length)
        buffer.put(bytes)
    
        return index + StringValueMapBuffer.SHORT_BYTES + bytes.count;
    }
    
    func getKatakanaBytes(_ string: String) -> [UInt8] {
        var bytes = [UInt8]()
        for scalar in string.unicodeScalars {
            let baseValue = UInt32(bitPattern:(Int32(scalar.value) - Int32(StringValueMapBuffer.KATAKANA_BASE)))
            bytes.append(UInt8(baseValue))
        }
        return bytes
    }
    
    private func getBytes(_ string: String) -> [UInt8] {
        return string.utf16.flatMap {
            [UInt8(($0 & 0xFF00) >> 8), UInt8($0 & 0x00FF)]
        }
    }
}
