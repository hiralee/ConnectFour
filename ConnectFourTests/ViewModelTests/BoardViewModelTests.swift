import XCTest
@testable import ConnectFour

private class MockFetchConfiguration: FetchConfigurationProtocol {
    var fetchConfigurationCalled = false
    var showError: Bool = false

    init(showError: Bool) {
        self.showError = showError
    }

    func fetchRemoteConfiguration(_ completion: @escaping (Configuration?, Error?) -> ()) {
        let config = Configuration(id: 1, color1: "color1", color2: "color2", name1: "name1", name2: "name2")
        fetchConfigurationCalled = true
        if showError {
            completion(nil, NSError.init() as Error)
        } else {
            completion(config, nil)
        }
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
    fileprivate let fetchConfigurationSuccess = MockFetchConfiguration(showError: false)
    fileprivate let fetchConfigurationFailure = MockFetchConfiguration(showError: true)

    override func setUp() {
        super.setUp()
    }

    func testViewModelIsInitialized() {
        viewModel = BoardViewModel(view: view, fetchConfiguration: fetchConfigurationSuccess)

        XCTAssertEqual(viewModel?.turnsTaken, 0)
        XCTAssertEqual(viewModel?.currentPlayerColor, .colorOne)
        XCTAssertEqual(viewModel!.board.columns.count, maxNumberOfColumns)
        XCTAssertEqual(viewModel?.offset.count, 7)
        XCTAssertNotNil(viewModel?.view)
        XCTAssertNotNil(viewModel?.fetchConfiguration)
    }

    func testStartGame() {
        viewModel = BoardViewModel(view: view, fetchConfiguration: fetchConfigurationSuccess)
        viewModel?.startGame()

        XCTAssertEqual(viewModel!.board.columns.count, maxNumberOfColumns)
        XCTAssertTrue(view.reloadBoardCalled)
        XCTAssertTrue(fetchConfigurationSuccess.fetchConfigurationCalled)
        XCTAssertEqual(viewModel?.players?.count, 2)
        XCTAssertTrue(view.initializeBoardViewWithPlayersCalled)
    }

    func testWinInHorizontalDirection() {
        viewModel = BoardViewModel(view: view, fetchConfiguration: fetchConfigurationSuccess)
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
        viewModel = BoardViewModel(view: view, fetchConfiguration: fetchConfigurationSuccess)
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
        viewModel = BoardViewModel(view: view, fetchConfiguration: fetchConfigurationSuccess)
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
        viewModel = BoardViewModel(view: view, fetchConfiguration: fetchConfigurationSuccess)
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

    func testNoWin() {
        viewModel = BoardViewModel(view: view, fetchConfiguration: fetchConfigurationSuccess)
        viewModel?.makeMove(indexPath: BoardPositionConverter.viewPosition(for: BoardPosition(column: 0, row: 0)))
        XCTAssertTrue(view.reloadBoardPositionCalled)
        XCTAssertTrue(view.updateGameStatusLabelCalled)
        XCTAssertEqual(viewModel?.currentPlayerColor, .colorTwo)
    }

    func testEndGame() {
        viewModel = BoardViewModel(view: view, fetchConfiguration: fetchConfigurationSuccess)
        viewModel?.startGame()
        viewModel?.endGame()

        XCTAssertEqual(viewModel?.turnsTaken, 0)
        XCTAssertTrue(view.setInterfaceForGameOverCalled)
        XCTAssertTrue(view.reloadBoardCalled)
    }

    func testFetchConfigurationFailure() {
        viewModel = BoardViewModel(view: view, fetchConfiguration: fetchConfigurationFailure)
        viewModel?.startGame()

        XCTAssertTrue(view.showErrorCalled)
        XCTAssertTrue(fetchConfigurationFailure.fetchConfigurationCalled)
    }

    override func tearDown() {
        super.tearDown()
        viewModel = nil
    }
}
