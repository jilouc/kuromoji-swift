//
//  LineNumberReader.swift
//  kuromoji-swift
//
//  Created by Jean-Luc Dagon on 17/11/2016.
//  Copyright © 2016 Cocoapps. All rights reserved.
//

import Foundation

public class BufferedDataReader: Sequence {
    
    let lineDelimiter: Data
    let chunkSize: Int
    var inputStream: InputStream!
    
    var buffer: Data
    var endOfFile: Bool
    
    convenience init?(_ filePath: String, lineDelimiter: Data, chunkSize: Int = 4096) {
        
        guard let inputStream = InputStream(fileAtPath: filePath) else {
            return nil
        }
        self.init(inputStream, lineDelimiter: lineDelimiter, chunkSize: chunkSize)
    }
    
    init(_ inputStream: InputStream, lineDelimiter: Data, chunkSize: Int = 4096) {
    
        self.inputStream = inputStream
        self.lineDelimiter = lineDelimiter
        self.chunkSize = chunkSize
        self.buffer = Data(capacity: chunkSize)
        self.endOfFile = false
        
        if inputStream.streamStatus != .open {
            inputStream.open()
        }
    }
    
    deinit {
        self.close()
    }
    
    func nextLine() -> Data? {
        precondition(inputStream != nil, "Attempt to read from closed file")
        
        // Read data chunks from file until a line delimiter is found:
        while !endOfFile {
            let line = autoreleasepool { () -> Data? in
                if let range = buffer.range(of: lineDelimiter) {
                    // Convert complete line (excluding the delimiter) to a string:
                    let line = buffer.subdata(in: 0..<range.lowerBound)
                    // Remove line (and the delimiter) from the buffer:
                    buffer.removeSubrange(0..<range.upperBound)
                    return line
                }
                var bytes = [UInt8](repeating: 0, count: chunkSize)
                let bytesRead = inputStream.read(&bytes, maxLength: chunkSize)
                if bytesRead > 0 {
                    buffer.append(Data(bytes: bytes, count: bytesRead))
                } else {
                    // EOF or read error.
                    endOfFile = true
                    if buffer.count > 0 {
                        // Buffer contains last line in file (not terminated by delimiter).
                        let line = Data(bytes: bytes, count: bytesRead)
                        buffer.count = 0
                        return line
                    }
                }
                return nil
            }
            if line != nil {
                return line
            }
        }
        return nil
    }
    
    /// Start reading from the beginning of file.
    /// Close the underlying file. No reading must be done after calling this method.
    public func close() {
        inputStream?.close()
        inputStream = nil
    }
    
    public func makeIterator() -> AnyIterator<Data> {
        return AnyIterator {
            return self.nextLine()
        }
    }
}

class BufferedStringReader : Sequence {
    
    let encoding: String.Encoding
    let dataReader: BufferedDataReader!
    
    convenience init?(_ filePath: String, encoding: String.Encoding, lineDelimiter: Character = "\n", chunkSize: Int = 4096) {
        guard let inputStream = InputStream(fileAtPath: filePath) else {
            return nil
        }
        self.init(inputStream, encoding: encoding, lineDelimiter: lineDelimiter, chunkSize: chunkSize)
    }
    
    init(_ inputStream: InputStream, encoding: String.Encoding, lineDelimiter: Character = "\n", chunkSize: Int = 4096) {
        let delimiterData = String(lineDelimiter).data(using: encoding)!
        self.encoding = encoding
        dataReader = BufferedDataReader(inputStream, lineDelimiter: delimiterData, chunkSize: chunkSize)
    }
    
    func nextLine() -> String? {
        guard let line = dataReader.nextLine() else {
            return nil
        }
        return String(data: line, encoding: encoding)
    }
    
    func makeIterator() -> AnyIterator<String> {
        return AnyIterator {
            return self.nextLine()
        }
    }
}
