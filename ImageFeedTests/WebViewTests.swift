@testable import ImageFeed
import XCTest

final class WebViewTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        //given
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "WebViewViewController") as! WebViewViewController
        let presenter = WebViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        //when
        
        _ = viewController.view
        //then
        
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterCallsLoadRequest() {
        // given
        
        let viewController = WebViewViewControllerSpy()
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        viewController.presenter = presenter
        presenter.view = viewController
        // when
        
        presenter.viewDidLoad()
        // then
        
        XCTAssertTrue(viewController.loadRequesstCalled)
    }
    
    func testProgressVisibleWhenLessThenOne() {
        //given
        
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 0.6
        //when
        
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        //then
        
        XCTAssertFalse(shouldHideProgress)
    }
    
    func testProgressHiddenWhenOne() {
        // given
        
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 1.0
        // when
        
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        // then
        
        XCTAssertTrue(shouldHideProgress)
    }
    
    func testAuthHelperAuthURL() {
        //given
        
        let configuration = AuthConfiguration.standard
        let authHelper = AuthHelper(configuration: configuration)
        //when
        
        guard let url = authHelper.authURL() else {
            XCTFail("URL должен быть создан")
            return
        }
        let urlString = url.absoluteString
        //then
        
        XCTAssertTrue(urlString.contains(configuration.authURLString),
                      "URL должен содержать базовый адрес")
        XCTAssertTrue(urlString.contains(configuration.accessKey),
                      "URL должен содержать client_id")
        XCTAssertTrue(urlString.contains(configuration.redirectURI),
                      "URL должен содержать redirect_uri")
        XCTAssertTrue(urlString.contains("response_type=code"),
                      "URL должен содержать response_type=code")
        XCTAssertTrue(urlString.contains(configuration.accessScope),
                      "URL должен содержать scope")
    }
    
    func testCodeFromURL() {
        // given
        
        let configuration = AuthConfiguration.standard
        let authHelper = AuthHelper(configuration: configuration)
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "unsplash.com"
        urlComponents.path = "/oauth/authorize/native"
        urlComponents.queryItems = [
            URLQueryItem(name: "code", value: "test_code")
        ]
        guard let testURL = urlComponents.url else {
            XCTFail("Не удалось создать тестовый URL")
            return
        }
        // when
        
        let extractedCode = authHelper.code(from: testURL)
        // then
        
        XCTAssertEqual(extractedCode, "test_code",
                      "Извлечённый код должен совпадать с ожидаемым значением")
    }
}
