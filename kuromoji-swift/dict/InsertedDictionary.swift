//
//  InsertedDictionary.swift
//  kuromoji-swift
//
//  Created by Jean-Luc Dagon on 08/12/2016.
//  Copyright © 2016 Cocoapps. All rights reserved.
//

import Foundation

class InsertedDictionary: DictionaryType {
    
    private static let DEFAULT_FEATURE = "*"
    private static let FEATURE_SEPARATOR = ","
    private var featuresArray: [String];
    private let featuresString: String
    
    init(features: Int) {
        featuresArray = [String](repeating: InsertedDictionary.DEFAULT_FEATURE, count: features)
        featuresString = featuresArray.joined(separator: InsertedDictionary.FEATURE_SEPARATOR)
    }
    
    func getLeftId(_ wordId: Int) -> Int {
        return 0
    }
    
    func getRightId(_ wordId: Int) -> Int {
        return 0
    }
    
    func getWordCost(_ wordId: Int) -> Int {
        return 0
    }
    
    func getAllFeatures(_ wordId: Int) -> String {
        return featuresString
    }
    
    func getAllFeatures(_ wordId: Int) -> [String] {
        return featuresArray
    }
    
    func getFeature(_ wordId: Int, fields: [Int]) -> String {
        return [String](repeating: InsertedDictionary.DEFAULT_FEATURE, count: fields.count)
            .joined(separator: InsertedDictionary.FEATURE_SEPARATOR)
    }
}
