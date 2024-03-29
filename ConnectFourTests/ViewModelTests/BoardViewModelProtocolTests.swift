import XCTest
@testable import ConnectFour

private class MockBoardViewController: NSObject {
    var viewModel: MockBoardViewModel?

    init(viewModel: MockBoardViewModel) {
        self.viewModel = viewModel
        super.init()
    }

    func startGame() {
        viewModel?.startGame()
    }

    func makeMove() {
        viewModel?.makeMove(indexPath: IndexPath(item: 0, section: 0))
    }

    func endGame() {
        viewModel?.endGame()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private class MockBoardViewModel: NSObject, BoardViewModelProtocol {
    var board: Board

    var startGameCalled = false
    var makeMoveCalled = false
    var endGameCalled = false

    override init() {
        board = Board()
    }

    func startGame() {
        startGameCalled = true
    }

    func makeMove(indexPath: IndexPath) {
        makeMoveCalled = true
    }

    func endGame() {
        endGameCalled = true
    }
}

class BoardViewModelProtocolTests: XCTestCase {
    fileprivate let mockBoardViewModel = MockBoardViewModel()
    fileprivate var view: MockBoardViewController?

    override func setUp() {
        super.setUp()

        view = MockBoardViewController(viewModel: mockBoardViewModel)
    }
    
    func testStartGameIsCalled() {
        view?.startGame()
        XCTAssertTrue(mockBoardViewModel.startGameCalled)
    }
    
    func testMakeMoveCalled() {
        view?.makeMove()
        XCTAssertTrue(mockBoardViewModel.makeMoveCalled)
    }
    
    func testEndGameIsCalled() {
        view?.endGame()
        XCTAssert(mockBoardViewModel.endGameCalled)
    }

    override func tearDown() {
        super.tearDown()
    }
}
