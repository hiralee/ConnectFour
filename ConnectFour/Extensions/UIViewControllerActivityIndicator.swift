import UIKit

var spinner: UIView?

extension UIViewController {
    func showSpinner(onView: UIView) {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let activityIndicator = UIActivityIndicatorView.init(style: .white)
        activityIndicator.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(activityIndicator)
            onView.addSubview(spinnerView)
        }

        activityIndicator.startAnimating()
        
        spinner = spinnerView
    }
    
    func removeSpinner() {
        DispatchQueue.main.async {
            spinner?.removeFromSuperview()
            spinner = nil
        }
    }
}
