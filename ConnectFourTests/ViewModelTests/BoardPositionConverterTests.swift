import XCTest
@testable import ConnectFour

class BoardPositionConverterTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }

    func testBoardPositionFromIndexPath() {
        let boardPosition = BoardPosition(column: 0, row: 0)
        let indexpath = IndexPath(item: 0, section: 5)

        let newBoardPosition = BoardPositionConverter.modelPosition(for: indexpath)
        XCTAssertEqual(boardPosition.column, newBoardPosition.column)
        XCTAssertEqual(boardPosition.row, newBoardPosition.row)
    }

    func testIndexPathFromBoardPosition() {
        let indexpath = IndexPath(item: 0, section: 5)
        let boardPosition = BoardPosition(column: 0, row: 0)

        let newIndexPath = BoardPositionConverter.viewPosition(for: boardPosition)
        XCTAssertEqual(indexpath.item, newIndexPath.item)
        XCTAssertEqual(indexpath.section, newIndexPath.section)
    }

    override func tearDown() {
        super.tearDown()
    }
}
