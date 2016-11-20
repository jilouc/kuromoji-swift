//
//  BufferEntry.swift
//  kuromoji-swift
//
//  Created by Jean-Luc Dagon on 14/11/2016.
//  Copyright © 2016 Cocoapps. All rights reserved.
//

import Foundation

public struct BufferEntry {
    
    var tokenInfo = [UInt16]()
    var features = [UInt32]()
    var posInfo = [UInt8]()
    var tokenInfos = [UInt16]()
    var featureInfos = [UInt32]()
    var posInfos = [UInt8]()
    
}
