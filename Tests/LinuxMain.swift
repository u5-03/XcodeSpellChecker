import XCTest

import XcodeSpellCheckerTests

var tests = [XCTestCaseEntry]()
tests += CommandsTests.allTests()
tests += WordFinderTests.allTests()
tests += FileNameFinderTests.allTests()
XCTMain(tests)
