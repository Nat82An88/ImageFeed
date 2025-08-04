import XCTest
import ImageFeed

class Image_FeedUITests: XCTestCase {
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app.launch()
    }
    
    func testAuth() throws {
        func testAuth() throws {
            app.buttons["Authenticate"].tap()
            
            let webView = app.webViews["UnsplashWebView"]
            
            XCTAssertTrue(webView.waitForExistence(timeout: 5))
            
            let loginTextField = webView.descendants(matching: .textField).element
            XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
            
            loginTextField.tap()
            loginTextField.typeText("Email@example.com")
            webView.swipeUp()
            
            let passwordTextField = webView.descendants(matching: .secureTextField).element
            XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
            
            passwordTextField.tap()
            passwordTextField.typeText("Password")
            webView.swipeUp()
            
            webView.buttons["Login"].tap()
            
            let tablesQuery = app.tables
            let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
            
            XCTAssertTrue(cell.waitForExistence(timeout: 5))
        }
    }
    
    func testFeed() throws {
        let tablesQuery = app.tables
        
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        cell.swipeUp()
        
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
        XCTAssertTrue(cellToLike.waitForExistence(timeout: 2))
        
        cellToLike.buttons["notActive"].tap()
        cellToLike.buttons["Active"].tap()
        
        XCTAssertTrue(cellToLike.waitForExistence(timeout: 2))
        
        cellToLike.tap()
        
        let image = app.scrollViews.images.element(boundBy: 0)
        XCTAssertTrue(image.waitForExistence(timeout: 2))
        
        image.pinch(withScale: 3, velocity: 1)
        image.pinch(withScale: 0.5, velocity: -1)
        
        let navBackButtonWhiteButton = app.buttons["Backward"]
        XCTAssertTrue(navBackButtonWhiteButton.waitForExistence(timeout: 2))
        navBackButtonWhiteButton.tap()
    }
    
    func testProfile() throws {
        let tabBarButton = app.tabBars.buttons.element(boundBy: 1)
        XCTAssertTrue(tabBarButton.waitForExistence(timeout: 3))
        tabBarButton.tap()
        
        XCTAssertTrue(app.staticTexts["Name Lastname"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["@username"].waitForExistence(timeout: 2))
        
        let logoutButton = app.buttons["Exit"]
        XCTAssertTrue(logoutButton.waitForExistence(timeout: 2))
        logoutButton.tap()
        
        let logoutAlert = app.alerts["Пока, пока!"]
        XCTAssertTrue(logoutAlert.waitForExistence(timeout: 2))
        
        let confirmButton = logoutAlert.buttons["Да"]
        XCTAssertTrue(confirmButton.waitForExistence(timeout: 1))
        confirmButton.tap()
    }
}
