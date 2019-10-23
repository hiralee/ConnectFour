import FBSnapshotTestCase
@testable import ConnectFour

class BoardViewControllerSnapshotTest: FBSnapshotTestCase {
    override func setUp() {
        super.setUp()
        self.recordMode = false
    }

    func testBoardViewController() {
        let boardViewController: BoardViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BoardViewController") as! BoardViewController
        FBSnapshotVerifyView(boardViewController.view)
    }
}
