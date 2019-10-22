import Foundation
import UIKit

struct Player {
    let name: String
    let color: UIColor
}

protocol BoardViewModelProtocol {
    var board: Board { get }

    func startGame()
    func makeMove(indexPath: IndexPath)
}

class BoardViewModel: NSObject, BoardViewModelProtocol {
    weak var view: BoardViewController?
    var board: Board
    var offset: [BoardPosition]
    var turnsTaken: Int
    var currentPlayer: CounterColorStatus

    init(view: BoardViewController) {
        self.board = Board()
        self.view = view
        self.turnsTaken = 0
        self.currentPlayer = CounterColorStatus.colorOne
        self.offset = [BoardPosition(column:1, row:1),
                       BoardPosition(column:1, row:0),
                       BoardPosition(column:1 , row:-1),
                       BoardPosition(column:0 , row:-1),
                       BoardPosition(column:-1,row:-1),
                       BoardPosition(column: -1, row:0),
                       BoardPosition(column:-1 , row:1)]
    }

    func startGame() {
        let configurationFetcher = FetchConfiguration()
        configurationFetcher.fetchRemoteConfiguration { [unowned self] (configuration: Configuration?, error: Error?) in
            if let configuration = configuration {
                self.initializePlayers(configuration: configuration)
            }
            if let error = error {
                self.view?.showError(error: error)
            }
        }
    }

    private func initializePlayers(configuration: Configuration) {
        let playerOne = Player(name: configuration.name1, color: UIColor(hexString: configuration.color1))
        let playerTwo = Player(name: configuration.name2, color: UIColor(hexString: configuration.color2))
        view?.initializeBoardView(playerOne: playerOne, playerTwo: playerTwo)
    }

    func makeMove(indexPath: IndexPath) {
        turnsTaken += 1
        let counter = PlayingCounter(colour: currentPlayer)
        let newPosition = getBoardPosition(indexPath: indexPath)
        updateBoard(withCounter: counter, at: newPosition)
    }

    private func getBoardPosition(indexPath: IndexPath) -> BoardPosition {
        let boardPosition = BoardPositionConverter.modelPosition(for: indexPath)
        let column = boardPosition.column
        return BoardPosition(column: boardPosition.column, row: board.columns[column].counters.count)
    }

    private func updateBoard(withCounter counter: PlayingCounter, at position: BoardPosition) {
        board.columns[position.column].add(counter)
        view?.reloadBoardPosition(at: BoardPositionConverter.viewPosition(for: position))
    }
}
