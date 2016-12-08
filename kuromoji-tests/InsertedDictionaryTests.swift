//
//  InsertedDictionaryTests.swift
//  kuromoji-swift
//
//  Created by Jean-Luc Dagon on 08/12/2016.
//  Copyright © 2016 Cocoapps. All rights reserved.
//

import XCTest

class InsertedDictionaryTests: XCTestCase {

    func testFeatureSize() {
        let dictionary1 = InsertedDictionary(features: 9)
        let dictionary2 = InsertedDictionary(features: 5)
    
        XCTAssertEqual("*,*,*,*,*,*,*,*,*", dictionary1.getAllFeatures(0))
        XCTAssertEqual("*,*,*,*,*", dictionary2.getAllFeatures(0))
    
        XCTAssertEqual(["*", "*", "*", "*", "*", "*", "*", "*", "*"], dictionary1.getAllFeatures(0))
        XCTAssertEqual(["*", "*", "*", "*", "*"], dictionary2.getAllFeatures(0))
    }

}
