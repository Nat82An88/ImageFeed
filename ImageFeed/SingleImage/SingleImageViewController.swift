import UIKit

final class SingleImageViewController: UIViewController {
    
    // MARK: - IB Outlets
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var scrollView: UIScrollView!
    
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func didTapShareButton(_ sender: UIButton) {
        guard let image else { return }
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        share.overrideUserInterfaceStyle = .dark
        present(share, animated: true, completion: nil)
    }
    
    // MARK: - Public Properties
    
    var image: UIImage?
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let image else { return }
        imageView.image = image
        imageView.frame.size = image.size
        
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        
        rescaleAndCenterImageInScrollView(image: image)
    }
    
    // MARK: - Private Methods
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        let xInset = max((scrollView.bounds.width - imageSize.width * scale) / 2, 0)
        let yInset = max((scrollView.bounds.height - imageSize.height * scale) / 2, 0)
        scrollView.contentInset = UIEdgeInsets(top: yInset, left: xInset, bottom: yInset, right: xInset)
    }
}

// MARK: - UIScrollViewDelegate

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        guard let image else { return }
        rescaleAndCenterImageInScrollView(image: image)
    }
}



