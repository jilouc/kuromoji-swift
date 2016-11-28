//
//  StringArrayIO.swift
//  kuromoji-swift
//
//  Created by Jean-Luc Dagon on 20/11/2016.
//  Copyright © 2016 Cocoapps. All rights reserved.
//

import Foundation

struct StringArrayIO {
    
    public static func writeArray(_ outputStream: OutputStream, array: [String]) {
        outputStream.writeInt(array.count)
        for string in array {
            outputStream.writeString(string)
        }
    }
    
    public static func writeArray2D(_ outputStream: OutputStream, array: [[String]]) {
        outputStream.writeInt(array.count)
        for inner in array {
            writeArray(outputStream, array: inner)
        }
    }
    
    public static func readArray(_ inputStream: InputStream) -> [String] {
        let length = inputStream.readInt()
        var strings = [String]()
        for _ in 0..<length {
            strings.append(inputStream.readString())
        }
        return strings
    }
}
