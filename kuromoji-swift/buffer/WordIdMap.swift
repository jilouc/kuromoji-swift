//
//  WordIdMap.swift
//  kuromoji-swift
//
//  Created by Jean-Luc Dagon on 16/11/2016.
//  Copyright © 2016 Cocoapps. All rights reserved.
//

import Foundation


public class WordIdMap {
    
    private let indices: [Int];
    private let wordIds: [Int];
    
    private static let empty = [Int]();
    
    init(inputStream: InputStream) {
        let arrays = IntegerArrayIO.readArray2D(inputStream)
        indices = arrays[0]
        wordIds = arrays[2]
    }
    
    public func lookUp(_ sourceId: Int) -> [Int] {
        let index = indices[sourceId];
    
        if (index == -1) {
            return WordIdMap.empty;
        }
    
        return [Int](wordIds[(index + 1)..<(index + 1 + wordIds[index])])
    }
}
