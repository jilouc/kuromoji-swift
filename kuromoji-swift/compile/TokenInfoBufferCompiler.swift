//
//  TokenInfoBufferCompiler.swift
//  kuromoji-swift
//
//  Created by Jean-Luc Dagon on 30/11/2016.
//  Copyright © 2016 Cocoapps. All rights reserved.
//

import Foundation

public class TokenInfoBufferCompiler: Compiler {
    
    private static let INTEGER_BYTES = MemoryLayout<Int>.size / MemoryLayout<UInt8>.size
    private static let SHORT_BYTES = MemoryLayout<Int16>.size / MemoryLayout<UInt8>.size
    
    private let outputStream: OutputStream
    private var buffer: ByteBuffer!
    
    
    init(_ outputStream: OutputStream, entries: [BufferEntry]) {
        self.outputStream = outputStream
        putEntries(entries)
    }
    
    public func putEntries(_ entries: [BufferEntry]) {
        let size = 2 * calculateEntriesSize(entries)
        buffer = ByteBuffer(size: size)
        
        buffer.put(size)
        buffer.put(entries.count)
        
        if entries.count == 0 {
            return
        }
        let firstEntry = entries.first!
        buffer.put(firstEntry.tokenInfo.count)
        buffer.put(firstEntry.posInfo.count)
        buffer.put(firstEntry.features.count)
        
        for entry in entries {
            for s in entry.tokenInfo {
                buffer.put(s)
            }
            for b in entry.posInfo {
                buffer.put([UInt8(bitPattern: b)])
            }
            for feature in entry.features {
                buffer.put(feature)
            }
        }
    }
    
    private func calculateEntriesSize(_ entries: [BufferEntry]) -> Int {
        if entries.count == 0 {
            return 0
        }
        let entry = entries.first!
        let size = entries.count *
            (
                (entry.tokenInfo.count + 1) * TokenInfoBufferCompiler.SHORT_BYTES +
                entry.posInfo.count +
                entry.features.count * TokenInfoBufferCompiler.INTEGER_BYTES
            )
        return size
    }
    
    func compile() {
        outputStream.open()
        outputStream.write([UInt8](buffer.buffer), maxLength: buffer.size)
        outputStream.close()
    }
}
