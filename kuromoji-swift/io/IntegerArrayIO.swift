//
//  IntegerArrayIO.swift
//  kuromoji-swift
//
//  Created by Jean-Luc Dagon on 20/11/2016.
//  Copyright © 2016 Cocoapps. All rights reserved.
//

import Foundation

struct IntegerArrayIO {
    
    static let INT_BYTES = MemoryLayout<Int>.size / MemoryLayout<UInt8>.size;

    public static func writeArray(_ outputStream: OutputStream, array: [Int]) {
        outputStream.writeInt(array.count)
        for i in array {
            outputStream.writeInt(i)
        }
    }
    
    public static func writeArray2D(_ outputStream: OutputStream, array: [[Int]]) {
        outputStream.writeInt(array.count)
        for inner in array {
            writeArray(outputStream, array: inner)
        }
    }
    
    public static func writeSparseArray2D(_ outputStream: OutputStream, array: [[Int]?]) {
        outputStream.writeInt(array.count)
        
        for (i, inner) in array.enumerated() {
            if let inner = inner {
                outputStream.writeInt(i)
                writeArray(outputStream, array: inner)
            }
        }
        outputStream.writeInt(-1)
    }
    
    public static func readSparseArray2D(_ inputStream: InputStream) -> [[Int]?] {
        let arrayCount = inputStream.readInt()
        var arrays = [[Int]?](repeating: nil, count: arrayCount)
        
        var index: Int
        while inputStream.hasBytesAvailable {
            index = inputStream.readInt()
            if index < 0 {
                break
            }
            arrays[index] = readArray(inputStream)
        }
        
        return arrays
    }
    
    public static func readArray(_ inputStream: InputStream) -> [Int] {
        let count = inputStream.readInt()
        var array = [Int]()
        for _ in 0..<count {
            array.append(inputStream.readInt())
        }
        return array
    }
    
    /*public static int[][] readSparseArray2D(InputStream input) throws IOException {
    ReadableByteChannel channel = Channels.newChannel(input);
    
    int arrayCount = readIntFromByteChannel(channel);
    int[][] arrays = new int[arrayCount][];
    
    int index;
    
    while ((index = readIntFromByteChannel(channel)) >= 0) {
    arrays[index] = readArrayFromChannel(channel);
    }
    return arrays;
    }*/
}

