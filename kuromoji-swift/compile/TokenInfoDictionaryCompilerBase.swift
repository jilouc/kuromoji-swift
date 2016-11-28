//
//  TokenInfoDictionaryCompilerBase.swift
//  kuromoji-swift
//
//  Created by Jean-Luc Dagon on 26/11/2016.
//  Copyright © 2016 Cocoapps. All rights reserved.
//

import Foundation

enum TokenInfoDictionaryCompilerError: Error {
    case invalidEntry
}

class TokenInfoDictionaryCompilerBase<Entry: DictionaryEntryBase>: Compiler {
    
    var bufferEntries = [BufferEntry]()
    var posInfo = FeatureInfoMap()
    var otherInfo = FeatureInfoMap()
    let wordIdsCompiler = WordIdMapCompiler()
    
    var dictionaryEntries: [GenericDictionaryEntry]? = nil

    let encoding: String.Encoding
    var surfaces = [String]()
    
    init(encoding: String.Encoding) {
        self.encoding = encoding
    }
    
    public func analyzeTokenInfo(_ inputStream: InputStream) {
        let reader = BufferedStringReader(inputStream, encoding: self.encoding)
        for line in reader {
            if let entry = parse(line),
                let dictionaryEntry = makeGenericDictionaryEntry(entry)
            {
                let _ = posInfo.mapFeatures(dictionaryEntry.partOfSpeechFeatures)
            }
        }
    }
    
    public func readTokenInfo(_ inputStream: InputStream) throws {
        let reader = BufferedStringReader(inputStream, encoding: self.encoding)
        let entryCountFitInAByte = entriesFitInAByte(posInfo.getEntryCount())
        
        for line in reader {
            guard
                let entry = parse(line),
                let dictionaryEntry = makeGenericDictionaryEntry(entry)
            else {
                throw TokenInfoDictionaryCompilerError.invalidEntry
            }
            let leftId = dictionaryEntry.leftId
            let rightId = dictionaryEntry.rightId
            let wordCost = dictionaryEntry.wordCost
            
            let allPosFeatures = dictionaryEntry.partOfSpeechFeatures
            let posFeatureIds = posInfo.mapFeatures(allPosFeatures)
            
            let featureList = dictionaryEntry.otherFeatures
            let otherFeatureIds = otherInfo.mapFeatures(featureList)
            
            var bufferEntry = BufferEntry()
            bufferEntry.tokenInfo.append(leftId)
            bufferEntry.tokenInfo.append(rightId)
            bufferEntry.tokenInfo.append(wordCost)
            
            if entryCountFitInAByte {
                bufferEntry.posInfo.append(contentsOf: createPosFeatureIds(posFeatureIds))
            } else {
                bufferEntry.tokenInfo.append(contentsOf: posFeatureIds.map {
                    Int16(truncatingBitPattern: $0)
                })
            }
            
            bufferEntry.features.append(contentsOf: otherFeatureIds)
            bufferEntries.append(bufferEntry)
            surfaces.append(dictionaryEntry.surface)
            
            if var dictionaryEntries = dictionaryEntries {
                dictionaryEntries.append(dictionaryEntry)
            }
        }
    }
    
    func makeGenericDictionaryEntry(_ entry: Entry) -> GenericDictionaryEntry? {
        return nil
    }
    
    func parse(_ line: String) -> Entry? {
        return nil
    }
    
    func compile() {
        
    }
    
    private func entriesFitInAByte(_ entryCount: Int) -> Bool {
        return entryCount <= Int(Int8.max)
    }
    
    private func createPosFeatureIds(_ posFeatureIds: [Int]) -> [Int8] {
        return posFeatureIds.map {
            Int8(truncatingBitPattern: $0)
        }
    }
}
