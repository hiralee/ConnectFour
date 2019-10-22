import Foundation
import UIKit

enum BoardDimension: Int {
    case numberOfColumns = 7
    case numberOfRows = 6
}

struct Player {
    let name: String
    let color: UIColor
}

protocol BoardViewModelProtocol {
    func startGame()
}

class BoardViewModel: NSObject, BoardViewModelProtocol {
    weak var view: BoardViewController?

    init(view: BoardViewController) {
        super.init()
        self.view = view
    }

    func startGame() {
        let configurationFetcher = FetchConfiguration()
        configurationFetcher.fetchRemoteConfiguration { [unowned self] (configuration: Configuration?, error: Error?) in
            if let configuration = configuration {
                self.initializePlayers(configuration: configuration)
            }
        }
    }

    func initializePlayers(configuration: Configuration) {
        let playerOne = Player(name: configuration.name1, color: UIColor(hexString: configuration.color1))
        let playerTwo = Player(name: configuration.name2, color: UIColor(hexString: configuration.color2))
        view?.initializeBoardView(playerOne: playerOne, playerTwo: playerTwo)
    }
}
