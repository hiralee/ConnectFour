import XCTest
@testable import ConnectFour

class ConnectFourModelTests: XCTestCase {
    var board: Board?

    override func setUp() {
        super.setUp()
        board = Board()
    }

    func testNumberOfColumnsInBoard() {
        XCTAssertEqual(board?.columns.count, maxNumberOfColumns)
    }

    func testCounterExistsAtGivenIndexPath() {
        let newCounter = PlayingCounter(colour: .none)
        board?.columns[0].add(newCounter)
        let indexPath = IndexPath(item: 0, section: 5)
        XCTAssertTrue(board!.counterExists(at: indexPath))
    }

    func testCounterExistsAtGivenBoardPosition() {
        let newCounter = PlayingCounter(colour: .none)
        board?.columns[0].add(newCounter)
        let boardPosition = BoardPosition(column: 0, row: 0)
        XCTAssertTrue(board!.counterExists(at: boardPosition))
    }

    func testCounterIsReturnedAfterAdded() {
        let newCounter = PlayingCounter(colour: .none)
        board?.columns[0].add(newCounter)
        let indexPath = IndexPath(item: 0, section: 5)

        guard let returnedCounter = board?.counter(at: indexPath) else {
            XCTFail()
            return
        }
        XCTAssertEqual(returnedCounter.colour, newCounter.colour)
    }

    func testCounterStatusSameAdAddedCounterStatus() {
        let newCounter = PlayingCounter(colour: .colorWin)
        board?.columns[1].add(newCounter)
        let indexPath = IndexPath(item: 1, section: 5)
        guard let counterColorStatus = board?.counterStatus(at: indexPath) else {
            XCTFail()
            return
        }
        XCTAssertEqual(counterColorStatus, newCounter.colour)
    }

    func testNextGeneratedOffsetInGivenDirection() {
        let counterOne = PlayingCounter(colour: .colorOne)
        let counterTwo = PlayingCounter(colour: .colorTwo)
        board?.columns[0].add(counterOne)
        board?.columns[1].add(counterTwo)

        let boardPositionOne = BoardPosition(column: 0, row: 0)
        let offset = BoardPosition(column: 1, row: 0)

        let returnedBoardPosition = board?.generateNextOffset(from: boardPositionOne, inDirection: offset)

        XCTAssertEqual(returnedBoardPosition?.column, 1)
        XCTAssertEqual(returnedBoardPosition?.row, 0)
    }

    override func tearDown() {
        super.tearDown()
        board = nil
    }
}
