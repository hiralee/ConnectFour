import UIKit

class BoardViewController: UIViewController {

    @IBOutlet weak var board: UICollectionView!
    @IBOutlet weak var startGameButton: UIButton!
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
        board.delegate = self
        board.dataSource = self
        viewModel = BoardViewModel(view: self)
    }

    @IBAction func startGame(_ sender: Any) {
        showSpinner(onView: view)
        viewModel?.startGame()
    }

    func showError(error: Error) {
        let alert = UIAlertController(title: "Error", message: "\(error.localizedDescription)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension BoardViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return maxNumberOfColumns
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return maxNumberOfRows
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellReuseIdentifier = "BoardCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath)
        let counterStatus: CounterColorStatus = viewModel?.board.counterStatus(at: indexPath) ?? .none
        switch counterStatus {
        case .none:
            cell.backgroundColor = .white
        case .colorOne:
            cell.backgroundColor = playerOne?.color
        case .colorTwo:
            cell.backgroundColor = playerTwo?.color
        }

        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 1.0

        return cell
    }
}

extension BoardViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = calculateCellWidth()
        return CGSize(width: cellWidth, height: cellWidth)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }

    func calculateCellWidth() -> CGFloat {
        let cellCountInARow = CGFloat(maxNumberOfColumns)
        let estimatedWidth: CGFloat = (self.view.frame.size.width - cellMargin * cellCountInARow  - cellMargin) / cellCountInARow
        return estimatedWidth
    }
}

extension BoardViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel?.makeMove(indexPath: indexPath)
    }
}

extension BoardViewController: BoardViewProtocol {
    func initializeBoardView(playerOne: Player?, playerTwo: Player?) {
        self.playerOne = playerOne
        self.playerTwo = playerTwo

        DispatchQueue.main.async { [unowned self] in
            self.removeSpinner()
            self.setInterfaceForPlaying()
        }
    }

    func setInterfaceForPlaying() {
        startGameButton.isEnabled = false
        playerOneLabel.text = playerOne?.name
        playerTwoLabel.text = playerTwo?.name
        board.isUserInteractionEnabled = true
        gameStatusLabel.text = "\(self.playerOne?.name ?? ""), you go next!"
    }

    func setInterfaceForGameOver() {
        startGameButton.isEnabled = true
        playerOneLabel.text = ""
        playerTwoLabel.text = ""
        board.isUserInteractionEnabled = false
        gameStatusLabel.text = ""
    }

    func updateGameStatusLabel(with message: String) {
        gameStatusLabel.text = message
    }

    func reloadBoardPosition(at indexPath: IndexPath) {
        board.reloadItems(at: [indexPath])
    }
}

