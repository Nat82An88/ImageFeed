import UIKit
import Foundation

final class ImagesListPresenter: ImagesListPresenterProtocol {
    // MARK: - Properties
    
    weak var view: ImagesListViewProtocol?
    private let imagesListService: ImagesListServiceProtocol
    
    var photosCount: Int {
        return imagesListService.photos.count
    }
    var photos: [Photo] {
        return imagesListService.photos
    }
    // MARK: - Initialization
    
    init(imagesListService: ImagesListServiceProtocol = ImagesListService()) {
        self.imagesListService = imagesListService
    }
    // MARK: - Public Methods
    
    func viewDidLoad() {
        loadNextPhotos()
    }
    
    func willDisplayCell(at indexPath: IndexPath) {
        if indexPath.row + 1 == photosCount && !imagesListService.isLoading {
            loadNextPhotos()
        }
    }
    
    func calculateCellHeight(for indexPath: IndexPath, tableView: UITableView) -> CGFloat {
        guard indexPath.row < photosCount else { return 0 }
        
        let photo = photos[indexPath.row]
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let scale = imageViewWidth / photo.size.width
        return photo.size.height * scale + imageInsets.top + imageInsets.bottom
    }
    
    func changeLike(at indexPath: IndexPath) {
        guard indexPath.row < photosCount else { return }
        
        let photo = photos[indexPath.row]
        view?.showLoadingIndicator()
        
        imagesListService.changeLike(photoId: photo.id, isLiked: !photo.isLiked) { [weak self] result in
            guard let self else { return }
            
            DispatchQueue.main.async {
                self.view?.hideLoadingIndicator()
                
                switch result {
                case .success:
                    self.view?.updatePhoto(at: indexPath)
                case .failure(let error):
                    self.view?.showErrorAlert(message: error.localizedDescription)
                    self.view?.updatePhoto(at: indexPath)
                }
            }
        }
    }
    
    func photoForIndexPath(_ indexPath: IndexPath) -> Photo? {
        guard photos.indices.contains(indexPath.row) else { return nil }
        return photos[indexPath.row]
    }
    // MARK: - Private Methods
    
    private func loadNextPhotos() {
        imagesListService.fetchPhotosNextPage { [weak self] result in
            guard let self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let newPhotos):
                    let oldCount = self.photosCount - newPhotos.count
                    self.view?.updateTableViewAnimated(oldCount: oldCount, newCount: self.photosCount)
                case .failure(let error):
                    self.view?.showErrorAlert(message: error.localizedDescription)
                }
            }
        }
    }
}
