import UIKit
import Kingfisher

class ImagesListViewController: UIViewController {
    
    // MARK: - IB Outlets
    
    @IBOutlet private var tableView: UITableView!
    // MARK: - Private Properties
    
    private let imagesListService = ImagesListService()
    private var isLoadingMore = false
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private let photosName: [String] = Array(0..<20).map { "\($0)" }
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        loadNextPage()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }
            
            let photo = imagesListService.photos[indexPath.row]
            viewController.imageURL = photo.largeImageURL
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    // MARK: - Private Methods
    
    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard indexPath.row < imagesListService.photos.count else { return }
        
        let photo = imagesListService.photos[indexPath.row]
        if let url = URL(string: photo.thumbImageURL) {
            cell.cellImage.kf.setImage(with: url)
        } else {
            cell.cellImage.image = UIImage(named: "placeholder")
        }
        
        let formattedDate = dateFormatter.string(from: photo.createdAt ?? Date())
        cell.dateLabel.text = formattedDate
        
        let buttonImage = photo.isLiked
        ? UIImage(named: "Active")
        : UIImage(named: "notActive")
        cell.likeButton.setImage(buttonImage, for: .normal)
    }
    
    private func loadNextPage() {
        isLoadingMore = true
        imagesListService.fetchPhotosNextPage()
        
        NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main) { [weak self] _ in
                guard let self else { return }
                self.isLoadingMore = false
                self.updateTableViewAnimated()
            }
    }
}
// MARK: - UITableViewDataSource

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imagesListService.photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        guard let imageListCell = cell as? ImagesListCell else { fatalError("Не удалось преобразовать ячейку к типу ImagesListCell") }
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
}
// MARK: - UITableViewDelegate

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == imagesListService.photos.count && !isLoadingMore {
            loadNextPage()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard indexPath.row < imagesListService.photos.count else { return 0 }
        let photo = imagesListService.photos[indexPath.row]
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = photo.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    private func updateTableViewAnimated() {
        let oldCount = imagesListService.photos.count
        tableView.performBatchUpdates({
            if oldCount > self.imagesListService.photos.count {
                let indicesToDelete = (self.imagesListService.photos.count..<oldCount)
                    .map { IndexPath(row: $0, section: 0) }
                self.tableView.deleteRows(at: indicesToDelete, with: .fade)
            }
            if oldCount < self.imagesListService.photos.count {
                let indicesToInsert = (oldCount..<self.imagesListService.photos.count)
                    .map { IndexPath(row: $0, section: 0) }
                self.tableView.insertRows(at: indicesToInsert, with: .fade)
            }
        }, completion: { _ in
        })
    }
}
