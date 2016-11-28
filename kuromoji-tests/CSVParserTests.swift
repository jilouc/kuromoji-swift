//
//  CSVParserTests.swift
//  kuromoji-swift
//
//  Created by Jean-Luc Dagon on 27/11/2016.
//  Copyright © 2016 Cocoapps. All rights reserved.
//

import XCTest

class CSVParserTests: XCTestCase {

    var parser: CSVParser!
    
    override func setUp() {
        super.setUp()
    }
    
    func testTrivial() {
        let strings = ["日本経済新聞", "日本 経済 新聞", "ニホン ケイザイ シンブン", "カスタム名詞"]
        let parser = CSVParser("日本経済新聞,日本 経済 新聞,ニホン ケイザイ シンブン,カスタム名詞")
        let records = try! parser.parse()
        XCTAssertEqual(records.count, 1)
        XCTAssertEqual(records.first!, strings)
    }

    func testQuotes() {
        let strings = [
            "Swift, safe, fast & expressive",
            "Swift, safe, fast & expressive",
            "Swift, safe, fast & expressive",
            "カスタム名詞"
        ]
        let parser = CSVParser("\"Swift, safe, fast & expressive\",\"Swift, safe, fast & expressive\",\"Swift, safe, fast & expressive\",カスタム名詞")
        let records = try! parser.parse()
        XCTAssertEqual(records.count, 1)
        XCTAssertEqual(records.first!, strings)
    }
    
    func testQuotedQuotes() {
        let strings = [
            "Swift \"language\"",
            "Swift \"language\"",
            "Swift \"language\"",
            "カスタム名詞"
        ]
        let parser = CSVParser("\"Swift \"\"language\"\"\",\"Swift \"\"language\"\"\",\"Swift \"\"language\"\"\",カスタム名詞")
        let records = try! parser.parse()
        XCTAssertEqual(records.count, 1)
        XCTAssertEqual(records.first!, strings)
    }
    
    func testEmptyQuotedQuotes() {
        let strings = [
            "\"",
            "\"",
            "quote",
            "punctuation"
        ]
        let parser = CSVParser("\"\"\"\",\"\"\"\",quote,punctuation")
        let records = try! parser.parse()
        XCTAssertEqual(records.count, 1)
        XCTAssertEqual(records.first!, strings)
    }

    func testCSharp() {
        let strings = [
            "C#",
            "C #",
            "シーシャープ",
            "プログラミング言語"
        ]
        let parser = CSVParser("\"C#\",\"C #\",シーシャープ,プログラミング言語")
        let records = try! parser.parse()
        XCTAssertEqual(records.count, 1)
        XCTAssertEqual(records.first!, strings)
    }
    
    func testTab() {
        let strings = [
            "A\tB",
            "A B",
            "A B",
            "tab"
        ]
        let parser = CSVParser("A\tB,A B,A B,tab")
        let records = try! parser.parse()
        XCTAssertEqual(records.count, 1)
        XCTAssertEqual(records.first!, strings)
    }
    
    func testUnmatchedDoubleQuote() {
        let parser = CSVParser("\"this is an entry with unmatched quote")
        XCTAssertThrowsError(try parser.parse())
    }
    
    func testEscapeRoundTrip() {
        let original = "3,\"14"
        XCTAssertEqual("\"3,\"\"14\"", CSVParser.escape(original))
        XCTAssertEqual(original, CSVParser.parseField(CSVParser.escape(original))!)
    }
    
    func testUnescape() {
        XCTAssertEqual("A", CSVParser.parseField("\"A\"")!)
        XCTAssertEqual("\"A\"", CSVParser.parseField("\"\"\"A\"\"\"")!)
        
        XCTAssertEqual("\"", CSVParser.parseField("\"\"\"\"")!)
        XCTAssertEqual("\"\"", CSVParser.parseField("\"\"\"\"\"\"")!)
        XCTAssertEqual("\"\"\"", CSVParser.parseField("\"\"\"\"\"\"\"\"")!)
        XCTAssertEqual("\"\"\"\"\"", CSVParser.parseField("\"\"\"\"\"\"\"\"\"\"\"\"")!)
    }
    
    func testParseInputString() {
        let input = "日本経済新聞,1292,1292,4980,名詞,固有名詞,組織,*,*,*,日本経済新聞,ニホンケイザイシンブン,ニホンケイザイシンブン"
        let expected = ["日本経済新聞", "1292", "1292", "4980", "名詞", "固有名詞", "組織", "*", "*", "*", "日本経済新聞", "ニホンケイザイシンブン", "ニホンケイザイシンブン"];
        XCTAssertEqual(expected, CSVParser.parseRecord(input)!)
    }
    
    func testParseInputStringWithQuotes() {
        let input = "日本経済新聞,1292,1292,4980,名詞,固有名詞,組織,*,*,\"1,0\",日本経済新聞,ニホンケイザイシンブン,ニホンケイザイシンブン"
        let expected = ["日本経済新聞", "1292", "1292", "4980", "名詞", "固有名詞", "組織", "*", "*", "1,0", "日本経済新聞", "ニホンケイザイシンブン", "ニホンケイザイシンブン"];
        XCTAssertEqual(expected, CSVParser.parseRecord(input)!)
    }
    
    func testQuoteEscape() {
        let input = "日本経済新聞,1292,1292,4980,名詞,固有名詞,組織,*,*,\"1,0\",日本経済新聞,ニホンケイザイシンブン,ニホンケイザイシンブン"
        let expected = "\"日本経済新聞,1292,1292,4980,名詞,固有名詞,組織,*,*,\"\"1,0\"\",日本経済新聞,ニホンケイザイシンブン,ニホンケイザイシンブン\""
        XCTAssertEqual(expected, CSVParser.escape(input))
    }
}
