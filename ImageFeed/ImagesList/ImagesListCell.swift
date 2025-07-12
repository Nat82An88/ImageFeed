import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
    
    // MARK: - IB Outlets
    
    @IBOutlet  weak var cellImage: UIImageView!
    @IBOutlet  weak var likeButton: UIButton!
    @IBOutlet  weak var dateLabel: UILabel!
    // MARK: - Public Properties
    
    static let reuseIdentifier = "ImagesListCell"
    // MARK: - View Life Cycle
        
        override func prepareForReuse() {
            super.prepareForReuse()
    
            cellImage.kf.cancelDownloadTask()
        }
}
