//
//  LineNumberReader.swift
//  kuromoji-swift
//
//  Created by Jean-Luc Dagon on 17/11/2016.
//  Copyright © 2016 Cocoapps. All rights reserved.
//

import Foundation

public class BufferedReader: Sequence {
    let lineDelimiterData: Data
    let chunkSize: Int
    var fileHandle: FileHandle!
    let encoding: String.Encoding
    
    var buffer: Data
    var endOfFile: Bool
    
    init?(_ filePath: String, lineDelimiter: Character = "\n", chunkSize: Int = 4096, encoding: String.Encoding) {
        
        guard let fileHandle = FileHandle(forReadingAtPath: filePath) else {
            return nil
        }
        guard let delimiterData = String(lineDelimiter).data(using: encoding) else {
            return nil
        }
        self.fileHandle = fileHandle
        self.lineDelimiterData = delimiterData
        self.encoding = encoding
        self.chunkSize = chunkSize
        self.buffer = Data(capacity: chunkSize)
        self.endOfFile = false
    }
    
    deinit {
        self.close()
    }
    
    func nextLine() -> String? {
        precondition(fileHandle != nil, "Attempt to read from closed file")
        
        // Read data chunks from file until a line delimiter is found:
        while !endOfFile {
            if let range = buffer.range(of: lineDelimiterData) {
                // Convert complete line (excluding the delimiter) to a string:
                let line = String(data: buffer.subdata(in: 0..<range.lowerBound), encoding: encoding)
                // Remove line (and the delimiter) from the buffer:
                buffer.removeSubrange(0..<range.upperBound)
                return line
            }
            let tmpData = fileHandle.readData(ofLength: chunkSize)
            if tmpData.count > 0 {
                buffer.append(tmpData)
            } else {
                // EOF or read error.
                endOfFile = true
                if buffer.count > 0 {
                    // Buffer contains last line in file (not terminated by delimiter).
                    let line = String(data: buffer as Data, encoding: encoding)
                    buffer.count = 0
                    return line
                }
            }
        }
        return nil
    }
    
    /// Start reading from the beginning of file.
    public func rewind() -> Void {
        fileHandle.seek(toFileOffset: 0)
        buffer.count = 0
        endOfFile = false
    }
    
    /// Close the underlying file. No reading must be done after calling this method.
    public func close() {
        fileHandle?.closeFile()
        fileHandle = nil
    }
    
    public func makeIterator() -> AnyIterator<String> {
        return AnyIterator {
            return self.nextLine()
        }
    }
}
