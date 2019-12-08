import XCTest
@testable import XcodeSpellCheckerCore

final class CommandsTests: XCTestCase {
    let filePaths = "/A/a.txt:/A/b.txt:/A/B/c.txt:/A/B/d.txt:/C/e.txt:/C/D/f.txt"
    override func setUp() {
        super.setUp()
        Commands.arguments = ["Commands", "-a", "hello", "--files", "/A/a.txt", "/A/b.txt", "/A/B/c.txt", "/A/B/d.txt", "/C/e.txt", "/C/D/f.txt", "--h"]
    }

    func testHasOption() {
        XCTAssertTrue(Commands.has("a"))
    }

    func testValue() {
        XCTAssertEqual(Commands.value(of: "a"), "hello")
        XCTAssertNil(Commands.value(of: "b"))
    }

    func testArray() {
        XCTAssertEqual(Commands.filePathArray(filePaths: filePaths), ["/A/a.txt", "/A/b.txt", "/A/B/c.txt", "/A/B/d.txt", "/C/e.txt", "/C/D/f.txt"])
    }

    func testIncluedPathArray() {
        let includePath = ["A/B/", "C/D/"]
        let filePathArray = Commands.filePathArray(filePaths: filePaths, includePath: includePath)
        XCTAssertEqual(filePathArray, ["/A/B/c.txt", "/A/B/d.txt", "/C/D/f.txt"])
    }

    func testExcluedPathArray() {
        let excludePath = ["A/B/", "C/D/f.txt"]
        let filePathArray = Commands.filePathArray(filePaths: filePaths, excludePath: excludePath)
        XCTAssertEqual(filePathArray, ["/A/a.txt", "/A/b.txt", "/C/e.txt"])
    }

    func testIncludedAndExcluedPathArray() {
        let includePath = ["A/"]
        let excludePath = ["A/B/"]
        let filePathArray = Commands.filePathArray(filePaths: filePaths, includePath: includePath, excludePath: excludePath)
        XCTAssertEqual(filePathArray, ["/A/a.txt", "/A/b.txt"])
    }

    static var allTests = [
        ("testHasOption", testHasOption),
        ("testValue", testValue),
        ("testArray", testArray),
        ("testIncluedPathArray", testIncluedPathArray),
        ("testExcluedPathArray", testExcluedPathArray),
        ("testIncludedAndExcluedPathArray", testIncludedAndExcluedPathArray),
    ]
}
