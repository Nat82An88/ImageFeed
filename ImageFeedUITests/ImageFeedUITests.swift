import XCTest
import ImageFeed

class Image_FeedUITests: XCTestCase {
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app.terminate()
    }
    
    func testAuth() throws {
        let authButton = app.buttons["Authenticate"]
        XCTAssertTrue(authButton.waitForExistence(timeout: 10))
        authButton.tap()
        
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 10))
        
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 10))
        loginTextField.tap()
        loginTextField.typeText("Login@example.com")
        
        webView.swipeUp()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 10))
        passwordTextField.tap()
        passwordTextField.typeText("Password")
        
        webView.swipeUp()
        webView.buttons["Login"].tap()
        
        let firstCell = app.tables.cells.firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 10))
    }
    
    func testFeed() throws {
        let tablesQuery = app.tables
        let firstCell = tablesQuery.cells.firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 10))
        
        firstCell.swipeUp()
        
        let secondCell = tablesQuery.cells.element(boundBy: 1)
        XCTAssertTrue(secondCell.waitForExistence(timeout: 10))
        
        let likeButton = secondCell.buttons["notActive"]
        XCTAssertTrue(likeButton.waitForExistence(timeout: 5))
        likeButton.tap()
        
        let activeLikeButton = secondCell.buttons["Active"]
        XCTAssertTrue(activeLikeButton.waitForExistence(timeout: 5))
        activeLikeButton.tap()
        
        secondCell.tap()
        
        let image = app.scrollViews.images.firstMatch
        XCTAssertTrue(image.waitForExistence(timeout: 5))
        
        image.pinch(withScale: 3, velocity: 1)
        image.pinch(withScale: 0.5, velocity: -1)
        
        let backButton = app.buttons["Backward"]
        XCTAssertTrue(backButton.waitForExistence(timeout: 5))
        backButton.tap()
        
        XCTAssertTrue(secondCell.waitForExistence(timeout: 5))
    }
    
    func testProfile() throws {
        sleep(2)
        
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 10))
        
        let tabBarButtons = tabBar.buttons.allElementsBoundByIndex
        guard tabBarButtons.count >= 2 else {
            XCTFail("Не найдена кнопка профиля в таббаре")
            return
        }
        
        let profileTab = tabBarButtons.last!
        profileTab.tap()
        
        sleep(2)
        
        let namePredicate = NSPredicate(format: "label CONTAINS ' '")
        let nameLabel = app.staticTexts.matching(namePredicate).firstMatch
        XCTAssertTrue(nameLabel.waitForExistence(timeout: 5))
        
        let loginPredicate = NSPredicate(format: "label BEGINSWITH '@'")
        let loginLabel = app.staticTexts.matching(loginPredicate).firstMatch
        XCTAssertTrue(loginLabel.waitForExistence(timeout: 5))
        
        let logoutButton = app.buttons["Exit"]
        XCTAssertTrue(logoutButton.waitForExistence(timeout: 5))
        logoutButton.tap()
        
        let logoutAlert = app.alerts["Пока, пока!"]
        XCTAssertTrue(logoutAlert.waitForExistence(timeout: 5))
        
        let confirmButton = logoutAlert.buttons["Да"]
        XCTAssertTrue(confirmButton.waitForExistence(timeout: 5))
        confirmButton.tap()
        
        let authButton = app.buttons["Authenticate"]
        XCTAssertTrue(authButton.waitForExistence(timeout: 5))
    }
}
