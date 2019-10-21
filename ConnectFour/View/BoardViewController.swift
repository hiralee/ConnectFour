import UIKit

class BoardViewController: UIViewController {

    @IBOutlet weak var board: UICollectionView!
    @IBOutlet weak var startGameButton: UIButton!

    let cellMargin: CGFloat = 10.0
    let boardBottomSpace: CGFloat = 237.0

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBoard()
    }

    private func setupBoard() {
        board.delegate = self
        board.dataSource = self
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

