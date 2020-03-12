import XCTest
@testable import PrintfParser

final class PrintfParserTests: XCTestCase {
    func testPlainString() throws {
		XCTAssertEqual(try "hi".formatSpecifiers(), [])
    }
	
	func testSimpleObject() throws {
		let results = try "hi %@".formatSpecifiers()
		XCTAssertEqual(results.count, 1)
		let spec = try XCTUnwrap(results.first)
		XCTAssertEqual(spec.type, .cf)
	}
	
	func testMultipleSimpleObjects() throws {
		let results = try "%@, %@".formatSpecifiers()
		XCTAssertEqual(results.count, 2)
	}
	
	func testLocalized() throws {
		let results = try "%2$@ %1$@".formatSpecifiers()
		XCTAssertEqual(results.count, 2)
		XCTAssertEqual(results[0].mainArgNum, 1)
		XCTAssertEqual(results[1].mainArgNum, 0)
	}
	
	func testInteger() throws {
		let results = try "%d %1d %2d".formatSpecifiers()
		XCTAssertEqual(results.count, 3)
	}
	
	func testFloat() throws {
		let results = try "%2.2f".formatSpecifiers()
		XCTAssertEqual(results.count, 1)
		let spec = try XCTUnwrap(results.first)
		XCTAssertEqual(spec.type, .double)
		XCTAssertEqual(spec.precision, .value(2))
		XCTAssertEqual(spec.width, .value(2))
	}
	
	func testSiriString() throws {
		let results = try "${firstName} still has %#@numberOfRemainingTODOItems@ to complete.".formatSpecifiers()
		XCTAssertEqual(results.count, 1)
	}
	
	func testStringsDictKey() throws {
		let results = try "%#@special_key@.".formatSpecifiers()
		XCTAssertEqual(results.count, 1)
		let spec = try XCTUnwrap(results.first)
		XCTAssertEqual(spec.configKey, "special_key")
	}
	
	func testInvalid() {
		XCTAssertThrowsError(try "%".formatSpecifiers())
	}
	
	func testValid() {
		XCTAssertNoThrow(try "%%".formatSpecifiers())
	}
	
	/// This example is pulled from https://pubs.opengroup.org/onlinepubs/009695399/functions/printf.html
	func testOpenGroupExample() throws {
		let results = try "%1$d:%2$.*3$d:%4$.*3$d".formatSpecifiers()
		XCTAssertEqual(results.count, 3)
		
		XCTAssertEqual(results[0].mainArgNum, 0)
		
		XCTAssertEqual(results[1].mainArgNum, 1)
		XCTAssertEqual(results[1].precision, .index(2))
		
		XCTAssertEqual(results[2].mainArgNum, 3)
		XCTAssertEqual(results[2].precision, .index(2))
	}
}
