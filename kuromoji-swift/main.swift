//
//  main.swift
//  kuromoji-swift
//
//  Created by Jean-Luc Dagon on 14/11/2016.
//  Copyright © 2016 Cocoapps. All rights reserved.
//

import Foundation



func getEnvironmentVar(_ name: String) -> String? {
    guard let rawValue = getenv(name) else { return nil }
    return String(utf8String: rawValue)
}

let BaseDir = getEnvironmentVar("BASE_DIR")!
let InputDir = BaseDir + "/tests/input"
let OutputDir = BaseDir + "/tests/output"


let charDefPath = InputDir + "/char.def"
let charDefCompiler = CharacterDefinitionsCompiler(OutputStream(toFileAtPath: OutputDir + "/swift-compiled-char-def.data", append: false)!)
charDefCompiler.readCharacterDefinition(at: charDefPath, encoding: .japaneseEUC)
charDefCompiler.compile()

let unkDefPath = InputDir + "/unk.def"
let unkDicCompiler = UnknownDictionaryCompiler(categoryMap: charDefCompiler.makeCharacterCategoryMap(),
                                               outputStream: OutputStream(toFileAtPath: OutputDir + "/swift-compiled-unk-def.data", append: false)!)

unkDicCompiler.readUnknownDefinitions(at: unkDefPath, encoding: .japaneseEUC)
unkDicCompiler.compile()
