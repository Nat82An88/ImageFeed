import Foundation
import ImageFeed

final class WebViewViewControllerSpy: WebViewViewControllerProtocol {
    var presenter: ImageFeed.WebViewPresenterProtocol?
    var loadRequesstCalled: Bool = false
    var progressValue: Float?
    var progressHidden: Bool?
    
    func load(request: URLRequest) {
        loadRequesstCalled = true
    }
    
    func setProgressValue(_ newValue: Float) {
        progressValue = newValue
    }
    
    func setProgressHidden(_ isHidden: Bool) {
        progressHidden = isHidden
    }
}
