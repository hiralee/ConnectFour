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

class BoardViewModel: NSObject {    
    enum Directions: Int {
        case northEast = 0
        case east
        case southEast
        case south
        case southWest
        case west
        case northWest
    }

    var view: BoardViewProtocol?
    var board: Board
    var offset: [BoardPosition]
    var turnsTaken: Int
    var currentPlayerColor: CounterColorState
    var players: [Player]?

    init(view: BoardViewController) {
        self.board = Board()
        self.view = view
        self.turnsTaken = 0
        self.currentPlayerColor = .colorOne
        self.offset = [BoardPosition(column:1, row:1), // northEast
                       BoardPosition(column:1, row:0), // east
                       BoardPosition(column:1 , row:-1), // southEast
                       BoardPosition(column:0 , row:-1), // south
                       BoardPosition(column:-1,row:-1), // southWest
                       BoardPosition(column: -1, row:0), // west
                       BoardPosition(column:-1 , row:1)] // northWest
    }
}

extension BoardViewModel: BoardViewModelProtocol {
    func startGame() {
        board = Board()
        view?.reloadBoard()
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

    func makeMove(indexPath: IndexPath) {
        turnsTaken += 1
        let counter = PlayingCounter(colour: currentPlayerColor)
        let newPosition = lowestAvailableCounter(from: indexPath)
        updateBoard(withCounter: counter, at: newPosition)
        let win = checkWin(at: newPosition, for: currentPlayerColor)
        if win {
            handleWin()
        } else {
            if turnsTaken >= maxNumberOfRows * maxNumberOfColumns {
                handleDraw()
            } else {
                updatePlayer()
            }
        }
    }

    // MARK: Private Methods
    private func initializePlayers(configuration: Configuration) {
        let playerOne = Player(name: configuration.name1, color: UIColor(hexString: configuration.color1))
        let playerTwo = Player(name: configuration.name2, color: UIColor(hexString: configuration.color2))
        players = [playerOne, playerTwo]
        view?.initializeBoardViewWithPlayers(playerOne: playerOne, playerTwo: playerTwo)
    }

    private func lowestAvailableCounter(from indexPath: IndexPath) -> BoardPosition {
        let boardPosition: BoardPosition = BoardPositionConverter.modelPosition(for: indexPath)
        let column = boardPosition.column
        return BoardPosition(column: boardPosition.column, row: board.columns[column].counters.count)
    }

    private func updatePlayer() {
        switch currentPlayerColor {
        case .colorOne:
            currentPlayerColor = .colorTwo
            view?.updateGameStatusLabel(with: "\(players?[0].name ?? ""), you go next!")
        case .colorTwo:
            currentPlayerColor = .colorOne
            view?.updateGameStatusLabel(with: "\(players?[1].name ?? ""), you go next!")
        case .none, .colorWin:
            view?.updateGameStatusLabel(with: "")
        }
    }

    private func handleWin() {
        switch currentPlayerColor {
        case .colorOne:
            view?.updateGameStatusLabel(with: "\(players?[0].name ?? "") wins!")
        case .colorTwo:
            view?.updateGameStatusLabel(with: "\(players?[1].name ?? "") wins!")
        case .none, .colorWin:
            view?.updateGameStatusLabel(with: "")
        }

        setGameOver()
    }

    private func handleDraw(){
        view?.updateGameStatusLabel(with: "Its a draw!")
        setGameOver()
    }

    private func setGameOver() {
        view?.setInterfaceForGameOver()
        turnsTaken = 0
        currentPlayerColor = .colorOne
    }

    private func updateBoard(withCounter counter: PlayingCounter, at position: BoardPosition) {
        board.columns[position.column].add(counter)
        view?.reloadBoardPosition(at: BoardPositionConverter.viewPosition(for: position))
    }

    private func checkWin(at position: BoardPosition, for color: CounterColorState) -> Bool {
        let southWin = countConsecutiveCounter(color: color, from: position, inDirection: offset[Directions.south.rawValue]) >= 3
        if southWin {
            changeWinningCounterColor(at: position)
            highlightWinnerCounters(color: color, from: position, inDirection: offset[Directions.south.rawValue])
        }

        let eastWestWin = countConsecutiveCounter(color: color, from: position, inDirection: offset[Directions.east.rawValue], offset2: offset[Directions.west.rawValue]) >= 3
        if eastWestWin {
            changeWinningCounterColor(at: position)
            highlightWinnerCounters(color: color, from: position, inDirection: offset[Directions.east.rawValue], offset2: offset[Directions.west.rawValue])
        }

        let diagonalOneWin = countConsecutiveCounter(color: color, from: position, inDirection: offset[Directions.northWest.rawValue], offset2: offset[Directions.southEast.rawValue]) >= 3
        if diagonalOneWin {
            changeWinningCounterColor(at: position)
            highlightWinnerCounters(color: color, from: position, inDirection: offset[Directions.northWest.rawValue], offset2: offset[Directions.southEast.rawValue])
        }

        let diagonalTwoWin = countConsecutiveCounter(color: color, from: position, inDirection: offset[Directions.northEast.rawValue], offset2: offset[Directions.southWest.rawValue]) >= 3
        if diagonalTwoWin {
            changeWinningCounterColor(at: position)
            highlightWinnerCounters(color: color, from: position, inDirection: offset[Directions.northEast.rawValue], offset2: offset[Directions.southWest.rawValue])
        }

        return southWin || eastWestWin || diagonalOneWin || diagonalTwoWin
    }

    private func countConsecutiveCounter(color: CounterColorState, from currentCounter: BoardPosition, inDirection offset1: BoardPosition, offset2: BoardPosition) -> Int {
        return countConsecutiveCounter(color: color, from: currentCounter, inDirection: offset1) +
            countConsecutiveCounter(color: color, from: currentCounter, inDirection: offset2)
    }

    private func countConsecutiveCounter(color: CounterColorState, from currentCounter: BoardPosition, inDirection offset: BoardPosition) -> Int {
        guard let nextOffsetCounter = generateNextOffset(from: currentCounter, inDirection: offset) else { return 0 }
        guard board.counterExists(at: nextOffsetCounter) && board.counterStatus(at: nextOffsetCounter) == color else { return 0 }

        return 1 + countConsecutiveCounter(color: color, from: nextOffsetCounter, inDirection: offset)
    }

    private func highlightWinnerCounters(color: CounterColorState, from currentCounter: BoardPosition, inDirection offset1: BoardPosition, offset2: BoardPosition) {
        highlightWinnerCounters(color: color, from: currentCounter, inDirection: offset1)
        highlightWinnerCounters(color: color, from: currentCounter, inDirection: offset2)
    }

    private func highlightWinnerCounters(color: CounterColorState, from currentCounter: BoardPosition, inDirection offset: BoardPosition) {
        guard let nextOffsetCounter = generateNextOffset(from: currentCounter, inDirection: offset) else { return }
        guard board.counterExists(at: nextOffsetCounter) && board.counterStatus(at: nextOffsetCounter) == color else { return }

        changeWinningCounterColor(at: nextOffsetCounter)
        highlightWinnerCounters(color: color, from: nextOffsetCounter, inDirection: offset)
    }

    private func changeWinningCounterColor(at position: BoardPosition) {
        board.columns[position.column].counters[position.row].colour = .colorWin
        view?.reloadBoardPosition(at: BoardPositionConverter.viewPosition(for: position))
    }

    private func generateNextOffset(from current: BoardPosition, inDirection offset: BoardPosition) -> BoardPosition? {
        let nextOffsetPosition = BoardPosition(column: current.column + offset.column, row: current.row + offset.row)
        if isValidBoardPosition(counter: nextOffsetPosition) {
            return nextOffsetPosition
        }
        return nil
    }

    private func isValidBoardPosition(counter: BoardPosition) -> Bool {
        if counter.column < 0 || counter.column > (maxNumberOfColumns - 1) || counter.row < 0 || counter.row > (maxNumberOfRows - 1) {
            return false
        }
        return true
    }
}
