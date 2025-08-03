import Foundation
import ImageFeed
import UIKit

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    var photos: [Photo] = []
    var view: ImagesListViewProtocol?
    var viewDidLoadCalled = false
    var willDisplayCellCalled = false
    var changeLikeCalled = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func willDisplayCell(at indexPath: IndexPath) {
        willDisplayCellCalled = true
    }
    
    func calculateCellHeight(for indexPath: IndexPath, tableView: UITableView) -> CGFloat {
        return 100
    }
    
    
    func changeLike(at indexPath: IndexPath) {
        changeLikeCalled = true
    }
    
    func photoForIndexPath(_ indexPath: IndexPath) -> Photo? {
        return photos.isEmpty ? nil : photos[indexPath.row]
    }
}
