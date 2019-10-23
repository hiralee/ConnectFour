import UIKit

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
        let counterStatus: CounterColorState = viewModel?.board.counterStatus(at: indexPath) ?? .none

        switch counterStatus {
        case .none:
            cell.backgroundColor = emptyCounterColor
        case .colorOne:
            cell.backgroundColor = playerOne?.color
        case .colorTwo:
            cell.backgroundColor = playerTwo?.color
        case .colorWin:
            cell.backgroundColor = winningCounterColor
        }

        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 1.0

        return cell
    }
}
