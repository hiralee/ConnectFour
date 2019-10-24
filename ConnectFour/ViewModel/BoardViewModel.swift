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
    func endGame()
}

class BoardViewModel: NSObject {    
    var view: BoardViewProtocol?
    var board: Board
    var offset: [BoardPosition]
    var turnsTaken: Int
    var currentPlayerColor: CounterColorState
    var players: [Player]?
    var fetchConfiguration: FetchConfigurationProtocol?

    init(view: BoardViewProtocol, fetchConfiguration: FetchConfigurationProtocol = FetchConfiguration()) {
        self.board = Board()
        self.view = view
        self.turnsTaken = 0
        self.currentPlayerColor = .colorOne
        self.fetchConfiguration = fetchConfiguration
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
        fetchRemoteConfiguration()
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

    func endGame() {
        setGameOver()
    }

    // MARK: Private Methods

    private func fetchRemoteConfiguration() {
        fetchConfiguration?.fetchRemoteConfiguration { [unowned self] (configuration: Configuration?, error: Error?) in
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
            view?.updateGameStatusLabel(with: "\(players?[1].name ?? ""), you go next!")
        case .colorTwo:
            currentPlayerColor = .colorOne
            view?.updateGameStatusLabel(with: "\(players?[0].name ?? ""), you go next!")
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
        board = Board()
        view?.setInterfaceForGameOver()
        view?.reloadBoard()
        turnsTaken = 0
        currentPlayerColor = .colorOne
    }

    private func updateBoard(withCounter counter: PlayingCounter, at position: BoardPosition) {
        board.columns[position.column].add(counter)
        view?.reloadBoardPosition(at: BoardPositionConverter.viewPosition(for: position))
    }

    private func checkWin(at position: BoardPosition, for color: CounterColorState) -> Bool {
        var isWin = false
        let winningDirections: [[Direction]] = [
            [.south],
            [.east, .west],
            [.southEast, .northWest],
            [.southWest, .northEast]
        ]

        for winningDirection in winningDirections {
            isWin = checkForWin(at: position, counterColor: color, directions: winningDirection)
            if isWin {
                changeWinningCounterColor(at: position)
                for direction in winningDirection {
                    highlightWinnerCounters(color: color, from: position, inDirection: offset[direction.rawValue])
                }
                break
            }
        }

        return isWin
    }

    private func checkForWin(at position: BoardPosition, counterColor: CounterColorState, directions: [Direction]) -> Bool {
        var consecutiveCounters: Int = 0
        for direction in directions {
            consecutiveCounters += countConsecutiveCounter(color: counterColor, from: position, inDirection: offset[direction.rawValue])
        }

        return consecutiveCounters >= (maxNumberToWin - 1)
    }

    private func countConsecutiveCounter(color: CounterColorState, from currentCounter: BoardPosition, inDirection offset: BoardPosition) -> Int {
        guard let nextOffsetCounter = board.generateNextOffset(from: currentCounter, inDirection: offset) else { return 0 }
        guard board.counterExists(at: nextOffsetCounter) && board.counterStatus(at: nextOffsetCounter) == color else { return 0 }

        return 1 + countConsecutiveCounter(color: color, from: nextOffsetCounter, inDirection: offset)
    }

    private func highlightWinnerCounters(color: CounterColorState, from currentCounter: BoardPosition, inDirection offset: BoardPosition) {
        guard let nextOffsetCounter = board.generateNextOffset(from: currentCounter, inDirection: offset) else { return }
        guard board.counterExists(at: nextOffsetCounter) && board.counterStatus(at: nextOffsetCounter) == color else { return }

        changeWinningCounterColor(at: nextOffsetCounter)
        highlightWinnerCounters(color: color, from: nextOffsetCounter, inDirection: offset)
    }

    private func changeWinningCounterColor(at position: BoardPosition) {
        board.columns[position.column].counters[position.row].colour = .colorWin
        view?.reloadBoardPosition(at: BoardPositionConverter.viewPosition(for: position))
    }
}
