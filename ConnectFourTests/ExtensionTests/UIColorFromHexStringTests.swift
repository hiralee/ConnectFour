import XCTest
@testable import ConnectFour

class UIColorFromHexStringTests: XCTestCase {
    var testColorHex: String?

    override func setUp() {
        super.setUp()
        testColorHex = "#0000FF"
    }

    func testUIColorFromHexString() {
        let color = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
        let testColor = UIColor.init(hexString: testColorHex ?? "")
        XCTAssertEqual(color, testColor)
    }

    override func tearDown() {
        super.setUp()
        testColorHex = nil
    }
}
