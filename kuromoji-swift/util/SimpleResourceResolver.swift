//
//  SimpleResourceResolver.swift
//  kuromoji-swift
//
//  Created by Jean-Luc Dagon on 27/11/2016.
//  Copyright © 2016 Cocoapps. All rights reserved.
//

import Foundation

class SimpleResourceResolver: ResourceResolver {
    
    func resolve(_ filePath: String) -> InputStream? {
        return InputStream(fileAtPath: filePath)
    }
}
