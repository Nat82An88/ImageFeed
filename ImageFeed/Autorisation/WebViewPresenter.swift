import UIKit
import WebKit
import Foundation

public protocol WebViewPresenterProtocol {
    var view: WebViewViewControllerProtocol? { get set}
    
    func viewDidLoad()
    func didUpdateProgressValue(_ newValue: Double)
    func code(from url: URL) -> String?
}

final class WebViewPresenter: WebViewPresenterProtocol {
    // MARK: - Properties
    
    weak var view: WebViewViewControllerProtocol?
    var authHelper: AuthHelperProtocol
    // MARK: - Initializer
    
    init(authHelper: AuthHelperProtocol) {
        self.authHelper = authHelper
    }
    // MARK: - View Life Cycles
    
    func viewDidLoad() {
        guard let view else { return }
        guard let request = authHelper.authRequest() else { return }
        didUpdateProgressValue(0)
        view.load(request: request)
    }
    // MARK: - Progress Methods
    
    func didUpdateProgressValue(_ newValue: Double) {
        let newProgressValue = Float(newValue)
        view?.setProgressValue(newProgressValue)
        
        let shouldHideProgress = shouldHideProgress(for: newProgressValue)
        view?.setProgressHidden(shouldHideProgress)
    }
    
     func shouldHideProgress(for value: Float) -> Bool {
        abs(value - 1.0) <= 0.0001
    }
    // MARK: - AUTH Code Method
    
    func code(from url: URL) -> String? {
        authHelper.code(from: url)
    }
}
