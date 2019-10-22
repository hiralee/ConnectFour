import Foundation

struct BoardPositionConverter {
    static func modelPosition(for indexPath: IndexPath) -> BoardPosition {
        return BoardPosition(column:indexPath.item, row: maxNumberOfRows - 1 - indexPath.section)
    }
    
    static func viewPosition(for modelPosition: BoardPosition) -> IndexPath{
        return IndexPath(item: modelPosition.column, section: maxNumberOfRows - 1 - modelPosition.row)
    }
}
