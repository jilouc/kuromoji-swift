//
//  DictionaryType.swift
//  kuromoji-swift
//
//  Created by Jean-Luc Dagon on 26/11/2016.
//  Copyright © 2016 Cocoapps. All rights reserved.
//

import Foundation

protocol DictionaryType {
    
    func getLeftId(_ wordId: Int) -> Int
    func getRightId(_ wordId: Int) -> Int
    func getWordCost(_ wordId: Int) -> Int
    func getAllFeatures(_ wordId: Int) -> String
    func getAllFeatures(_ wordId: Int) -> [String]
    func getFeature(_ wordId: Int, fields: [Int]) -> String
    
}
