//
//  UnknownDictionary.swift
//  kuromoji-swift
//
//  Created by Jean-Luc Dagon on 28/11/2016.
//  Copyright © 2016 Cocoapps. All rights reserved.
//

import Foundation

class UnknownDictionary: DictionaryType {
    
    public static let UNKNOWN_DICTIONARY_FILENAME = "unknownDictionary.bin"
    private static let DEFAULT_FEATURE = "*"
    private static let FEATURE_SEPARATOR = ","
    
    private final var entries: [[Int]]
    private final var costs: [[Int]]
    private final var features: [[String]]
    private final var totalFeatures: Int
    
    private final var characterDefinition: CharacterDefinitions!
    
    public init(characterDefinition: CharacterDefinitions,
                entries: [[Int]],
                costs: [[Int]],
                features: [[String]],
                totalFeatures: Int)
    {
        self.characterDefinition = characterDefinition
        self.entries = entries
        self.costs = costs
        self.features = features
        self.totalFeatures = totalFeatures
    }
    
    convenience public init(characterDefinition: CharacterDefinitions,
                entries: [[Int]],
                costs: [[Int]],
                features: [[String]])
    {
        self.init(characterDefinition: characterDefinition,
                  entries: entries,
                  costs: costs,
                  features: features,
                  totalFeatures: features.count)
    }
    
    convenience public init(resolver: SimpleResourceResolver,
                            characterDefinition: CharacterDefinitions,
                            totalFeatures: Int)
    {
        let unkDefInput = resolver.resolve(UnknownDictionary.UNKNOWN_DICTIONARY_FILENAME)!
        let costs = IntegerArrayIO.readArray2D(unkDefInput)
        let references = IntegerArrayIO.readArray2D(unkDefInput)
        let features = StringArrayIO.readArray2D(unkDefInput)
        self.init(characterDefinition: characterDefinition,
                  entries: references,
                  costs: costs,
                  features: features,
                  totalFeatures: totalFeatures)
    }
    
    public func lookupWordIds(_ categoryId: Int) -> [Int] {
        return entries[categoryId]
    }
    
    func getLeftId(_ wordId: Int) -> Int {
        return costs[wordId][0]
    }
    
    func getRightId(_ wordId: Int) -> Int {
        return costs[wordId][1]
    }
    
    func getWordCost(_ wordId: Int) -> Int {
        return costs[wordId][2]
    }
    
    func getAllFeatures(_ wordId: Int) -> String {
        return getAllFeatures(wordId).joined(separator: UnknownDictionary.FEATURE_SEPARATOR)
    }
    
    func getAllFeatures(_ wordId: Int) -> [String] {
        if totalFeatures == features.count {
            return features[wordId]
        }
        let basicFeatures = features[wordId]
        let allFeatures = basicFeatures + repeatElement(UnknownDictionary.DEFAULT_FEATURE, count: totalFeatures - basicFeatures.count)
        return allFeatures
    }
    
    func getFeature(_ wordId: Int, fields: [Int]) -> String {
        let allFeatures: [String] = getAllFeatures(wordId)
        let features = fields.map({ featureNumber in
            return allFeatures[featureNumber]
        })
        return features.joined(separator: UnknownDictionary.FEATURE_SEPARATOR)
    }
    
    public func getCharacterDefinition() -> CharacterDefinitions {
        return characterDefinition
    }
    
    
}
