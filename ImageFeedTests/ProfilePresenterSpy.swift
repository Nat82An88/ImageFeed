import Foundation
import ImageFeed

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    
    var viewDidLoadCalled = false
    var performLogoutCalled = false
    var didTapLogoutButtonCalled = false
    var handleAvatarUpdateCalled = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func performLogout() {
        performLogoutCalled = true
    }
    
    func didTapLogoutButton() {
        didTapLogoutButtonCalled = true
    }
    
    func handleAvatarUpdate(_ notification: Notification) {
        handleAvatarUpdateCalled = true
    }
}
