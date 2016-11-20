//
//  ScriptUtils.swift
//  kuromoji-swift
//
//  Created by Jean-Luc Dagon on 15/11/2016.
//  Copyright © 2016 Cocoapps. All rights reserved.
//

import Foundation

public extension Character {
    public enum UnicodeBlock {
        case HIRAGANA
        case KATAKANA
        case OTHER
        
        func range() -> Range<UInt16> {
            switch self {
            case .HIRAGANA: return Range<UInt16>(uncheckedBounds:(0x3040, 0x309F))
            case .KATAKANA: return Range<UInt16>(uncheckedBounds:(0x30A0, 0x30FF))
            case .OTHER: return Range(uncheckedBounds: (0, 0))
            }
        }
    }
    
    public func isOfUnicodeBlock(_ block: UnicodeBlock) -> Bool {
        return block.range().contains(UInt16(self.unicodeScalarCodePoint))
    }
    
    public func isHiragana() -> Bool {
        return self.isOfUnicodeBlock(.HIRAGANA)
    }
    
    public func isFullWidthKatakana() -> Bool {
        return self.isOfUnicodeBlock(.KATAKANA)
    }
    
    public var unicodeScalarCodePoint: UInt32 {
        get {
            return String(self).unicodeScalars.first!.value
        }
    }
    
}

public extension String {
    
    public func isKatakana() -> Bool {
        for c in self.characters {
            if !c.isFullWidthKatakana() {
                return false
            }
        }
        return true
    }
    
    public func isHiragana() -> Bool {
        for c in self.characters {
            if !c.isHiragana() {
                return false
            }
        }
        return true
    }
}
