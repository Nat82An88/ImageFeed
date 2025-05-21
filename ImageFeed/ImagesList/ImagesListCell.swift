import UIKit

final class ImagesListCell: UITableViewCell {
    
    // MARK: - IB Outlets
    
    @IBOutlet  weak var cellImage: UIImageView!
    @IBOutlet  weak var likeButton: UIButton!
    @IBOutlet  weak var dateLabel: UILabel!
    
    // MARK: - Private Properties
    
    
    static let reuseIdentifier = "ImagesListCell"
}
