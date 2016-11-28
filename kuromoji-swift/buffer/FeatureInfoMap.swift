//
//  FeatureInfoMap.swift
//  kuromoji-swift
//
//  Created by Jean-Luc Dagon on 14/11/2016.
//  Copyright © 2016 Cocoapps. All rights reserved.
//

import Foundation

public struct FeatureInfoMap : CustomStringConvertible {
    
    var featureMap = [String: Int]()
    private var maxValue: Int = 0
    
    mutating public func mapFeatures(_ features: [String]) -> [Int] {
        var posFeatureIds = [Int]()
        for feature in features {
            if let posFeatureId = featureMap[feature] {
                posFeatureIds.append(posFeatureId)
            } else {
                featureMap[feature] = maxValue
                posFeatureIds.append(maxValue)
                maxValue += 1
            }
        }
        return posFeatureIds
    }
    
    public func invert() -> [Int: String] {
        var features = [Int: String]()
        for (key, value) in featureMap {
            features[value] = key
        }
        return features
    }
    
    public func getEntryCount() -> Int {
        return maxValue
    }
    
    public var description: String {
        return "FeatureInfoMap{featureMap=\(featureMap), maxValue=\(maxValue)}"
    }
}
