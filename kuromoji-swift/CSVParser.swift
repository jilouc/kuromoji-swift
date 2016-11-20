//
//  CSVParser.swift
//  kuromoji-swift
//
//  Created by Jean-Luc Dagon on 20/11/2016.
//  Copyright © 2016 Cocoapps. All rights reserved.
//

import Foundation

public class CSVParser {
    
    private static let QUOTE = "\""
    private static let COMMA = ","
    private static let QUOTE_ESCAPED = "\"\""
    
    private let separator: String
    private let string: String
    private let scanner: Scanner
    private let endTextCharacterSet: CharacterSet
    private let separatorIsSingleChar: Bool
    
    init(_ string: String, separator: String = CSVParser.COMMA) {
        self.string = string
        self.separator = separator
        self.separatorIsSingleChar = separator.characters.count == 1
        
        self.scanner = Scanner(string: self.string)
        scanner.charactersToBeSkipped = CharacterSet()
        
        var endTextCharSet = CharacterSet.newlines
        endTextCharSet.insert(charactersIn: CSVParser.QUOTE)
        endTextCharSet.insert(separator.unicodeScalars.first!)
        endTextCharacterSet = endTextCharSet
    }
    
    public func parse() -> [[String]] {
        return parseFile()
    }
    
    private func parseFile() -> [[String]] {
        var records = [[String]]()
        var record = parseRecord()
        while record != nil {
            records.append(record!)
            if parseLineSeparator() == nil {
                break
            }
            record = parseRecord()
        }
        return records
    }
    
    private func parseRecord() -> [String]? {
        if parseLineSeparator() != nil || scanner.isAtEnd {
            return nil
        }
        var field = parseField()
        var record = [String]()
        
        while field != nil {
            record.append(field!)
            if parseSeparator() == nil {
                break
            }
            field = parseField()
        }
        return record
    }
    
    private func parseField() -> String? {
        if let escapedString = parseEscaped() {
            return escapedString
        }
        if let nonEscapedString = parseNonEscaped() {
            return nonEscapedString
        }
        let currentLocation = scanner.scanLocation
        if parseSeparator() != nil || parseLineSeparator() != nil || scanner.isAtEnd {
            scanner.scanLocation = currentLocation
            return ""
        }
        return nil
    }
    
    private func parseEscaped() -> String? {
        if parseDoubleQuote() == nil {
            return nil
        }
        var accumulatedString = ""
        while true {
            var fragment = parseTextData()
            if fragment == nil {
                fragment = parseSeparator()
                if fragment == nil {
                    fragment = parseLineSeparator()
                    if fragment == nil {
                        if parseTwoDoubleQuotes() != nil {
                            fragment = CSVParser.QUOTE
                        } else {
                            break
                        }
                    }
                }
            }
            if let fragment = fragment {
                accumulatedString.append(fragment)
            }
        }
        if parseDoubleQuote() == nil {
            return nil
        }
        return accumulatedString
    }
    
    private func parseNonEscaped() -> String? {
        return parseTextData()
    }
    
    private func parseTwoDoubleQuotes() -> String? {
        if scanner.scanString(CSVParser.QUOTE_ESCAPED, into: nil) {
            return CSVParser.QUOTE_ESCAPED
        }
        return nil
    }
    
    private func parseDoubleQuote() -> String? {
        if scanner.scanString(CSVParser.QUOTE, into: nil) {
            return CSVParser.QUOTE
        }
        return nil
    }
    
    private func parseSeparator() -> String? {
        if scanner.scanString(separator, into: nil) {
            return separator
        }
        return nil
    }
    
    private func parseLineSeparator() -> String? {
        return scanner.scanCharacters(from: .newlines)
    }
    
    private func parseTextData() -> String? {
        var accumulatedText = ""
        while true {
            if let fragment = scanner.scanUpToCharacters(from: endTextCharacterSet) {
                accumulatedText.append(fragment)
            }
            if separatorIsSingleChar {
                break
            }
            let location = scanner.scanLocation
            var firstCharOfSeparator: NSString?
            if scanner.scanString(separator.substring(to: separator.index(separator.startIndex, offsetBy: 1)), into: &firstCharOfSeparator) {
                if scanner.scanString(separator.substring(from: separator.index(separator.startIndex, offsetBy: 1)), into: nil) {
                    scanner.scanLocation = location
                    break
                }
                accumulatedText.append(firstCharOfSeparator as! String)
            }
        }
        return accumulatedText
    }
}
