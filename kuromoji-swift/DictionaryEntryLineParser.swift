//
//  DictionaryEntryLineParser.swift
//  kuromoji-swift
//
//  Created by Jean-Luc Dagon on 20/11/2016.
//  Copyright © 2016 Cocoapps. All rights reserved.
//

import Foundation

public class DictionaryEntryLineParser {
    
    private static let QUOTE: Character = "\""
    private static let COMMA: Character = ","
    private static let QUOTE_ESCAPED = "\"\""
    
    public static func parseLine(_ line: String) -> [String] {
        let s = Scanner(string: line)
        return []
    }
}
