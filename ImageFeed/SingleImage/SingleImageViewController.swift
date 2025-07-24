import UIKit
import Kingfisher
import ProgressHUD

final class SingleImageViewController: UIViewController {
    
    // MARK: - Public Properties
    
    var image: UIImage?
    var imageURL: String?
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
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let url = URL(string: imageURL ?? "") else { return }
        UIBlockingProgressHUD.animate()
        
        imageView.kf.setImage(
            with: url,
            placeholder: nil,
            options: [.transition(.fade(0.3))],
            completionHandler: { [weak self] result in
                UIBlockingProgressHUD.dismiss()
                guard let self else { return }
                switch result {
                case .success(let value):
                    self.image = value.image
                    self.imageView.frame.size = value.image.size
                    self.rescaleAndCenterImageInScrollView(image: value.image)
                case .failure:
                    self.showError()
                }
            }
        )
        
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        imageView.contentMode = .center
        if let image {
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    // MARK: - Private Methods
    
    private func showError() {
        let alert = UIAlertController(title: "Ошибка", message: "Что-то пошло не так. Попробовать еще раз?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Не надо", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Повторить", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, max(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        let xOffset = max((scrollView.bounds.width - imageSize.width * scale) / 2, 0)
        let yOffset = max((scrollView.bounds.height - imageSize.height * scale) / 2, 0)
        imageView.center = CGPoint(x: scrollView.bounds.midX + xOffset, y: scrollView.bounds.midY + yOffset)
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
        imageView.center = CGPoint(x: scrollView.bounds.midX, y: scrollView.bounds.midY)
    }
}
