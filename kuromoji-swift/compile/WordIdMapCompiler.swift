//
//  WordIdMapCompiler.swift
//  kuromoji-swift
//
//  Created by Jean-Luc Dagon on 26/11/2016.
//  Copyright © 2016 Cocoapps. All rights reserved.
//

import Foundation

class WordIdMapCompiler: Compiler {
    
    var wordIds = [[Int]?]()
    var indices = [Int]()
    var wordIdArray = [Int]()
    
    public func addMapping(sourceId: Int, wordId: Int) {
        if wordIds.count <= sourceId {
            wordIds.append(contentsOf: [[Int]?](repeating: nil, count: sourceId + 1 - wordIds.count))
        }
        
        var current = wordIds[sourceId] ?? []
        current.append(wordId)
        wordIds[sourceId] = current
    }
    
    public func write(_ outputStream: OutputStream) {
        compile()
        outputStream.open()
        IntegerArrayIO.writeArray(outputStream, array: indices)
        IntegerArrayIO.writeArray(outputStream, array: wordIdArray)
        outputStream.close()
    }
    
    func compile() {
        
        var wordIndex = 0
        for inner in wordIds {
            if let inner = inner {
                indices.append(wordIndex)
                wordIdArray.append(inner.count)
                wordIdArray.append(contentsOf: inner)
                wordIndex += (1 + inner.count)
            } else {
                indices.append(-1)
            }
        }
        
    }
    
}
