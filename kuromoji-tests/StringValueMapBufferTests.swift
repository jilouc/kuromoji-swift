//
//  StringValueMapBufferTests.swift
//  kuromoji-swift
//
//  Created by Jean-Luc Dagon on 27/11/2016.
//  Copyright © 2016 Cocoapps. All rights reserved.
//

import XCTest

class StringValueMapBufferTests: XCTestCase {

    func testInsertIntoMap() {
        let input = [
            1: "hello",
            2: "日本",
            3: "カタカナ",
            0: "Bye"
        ]
        
        let values = StringValueMapBuffer(input)
        XCTAssertEqual("Bye", values.get(0))
        XCTAssertEqual("hello", values.get(1))
        XCTAssertEqual("日本", values.get(2))
        XCTAssertEqual("カタカナ", values.get(3))
    }

}
