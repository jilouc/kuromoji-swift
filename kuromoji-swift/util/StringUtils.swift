//
//  StringUtils.swift
//  kuromoji-swift
//
//  Created by Jean-Luc Dagon on 17/11/2016.
//  Copyright © 2016 Cocoapps. All rights reserved.
//

import Foundation

extension String {
    
    func replace(_ pattern: String, with replacement: String) -> String {
        let regex = try! NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        return regex.stringByReplacingMatches(in: self, options:[], range: NSMakeRange(0, self.characters.count), withTemplate: replacement)
    }
    
    func separatedBySpaces() -> [String] {
        return self.components(separatedBy: .whitespaces).filter {
            return $0.characters.count != 0
        }
    }
    
    func scanHexInt32() -> UInt32? {
        return Scanner(string: self).scanHexInt32()
    }
}

extension Scanner {
    
    func scanHexInt32() -> UInt32? {
        var value: UInt32 = 0
        if scanHexInt32(&value) {
            return value
        }
        return nil
    }
    
    func scanCharacters(from set: CharacterSet) -> String? {
        var value: NSString? = ""
        if scanCharacters(from: set, into: &value),
            let value = value as? String {
            return value
        }
        return nil
    }
    
    func scanUpToCharacters(from set: CharacterSet) -> String? {
        var value: NSString? = ""
        if scanUpToCharacters(from: set, into: &value),
            let value = value as? String {
            return value
        }
        return nil
    }
    
    func scanUpToString(_ string: String) -> String? {
        var value: NSString? = ""
        if scanUpTo(string, into: &value),
            let value = value as? String {
            return value
        }
        return nil
    }
}
