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
        
    }
    
    func testProfile() throws {
        
    }
}
