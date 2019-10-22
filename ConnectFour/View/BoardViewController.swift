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

    func initializeBoardView(playerOne: Player?, playerTwo: Player?) {
        DispatchQueue.main.async { [unowned self] in
            self.removeSpinner()
            self.playerOneLabel.text = playerOne?.name
            self.playerTwoLabel.text = playerTwo?.name
        }
        self.playerOne = playerOne
        self.playerTwo = playerTwo
    }

    @IBAction func startGame(_ sender: Any) {
        showSpinner(onView: view)
        viewModel?.startGame()
    }
}

extension BoardViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return BoardDimension.numberOfColumns.rawValue
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return BoardDimension.numberOfRows.rawValue
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellReuseIdentifier = "BoardCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath)
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
        let cellCountInARow = CGFloat(BoardDimension.numberOfColumns.rawValue)
        let estimatedWidth: CGFloat = (self.view.frame.size.width - cellMargin * cellCountInARow  - cellMargin) / cellCountInARow
        return estimatedWidth
    }
}

