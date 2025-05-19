import UIKit

final class ImagesListCell: UITableViewCell {
    
    static let reuseIdentifier = "ImagesListCell"
    
    
    @IBOutlet private var cellImage: UIImageView!
    
    @IBOutlet private var likeButton: UIButton!
    
    @IBOutlet private var dateLabel: UILabel!
    
}
