import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imagesListCellDidTapLike(in cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    weak var delegate: ImagesListCellDelegate?
    // MARK: - IB Outlets
    
    @IBOutlet  weak var cellImage: UIImageView!
    @IBOutlet  weak var likeButton: UIButton!
    @IBOutlet  weak var dateLabel: UILabel!
    // MARK: - Reuse Identifier
    
    static let reuseIdentifier = "ImagesListCell"
    // MARK: - Private Methods
    
    func setIsLiked(_ isLiked: Bool) {
        let buttonImage = isLiked
        ? UIImage(named: "Active")
        : UIImage(named: "notActive")
        likeButton.setImage(buttonImage, for: .normal)
    }
    // MARK: - View Life Cycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cellImage.kf.cancelDownloadTask()
    }
    // MARK: - IB Actions
    
    @IBAction func likeButtonClicked(_ sender: Any) {
        delegate?.imagesListCellDidTapLike(in: self)
    }
}
