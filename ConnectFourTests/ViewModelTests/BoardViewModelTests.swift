import XCTest
@testable import ConnectFour

private class MockFetchConfiguration: FetchConfigurationProtocol {
    var fetchConfigurationCalled = false

    func fetchRemoteConfiguration(_ completion: @escaping (Configuration?, Error?) -> ()) {
        let config = Configuration(id: 1, color1: "color1", color2: "color2", name1: "name1", name2: "name2")
        fetchConfigurationCalled = true
        completion(config, nil)
    }
}

private class MockBoardViewController: BoardViewProtocol {
    var initializeBoardViewWithPlayersCalled = false
    var setInterfaceForPlayingCalled = false
    var setInterfaceForGameOverCalled = false
    var updateGameStatusLabelCalled = false
    var reloadBoardPositionCalled = false
    var reloadBoardCalled = false
    var showErrorCalled = false

    func initializeBoardViewWithPlayers(playerOne: Player?, playerTwo: Player?) {
        initializeBoardViewWithPlayersCalled = true
    }

    func setInterfaceForPlaying() {
        setInterfaceForPlayingCalled = true
    }

    func setInterfaceForGameOver() {
        setInterfaceForGameOverCalled = true
    }

    func updateGameStatusLabel(with message: String) {
        updateGameStatusLabelCalled = true
    }

    func reloadBoardPosition(at indexPath: IndexPath) {
        reloadBoardPositionCalled = true
    }

    func reloadBoard() {
        reloadBoardCalled = true
    }

    func showError(error: Error) {
        showErrorCalled = true
    }
}

class BoardViewModelTests: XCTestCase {
    var viewModel: BoardViewModel?
    fileprivate let view = MockBoardViewController()
    fileprivate let fetchConfiguration = MockFetchConfiguration()

    override func setUp() {
        super.setUp()
        viewModel = BoardViewModel(view: view, fetchConfiguration: fetchConfiguration)
    }

    func testViewModelIsInitialized() {
        XCTAssertEqual(viewModel?.turnsTaken, 0)
        XCTAssertEqual(viewModel?.currentPlayerColor, .colorOne)
        XCTAssertEqual(viewModel!.board.columns.count, maxNumberOfColumns)
        XCTAssertEqual(viewModel?.offset.count, 7)
        XCTAssertNotNil(viewModel?.view)
        XCTAssertNotNil(viewModel?.fetchConfiguration)
    }

    func testStartGame() {
        viewModel?.startGame()

        XCTAssertEqual(viewModel!.board.columns.count, maxNumberOfColumns)
        XCTAssertTrue(view.reloadBoardCalled)
        XCTAssertTrue(fetchConfiguration.fetchConfigurationCalled)
        XCTAssertEqual(viewModel?.players?.count, 2)
        XCTAssertTrue(view.initializeBoardViewWithPlayersCalled)
    }

    func testWinInHorizontalDirection() {
        viewModel?.board.columns[0].add(PlayingCounter(colour: .colorOne))
        viewModel?.board.columns[1].add(PlayingCounter(colour: .colorOne))
        viewModel?.board.columns[2].add(PlayingCounter(colour: .colorOne))

        viewModel?.makeMove(indexPath: BoardPositionConverter.viewPosition(for: BoardPosition(column: 3, row: 0)))

        XCTAssertTrue(view.reloadBoardPositionCalled)
        XCTAssertTrue(view.updateGameStatusLabelCalled)
        XCTAssertTrue(view.setInterfaceForGameOverCalled)
        XCTAssertEqual(viewModel?.currentPlayerColor, .colorOne)
    }

    func testWinInVerticalDirection() {
        viewModel?.board.columns[0].add(PlayingCounter(colour: .colorOne))
        viewModel?.board.columns[0].add(PlayingCounter(colour: .colorOne))
        viewModel?.board.columns[0].add(PlayingCounter(colour: .colorOne))

        viewModel?.makeMove(indexPath: BoardPositionConverter.viewPosition(for: BoardPosition(column: 0, row: 0)))

        XCTAssertTrue(view.reloadBoardPositionCalled)
        XCTAssertTrue(view.updateGameStatusLabelCalled)
        XCTAssertTrue(view.setInterfaceForGameOverCalled)
        XCTAssertEqual(viewModel?.currentPlayerColor, .colorOne)
    }

    func testWinInRisingDiagonalPosition() {
        viewModel?.board.columns[0].add(PlayingCounter(colour: .colorOne))

        viewModel?.board.columns[1].add(PlayingCounter(colour: .colorTwo))
        viewModel?.board.columns[1].add(PlayingCounter(colour: .colorOne))

        viewModel?.board.columns[2].add(PlayingCounter(colour: .colorTwo))
        viewModel?.board.columns[2].add(PlayingCounter(colour: .colorOne))
        viewModel?.board.columns[2].add(PlayingCounter(colour: .colorOne))

        viewModel?.board.columns[3].add(PlayingCounter(colour: .colorTwo))
        viewModel?.board.columns[3].add(PlayingCounter(colour: .colorOne))
        viewModel?.board.columns[3].add(PlayingCounter(colour: .colorTwo))

        viewModel?.makeMove(indexPath: BoardPositionConverter.viewPosition(for: BoardPosition(column: 3, row: 3)))

        XCTAssertTrue(view.reloadBoardPositionCalled)
        XCTAssertTrue(view.updateGameStatusLabelCalled)
        XCTAssertTrue(view.setInterfaceForGameOverCalled)
        XCTAssertEqual(viewModel?.currentPlayerColor, .colorOne)
    }

    func testWinInFallingDiagonalPosition() {
        viewModel?.board.columns[3].add(PlayingCounter(colour: .colorOne))

        viewModel?.board.columns[2].add(PlayingCounter(colour: .colorTwo))
        viewModel?.board.columns[2].add(PlayingCounter(colour: .colorOne))

        viewModel?.board.columns[1].add(PlayingCounter(colour: .colorOne))
        viewModel?.board.columns[1].add(PlayingCounter(colour: .colorTwo))
        viewModel?.board.columns[1].add(PlayingCounter(colour: .colorOne))

        viewModel?.board.columns[0].add(PlayingCounter(colour: .colorTwo))
        viewModel?.board.columns[0].add(PlayingCounter(colour: .colorOne))
        viewModel?.board.columns[0].add(PlayingCounter(colour: .colorTwo))

        viewModel?.makeMove(indexPath: BoardPositionConverter.viewPosition(for: BoardPosition(column: 0, row: 3)))

        XCTAssertTrue(view.reloadBoardPositionCalled)
        XCTAssertTrue(view.updateGameStatusLabelCalled)
        XCTAssertTrue(view.setInterfaceForGameOverCalled)
        XCTAssertEqual(viewModel?.currentPlayerColor, .colorOne)
    }

    override func tearDown() {
        super.tearDown()
        viewModel = nil
    }
}
