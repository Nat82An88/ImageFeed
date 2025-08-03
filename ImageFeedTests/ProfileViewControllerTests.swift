import XCTest
@testable import ImageFeed

final class ProfileViewControllerTests: XCTestCase {
    var sut: ProfileViewController!
    var presenterSpy: ProfilePresenterSpy!
    
    override func setUp() {
        super.setUp()
        sut = ProfileViewController()
        presenterSpy = ProfilePresenterSpy()
        sut.configure(presenterSpy)
        sut.loadViewIfNeeded()
    }
    
    override func tearDown() {
        sut = nil
        presenterSpy = nil
        super.tearDown()
    }
    
    func testViewDidLoad_CallsPresenter() {
        // when
        
        sut.viewDidLoad()
        // then
        
        XCTAssertTrue(presenterSpy.viewDidLoadCalled)
    }
    
    func testShowLogoutConfirmationAlert_PresentsAlert() {
        // given
        
        let window = UIWindow()
        window.rootViewController = sut
        window.makeKeyAndVisible()
        // when
        
        sut.showLogoutConfirmationAlert()
        // then
        
        XCTAssertTrue(sut.presentedViewController is UIAlertController)
        XCTAssertEqual((sut.presentedViewController as? UIAlertController)?.title, "Пока, пока!")
    }
    
    func testHandleAvatarUpdateNotification_CallsPresenter() {
        // given
        
        let notification = Notification(
            name: ProfileImageService.didChangeNotification,
            object: nil,
            userInfo: ["URL": "https://test.com/avatar.jpg"]
        )
        // when
        
        NotificationCenter.default.post(notification)
        // then
        
        XCTAssertTrue(presenterSpy.handleAvatarUpdateCalled)
    }
}
