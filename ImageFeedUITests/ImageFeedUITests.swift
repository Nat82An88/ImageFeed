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
    
    private func hideKeyboard() {
        let app = XCUIApplication()
        if app.keyboards.element.exists {
            if UIDevice.current.userInterfaceIdiom == .pad {
                app.keyboards.buttons["Hide keyboard"].tap()
            } else {
                app.toolbars.buttons["Done"].tap()
            }
        }
    }
    
    func testAuth() throws {
        let authButton = app.buttons["Authenticate"]
        XCTAssertTrue(authButton.waitForExistence(timeout: 5))
        authButton.tap()
        
        let webView = app.webViews.firstMatch
        XCTAssertTrue(webView.waitForExistence(timeout: 10))
        
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        loginTextField.tap()
        loginTextField.typeText("login@example.com")
        
        hideKeyboard()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        passwordTextField.tap()
        passwordTextField.typeText("Password123")
        
        hideKeyboard()
        
        webView.buttons["Login"].tap()
        
        let firstCell = app.tables.cells.firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 10))
    }
    
    func testFeed() throws {
        let tablesQuery = app.tables
        
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        cell.swipeUp()
        
        sleep(2)
        
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
        
        cellToLike.buttons["notActive"].tap()
        cellToLike.buttons["Active"].tap()
        
        sleep(2)
        
        cellToLike.tap()
        
        sleep(2)
        
        let image = app.scrollViews.images.element(boundBy: 0)
        image.pinch(withScale: 3, velocity: 1)
        image.pinch(withScale: 0.5, velocity: -1)
        
        let navBackButtonWhiteButton = app.buttons["Backward"]
        navBackButtonWhiteButton.tap()
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
