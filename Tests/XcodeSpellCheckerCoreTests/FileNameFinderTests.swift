import XCTest
@testable import XcodeSpellCheckerCore

final class FileNameFinderTests: XCTestCase {
    func testFindFileName() {
        let filePath = "/Users/HomeDirectory/Swift/XcodeSpellChecker/XcodeSpellChecker.xcodeproj"
        XCTAssertEqual(FileNameFinder().findFileName(fileArray: [filePath]), ["XcodeSpellChecker"])
    }

    func testFindFileNameWithoutExtension() {
        let filePath = "/Users/HomeDirectory/Swift/XcodeSpellChecker/XcodeSpellChecker"
        XCTAssertEqual(FileNameFinder().findFileName(fileArray: [filePath]), ["XcodeSpellChecker"])
    }

    static var allTests = [
        ("testFindFileName", testFindFileName),
        ("testFindFileNameWithoutExtension", testFindFileNameWithoutExtension)
    ]
}
