import Foundation

protocol BoardViewProtocol {
    func initializeBoardViewWithPlayers(playerOne: Player?, playerTwo: Player?)
    func setInterfaceForPlaying()
    func setInterfaceForGameOver()
    func updateGameStatusLabel(with message: String)
    func reloadBoardPosition(at indexPath: IndexPath)
    func reloadBoard()
    func showError(error: Error)
}
