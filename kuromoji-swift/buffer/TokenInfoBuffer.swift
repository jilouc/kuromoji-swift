//
//  TokenInfoBuffer.swift
//  kuromoji-swift
//
//  Created by Jean-Luc Dagon on 16/11/2016.
//  Copyright © 2016 Cocoapps. All rights reserved.
//

import Foundation


public class TokenInfoBuffer {

    private static let INTEGER_BYTES: Int = MemoryLayout<UInt32>.size / MemoryLayout<UInt8>.size
    private static let SHORT_BYTES: Int = MemoryLayout<UInt16>.size / MemoryLayout<UInt8>.size
    
    private var buffer: ByteBuffer = ByteBuffer(size: 0)
    
    private var tokenInfoCount: Int = 0
    private var posInfoCount: Int = 0
    private var featureCount: Int = 0
    private var entrySize: Int = 0;

    init(_ inputStream: InputStream) {
        var readBuffer: UnsafeMutablePointer<UInt8>?
        var readSize: Int = 0
        inputStream.getBuffer(&readBuffer, length: &readSize)
        if readBuffer != nil {
            buffer = ByteBuffer(size: readSize)
            buffer.put([UInt8](UnsafeBufferPointer(start: readBuffer, count: readSize)))
        }
        tokenInfoCount = getTokenInfoCount()
        posInfoCount = getPosInfoCount()
        featureCount = getFeatureCount()
        entrySize = getEntrySize(tokenInfoCount: tokenInfoCount, posInfoCount: posInfoCount, featureCount: featureCount)
    }
    
    
    public func lookupEntry(_ offset: Int) -> BufferEntry {
        var entry = BufferEntry();
        let position = getPosition(offset, entrySize);
    
        // Get left id, right id and word cost
        for i in 0..<tokenInfoCount {
            entry.tokenInfos.append(buffer.getInt16(at: position + i * TokenInfoBuffer.SHORT_BYTES));
        }
    
        // Get part of speech tags values (not strings yet)
        for i in 0..<posInfoCount {
            entry.posInfos.append(Int8(bitPattern: buffer.buffer[position + tokenInfoCount * TokenInfoBuffer.SHORT_BYTES + i]));
        }
    
        // Get field value references (string references)
        for i in 0..<featureCount {
            entry.featureInfos.append(buffer.getInt(at: position + tokenInfoCount * TokenInfoBuffer.SHORT_BYTES + posInfoCount + i * TokenInfoBuffer.INTEGER_BYTES));
        }
    
        return entry;
    }
    
    public func lookupTokenInfo(_ offset: Int, _ i: Int) -> Int {
        let position = getPosition(offset, entrySize);
        return Int(buffer.getInt16(at: position + i * TokenInfoBuffer.SHORT_BYTES));
    }
    
    public func lookupPartOfSpeechFeature(_ offset: Int, _ i: Int) -> Int {
        let position = getPosition(offset, entrySize);
        return (0xFF & buffer.getInt(at: position + tokenInfoCount * TokenInfoBuffer.SHORT_BYTES + i));
    }
    
    public func lookupFeature(_ offset: Int, _ i: Int) -> Int {
        let position = getPosition(offset, entrySize);
        return buffer.getInt(at: position + tokenInfoCount * TokenInfoBuffer.SHORT_BYTES + posInfoCount + (i - posInfoCount) * TokenInfoBuffer.INTEGER_BYTES);
    }
    
    public func isPartOfSpeechFeature(_ i: Int) -> Bool {
        return (i < getPosInfoCount())
    }
    
    public func getTokenInfoCount() -> Int {
        return Int(buffer.getInt(at: TokenInfoBuffer.INTEGER_BYTES * 2))
    }
    
    public func getPosInfoCount() -> Int {
        return Int(buffer.getInt(at: TokenInfoBuffer.INTEGER_BYTES * 3))
    }
    
    public func getFeatureCount() -> Int {
        return Int(buffer.getInt(at: TokenInfoBuffer.INTEGER_BYTES * 4))
    }
    
    public func getEntrySize(tokenInfoCount: Int, posInfoCount: Int, featureCount: Int) -> Int {
        return tokenInfoCount * TokenInfoBuffer.SHORT_BYTES + posInfoCount + featureCount * TokenInfoBuffer.INTEGER_BYTES
    }
    
    private func getPosition(_ offset: Int, _ entrySize: Int) -> Int {
        return offset * entrySize + TokenInfoBuffer.INTEGER_BYTES * 5;
    }
    
}
