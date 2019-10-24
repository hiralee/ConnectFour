import UIKit

class BoardViewController: UIViewController {

    @IBOutlet weak var board: UICollectionView!
    @IBOutlet weak var startGameButton: UIButton!
    @IBOutlet weak var endGameButton: UIButton!
    @IBOutlet weak var gameStatusLabel: UILabel!
    @IBOutlet weak var playerOneLabel: UILabel!
    @IBOutlet weak var playerTwoLabel: UILabel!

    var playerOne: Player?
    var playerTwo: Player?

    let cellMargin: CGFloat = 10.0
    let boardBottomSpace: CGFloat = 237.0 + 86.0

    var viewModel: BoardViewModelProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBoard()
    }

    private func setupBoard() {
        startGameButton.isEnabled = true
        endGameButton.isEnabled = false
        
        board.delegate = self
        board.dataSource = self
        viewModel = BoardViewModel(view: self)
    }

    @IBAction func startGame(_ sender: Any) {
        showSpinner(onView: view)
        viewModel?.startGame()
    }

    @IBAction func endGame(_ sender: Any) {
        viewModel?.endGame()
    }
}

extension BoardViewController: BoardViewProtocol {
    func initializeBoardViewWithPlayers(playerOne: Player?, playerTwo: Player?) {
        self.playerOne = playerOne
        self.playerTwo = playerTwo

        DispatchQueue.main.async { [unowned self] in
            self.removeSpinner()
            self.setInterfaceForPlaying()
        }
    }

    func setInterfaceForPlaying() {
        startGameButton.isEnabled = false
        endGameButton.isEnabled = true
        playerOneLabel.text = playerOne?.name
        playerTwoLabel.text = playerTwo?.name
        board.isUserInteractionEnabled = true
        gameStatusLabel.text = "\(self.playerOne?.name ?? ""), you go next!"
    }

    func setInterfaceForGameOver() {
        startGameButton.isEnabled = true
        endGameButton.isEnabled = false
        playerOneLabel.text = ""
        playerTwoLabel.text = ""
        board.isUserInteractionEnabled = false
        gameStatusLabel.text = ""
    }

    func updateGameStatusLabel(with message: String) {
        DispatchQueue.main.async { [unowned self] in
            self.gameStatusLabel.text = message
        }
    }

    func reloadBoardPosition(at indexPath: IndexPath) {
        board.reloadItems(at: [indexPath])
    }

    func reloadBoard() {
        DispatchQueue.main.async { [unowned self] in
            self.board.reloadData()
        }
    }

    func showError(error: Error) {
        let alert = UIAlertController(title: "Error", message: "\(error.localizedDescription)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

