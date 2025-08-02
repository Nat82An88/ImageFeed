import UIKit
import Foundation

final class ImagesListPresenter: ImagesListPresenterProtocol {
    // MARK: - Properties
    
    private let imagesListService: ImagesListService
    weak var view: ImagesListViewProtocol?
    private(set) var photos: [Photo] = []
    // MARK: - Initialization
    
    init(imagesListService: ImagesListService = ImagesListService()) {
        self.imagesListService = imagesListService
        setupObservers()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    // MARK: - Private Methods
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePhotosUpdate),
            name: ImagesListService.didChangeNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePhotoUpdate),
            name: ImagesListService.photoUpdatedNotification,
            object: nil
        )
    }
    
    @objc private func handlePhotosUpdate() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        view?.updateTableViewAnimated(oldCount: oldCount, newCount: newCount)
    }
    
    @objc private func handlePhotoUpdate(notification: Notification) {
        guard let index = notification.object as? Int else { return }
        let indexPath = IndexPath(row: index, section: 0)
        view?.updatePhoto(at: indexPath)
    }
    // MARK: - Public Methods
    
    func viewDidLoad() {
        imagesListService.fetchPhotosNextPage()
    }
    
    func willDisplayCell(at indexPath: IndexPath) {
        if indexPath.row + 1 == photos.count {
            imagesListService.fetchPhotosNextPage()
        }
    }
    
    func calculateCellHeight(for indexPath: IndexPath, tableView: UITableView) -> CGFloat {
        guard indexPath.row < photos.count else { return 0 }
        
        let photo = photos[indexPath.row]
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = photo.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func changeLike(at indexPath: IndexPath) {
        guard indexPath.row < photos.count else { return }
        
        let photo = photos[indexPath.row]
        view?.blockProgressHUDOn()
        
        imagesListService.changeLike(photoId: photo.id, isLiked: !photo.isLiked) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.view?.blockProgressHUDOff()
                
                switch result {
                case .success:
                    break
                case .failure(let error):
                    self.view?.showErrorAlert(message: error.localizedDescription)
                    if let index = self.photos.firstIndex(where: { $0.id == photo.id }) {
                        var updatedPhoto = self.photos[index]
                        updatedPhoto.isLiked = photo.isLiked
                        self.photos[index] = updatedPhoto
                        self.view?.updatePhoto(at: indexPath)
                    }
                }
            }
        }
    }
    
    func photoForIndexPath(_ indexPath: IndexPath) -> Photo? {
        guard indexPath.row < photos.count else { return nil }
        return photos[indexPath.row]
    }
}
