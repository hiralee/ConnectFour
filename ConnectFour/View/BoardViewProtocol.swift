import Foundation

protocol BoardViewProtocol {
    func initializeBoardView(playerOne: Player?, playerTwo: Player?)
    func setInterfaceForPlaying()
    func setInterfaceForGameOver()
    func updateGameStatusLabel(with message: String)
    func reloadBoardPosition(at indexPath: IndexPath)
}
