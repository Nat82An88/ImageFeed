import UIKit
import Foundation
import ImageFeed

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    var view: ImagesListViewProtocol?
    var photos: [Photo] = []
    var photosCount: Int { photos.count }
    
    var viewDidLoadCalled = false
    var willDisplayCellCalled = false
    var changeLikeCalled = false
    var calculateCellHeightCalled = false
    var photoForIndexPathCalled = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func willDisplayCell(at indexPath: IndexPath) {
        willDisplayCellCalled = true
    }
    
    func calculateCellHeight(for indexPath: IndexPath, tableView: UITableView) -> CGFloat {
        calculateCellHeightCalled = true
        return 100
    }
    
    func changeLike(at indexPath: IndexPath) {
        changeLikeCalled = true
    }
    
    func photoForIndexPath(_ indexPath: IndexPath) -> Photo? {
        photoForIndexPathCalled = true
        return photos[indexPath.row]
    }
}

final class ImagesListServiceStub: ImagesListServiceProtocol {
    var photos: [Photo] = []
    var isLoading: Bool = false
    
    var fetchPhotosNextPageCalled = false
    var changeLikeCalled = false
    
    func fetchPhotosNextPage(completion: @escaping (Result<[Photo], Error>) -> Void) {
        fetchPhotosNextPageCalled = true
        isLoading = true
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            self.isLoading = false
            completion(.success(self.photos))
        }
    }
    
    func changeLike(photoId: String, isLiked: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        changeLikeCalled = true
        completion(.success(()))
    }
}

final class ImagesListViewSpy: ImagesListViewProtocol {
    var updateTableViewAnimatedCalled = false
    var updatePhotoCalled = false
    var showLoadingIndicatorCalled = false
    var hideLoadingIndicatorCalled = false
    var showErrorAlertCalled = false
    
    func updateTableViewAnimated(oldCount: Int, newCount: Int) {
        updateTableViewAnimatedCalled = true
    }
    
    func updatePhoto(at indexPath: IndexPath) {
        updatePhotoCalled = true
    }
    
    func showLoadingIndicator() {
        showLoadingIndicatorCalled = true
    }
    
    func hideLoadingIndicator() {
        hideLoadingIndicatorCalled = true
    }
    
    func showErrorAlert(message: String) {
        showErrorAlertCalled = true
    }
}
