import XCTest
@testable import XcodeSpellCheckerCore

final class WordFinderTests: XCTestCase {
    func testEmpty() {
        let wordFinder = WordFinder(sentence: "", url: URL(string: "https://example.com/")!, line: 10)
        XCTAssertEqual(wordFinder.findWords(), [])
    }

    func testSpace() {
        let wordFinder = WordFinder(sentence: " ", url: URL(string: "https://example.com/")!, line: 10)
        XCTAssertEqual(wordFinder.findWords(), [])
    }

    func testAlnum() {
        let wordFinder = WordFinder(sentence: "abc", url: URL(string: "https://example.com/")!, line: 10)
        XCTAssertEqual(wordFinder.findWords(), [
            WordEntity(url: URL(string: "https://example.com/")!, line: 10, position: 0, word: "abc")
        ])
    }

    func testSnakeCase() {
        let wordFinder = WordFinder(sentence: " abc_def ", url: URL(string: "https://example.com/")!, line: 10)
        XCTAssertEqual(wordFinder.findWords(), [
            WordEntity(url: URL(string: "https://example.com/")!, line: 10, position: 1, word: "abc"),
            WordEntity(url: URL(string: "https://example.com/")!, line: 10, position: 5, word: "def")
        ])
    }

    func testCamelCase() {
        let wordFinder = WordFinder(sentence: " abcDefGhi ", url: URL(string: "https://example.com/")!, line: 10)
        XCTAssertEqual(wordFinder.findWords(), [
            WordEntity(url: URL(string: "https://example.com/")!, line: 10, position: 1, word: "abc"),
            WordEntity(url: URL(string: "https://example.com/")!, line: 10, position: 4, word: "Def"),
            WordEntity(url: URL(string: "https://example.com/")!, line: 10, position: 7, word: "Ghi")
        ])
    }

    func testNumber() {
        let wordFinder = WordFinder(sentence: " abc1DefGhi ", url: URL(string: "https://example.com/")!, line: 10)
        XCTAssertEqual(wordFinder.findWords(), [
            WordEntity(url: URL(string: "https://example.com/")!, line: 10, position: 1, word: "abc"),
            WordEntity(url: URL(string: "https://example.com/")!, line: 10, position: 5, word: "Def"),
            WordEntity(url: URL(string: "https://example.com/")!, line: 10, position: 8, word: "Ghi")
        ])
    }

    func testConsecutiveUpperCase() {
        let wordFinder = WordFinder(sentence: " abcDEFGhiJKL ", url: URL(string: "https://example.com/")!, line: 10)
        XCTAssertEqual(wordFinder.findWords(), [
            WordEntity(url: URL(string: "https://example.com/")!, line: 10, position: 1, word: "abc"),
            WordEntity(url: URL(string: "https://example.com/")!, line: 10, position: 4, word: "DEF"),
            WordEntity(url: URL(string: "https://example.com/")!, line: 10, position: 7, word: "Ghi"),
            WordEntity(url: URL(string: "https://example.com/")!, line: 10, position: 10, word: "JKL")
        ])
    }

    static var allTests = [
        ("testEmpty", testEmpty),
        ("testSpace", testSpace),
        ("testAlnum", testAlnum),
        ("testSnakeCase", testSnakeCase),
        ("testCamelCase", testCamelCase),
        ("testNumber", testNumber),
        ("testConsecutiveUpperCase", testConsecutiveUpperCase)
    ]
}
