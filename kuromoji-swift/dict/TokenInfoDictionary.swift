//
//  TokenInfoDictionary.swift
//  kuromoji-swift
//
//  Created by Jean-Luc Dagon on 26/11/2016.
//  Copyright © 2016 Cocoapps. All rights reserved.
//

import Foundation

public class TokenInfoDictionary : DictionaryType {
    
    static let TOKEN_INFO_DICTIONARY_FILENAME = "tokenInfoDictionary.bin"
    static let FEATURE_MAP_FILENAME = "tokenInfoFeaturesMap.bin"
    static let POS_MAP_FILENAME = "tokenInfoPartOfSpeechMap.bin"
    static let TARGETMAP_FILENAME = "tokenInfoTargetMap.bin"
    
    static let LEFT_ID = 0
    static let RIGHT_ID = 1
    static let WORD_COST = 2
    static let TOKEN_INFO_OFFSET = 3
    
    static let FEATURE_SEPARATOR = ","
    
    var tokenInfoBuffer: TokenInfoBuffer!
    var posValues: StringValueMapBuffer!
    var stringValues: StringValueMapBuffer!
    var wordIdMap: WordIdMap;
    
    func lookupWordIds(_ sourceId: Int) -> [Int] {
        return wordIdMap.lookUp(sourceId)
    }
    
    func getLeftId(_ wordId: Int) -> Int {
        return tokenInfoBuffer.lookupTokenInfo(wordId, TokenInfoDictionary.LEFT_ID)
    }
    
    func getRightId(_ wordId: Int) -> Int {
        return tokenInfoBuffer.lookupTokenInfo(wordId, TokenInfoDictionary.RIGHT_ID)
    }
    
    func getWordCost(_ wordId: Int) -> Int {
        return tokenInfoBuffer.lookupTokenInfo(wordId, TokenInfoDictionary.WORD_COST)
    }
    
    func getAllFeatures(_ wordId: Int) -> String {
        let features: [String] = getAllFeatures(wordId)
        return features.map({
            CSVParser.escape($0)
        }).joined(separator: TokenInfoDictionary.FEATURE_SEPARATOR)
    }
    
    func getAllFeatures(_ wordId: Int) -> [String] {
        let bufferEntry = tokenInfoBuffer.lookupEntry(wordId)
        var posLength = bufferEntry.posInfo.count
        
        var partOfSpeechAsShort = false
        if posLength == 0 {
            posLength = bufferEntry.tokenInfos.count - TokenInfoDictionary.TOKEN_INFO_OFFSET
            partOfSpeechAsShort = true
        }
        var result = [String]()
        if partOfSpeechAsShort {
            for i in 0..<posLength {
                let feature = bufferEntry.tokenInfos[i + TokenInfoDictionary.TOKEN_INFO_OFFSET]
                result.append(posValues.get(Int(feature)))
            }
        } else {
            for i in 0..<posLength {
                let feature = Int8(truncatingBitPattern: bufferEntry.tokenInfos[i + TokenInfoDictionary.TOKEN_INFO_OFFSET])
                result.append(posValues.get(Int(feature)))
            }
        }
        result.append(contentsOf: bufferEntry.featureInfos.map { (feature) -> String in
            stringValues.get(feature)
        })
        return result
    }
    
    func getFeature(_ wordId: Int, fields: [Int]) -> String {
        if fields.count == 1 {
            return extractSingleFeature(wordId, field: fields.first!)
        }
        return extractMultipleFeatures(wordId, fields: fields)
    }
    
    public func extractSingleFeature(_ wordId: Int, field: Int) -> String {
        let featureId: Int
        if tokenInfoBuffer.isPartOfSpeechFeature(field) {
            featureId = tokenInfoBuffer.lookupPartOfSpeechFeature(wordId, field)
            return posValues.get(featureId)
        }
        featureId = tokenInfoBuffer.lookupFeature(wordId, field)
        return stringValues.get(featureId)
    }
    
    public func extractMultipleFeatures(_ wordId: Int, fields: [Int]) -> String {
        if fields.count == 0 {
            return getAllFeatures(wordId)
        }
        if fields.count == 1 {
            return extractSingleFeature(wordId, field: fields.first!)
        }
        let allFeatures: [String] = getAllFeatures(wordId)
        return fields.map({ featureNumber in
            CSVParser.escape(allFeatures[featureNumber])
        }).joined(separator: TokenInfoDictionary.FEATURE_SEPARATOR)
    }
    
    init?(_ resolver: ResourceResolver) {
        guard
            let tokenInfoDictionaryInput = resolver.resolve(TokenInfoDictionary.TOKEN_INFO_DICTIONARY_FILENAME),
            let featureMapInput = resolver.resolve(TokenInfoDictionary.FEATURE_MAP_FILENAME),
            let posMapInput = resolver.resolve(TokenInfoDictionary.POS_MAP_FILENAME),
            let targetMapInput = resolver.resolve(TokenInfoDictionary.TARGETMAP_FILENAME)
        else {
            return nil
        }
            
        tokenInfoBuffer = TokenInfoBuffer(tokenInfoDictionaryInput)
        stringValues = StringValueMapBuffer(featureMapInput)
        posValues = StringValueMapBuffer(posMapInput)
        wordIdMap = WordIdMap(targetMapInput)
    }
}
