import UIKit

let maxNumberOfColumns = 7
let maxNumberOfRows = 6
let maxNumberToWin = 4
let emptyCounterColor: UIColor = .white
let winningCounterColor: UIColor = .green

enum CounterColorState: Int {
    case colorOne = 0
    case colorTwo
    case colorWin
    case none
}

enum Direction: Int {
    case northEast = 0
    case east
    case southEast
    case south
    case southWest
    case west
    case northWest
}

struct PlayingCounter {
    var colour : CounterColorState
}

struct Column {
    var counters = [PlayingCounter]()

    mutating func add(_ counter : PlayingCounter){
        guard counters.count < maxNumberOfRows else {return}
        counters.append(counter)
    }
}

struct BoardPosition {
    var column: Int
    var row: Int
}

struct Board {
    var columns = [Column]()

    init() {
        for _ in 1...maxNumberOfColumns {
            columns.append(Column())
        }
    }

    func counterExists(at position: BoardPosition) -> Bool {
        if self.columns[position.column].counters.count > (position.row) {
            return true
        }
        return false
    }

    func counterExists(at indexPath : IndexPath) -> Bool {
        let position = BoardPositionConverter.modelPosition(for: indexPath)
        return counterExists(at: position)
    }

    func counter(at position : BoardPosition) -> PlayingCounter {
        return columns[position.column].counters[position.row]
    }

    func counter(at indexPath: IndexPath) -> PlayingCounter {
        let position = BoardPositionConverter.modelPosition(for: indexPath)
        return counter(at: position)
    }

    func counterStatus(at position: BoardPosition) -> CounterColorState {
        guard (counterExists(at: position) == true) else {
            return .none
        }
        let counter = self.counter(at: position)
        return counter.colour
    }

    func counterStatus(at indexPath : IndexPath) -> CounterColorState {
        let position = BoardPositionConverter.modelPosition(for: indexPath)
        return counterStatus(at: position)
    }

    func generateNextOffset(from current: BoardPosition, inDirection offset: BoardPosition) -> BoardPosition? {
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
