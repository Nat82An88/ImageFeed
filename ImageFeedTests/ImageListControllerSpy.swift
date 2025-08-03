import Foundation
import ImageFeed
import UIKit

class ImagesListViewControllerSpy: ImagesListViewProtocol {
    var updateTableViewAnimatedCalled = false
    var updatePhotoCalled = false
    var blockProgressHUDOnCalled = false
    var blockProgressHUDOffCalled = false
    var showErrorAlertCalled = false
    
    func updateTableViewAnimated(oldCount: Int, newCount: Int) {
        updateTableViewAnimatedCalled = true
    }
    
    func updatePhoto(at indexPath: IndexPath) {
        updatePhotoCalled = true
    }
    
    func blockProgressHUDOn() {
        blockProgressHUDOnCalled = true
    }
    
    func blockProgressHUDOff() {
        blockProgressHUDOffCalled = true
    }
    
    func showErrorAlert(message: String) {
        showErrorAlertCalled = true
    }
}
