import Foundation
import UIKit

protocol ImagesListViewProtocol: AnyObject {
    func updateTableViewAnimated(oldCount: Int, newCount: Int)
    func updatePhoto(at indexPath: IndexPath)
    func blockProgressHUDOn()
    func blockProgressHUDOff()
    func showErrorAlert(message: String)
}

protocol ImagesListPresenterProtocol: AnyObject {
    var photos: [Photo] { get }
    var view: ImagesListViewProtocol? { get set }
    func viewDidLoad()
    func willDisplayCell(at indexPath: IndexPath)
    func calculateCellHeight(for indexPath: IndexPath, tableView: UITableView) -> CGFloat
    func changeLike(at indexPath: IndexPath)
    func photoForIndexPath(_ indexPath: IndexPath) -> Photo?
}
