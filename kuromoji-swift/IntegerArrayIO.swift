//
//  IntegerArrayIO.swift
//  kuromoji-swift
//
//  Created by Jean-Luc Dagon on 20/11/2016.
//  Copyright © 2016 Cocoapps. All rights reserved.
//

import Foundation

struct IntegerArrayIO {
    
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
}

