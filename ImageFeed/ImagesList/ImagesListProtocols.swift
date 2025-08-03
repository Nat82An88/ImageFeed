import Foundation
import UIKit

public protocol ImagesListViewProtocol: AnyObject {
    func updateTableViewAnimated(oldCount: Int, newCount: Int)
    func updatePhoto(at indexPath: IndexPath)
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func showErrorAlert(message: String)
}

public protocol ImagesListPresenterProtocol: AnyObject {
    var photos: [Photo] { get }
    var photosCount: Int { get }
    var view: ImagesListViewProtocol? { get set }
    func viewDidLoad()
    func willDisplayCell(at indexPath: IndexPath)
    func calculateCellHeight(for indexPath: IndexPath, tableView: UITableView) -> CGFloat
    func changeLike(at indexPath: IndexPath)
    func photoForIndexPath(_ indexPath: IndexPath) -> Photo?
}

protocol ImagesListServiceProtocol {
    var photos: [Photo] { get }
    var isLoading: Bool { get }
    func fetchPhotosNextPage(completion: @escaping (Result<[Photo], Error>) -> Void)
    func changeLike(photoId: String, isLiked: Bool, completion: @escaping (Result<Void, Error>) -> Void)
}
