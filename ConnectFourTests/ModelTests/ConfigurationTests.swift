import XCTest
@testable import ConnectFour

class ConfigurationTests: XCTestCase {
    var configuration: Configuration?
    let jsonDataWithAllValues = Data("""
    [
        {
            "id":1234567890,
            "color1":"#FF0000",
            "color2":"#0000FF",
            "name1":"Sue",
            "name2":"Henry"
        }
    ]
    """.utf8)

    let jsonDataWithoutName1 = Data("""
    [
        {
            "id":1234567890,
            "color1":"#FF0000",
            "color2":"#0000FF",
            "name2":"Henry"
        }
    ]
    """.utf8)

    override func setUp() {
        super.setUp()
        
    }

    func testConfigurationForCorrectData() {
        do {
            let configArray = try JSONDecoder().decode([Configuration].self, from: jsonDataWithAllValues)
            configuration = configArray[0]
        } catch {
            XCTFail()
        }

        XCTAssertEqual(configuration?.id, 1234567890)
        XCTAssertEqual(configuration?.color1, "#FF0000")
        XCTAssertEqual(configuration?.color2, "#0000FF")
        XCTAssertEqual(configuration?.name1, "Sue")
        XCTAssertEqual(configuration?.name2, "Henry")
    }

    func testConfigurationWithoutName() {
        do {
            let configArray = try JSONDecoder().decode([Configuration].self, from: jsonDataWithoutName1)
            configuration = configArray[0]
        } catch {
            XCTAssertNil(configuration)
        }
    }

    override func tearDown() {
        super.tearDown()
        configuration = nil
    }
}
