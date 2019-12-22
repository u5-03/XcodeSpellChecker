import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(CommandsTests.allTests),
        testCase(WordFinderTests.allTests),
        testCase(FileNameFinderTests.allTests)
    ]
}
#endif
