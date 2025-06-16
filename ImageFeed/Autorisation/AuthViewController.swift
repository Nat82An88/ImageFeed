import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_vc: AuthViewController, didAuthenticateWithToken token: String)
}
final class AuthViewController: UIViewController {
    
    weak var delegate: AuthViewControllerDelegate?
    // MARK: - Private Properties
    
    private let showWebViewSegueIdentifier = "ShowWebView"
    private let oauth2Service = OAuth2Service.shared
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewSegueIdentifier {
            guard
                let webViewViewController = segue.destination as? WebViewViewController
            else {
                assertionFailure("Failed to prepare for \(showWebViewSegueIdentifier)")
                return
            }
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}
// MARK: - WebViewViewControllerDelegate

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        vc.dismiss(animated: true)
        OAuth2Service.shared.fetchOAuthToken(code: code){ [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let accessToken): self.delegate?.authViewController(_vc: self, didAuthenticateWithToken: accessToken)
            case .failure(let error):
                print("Ошибка получения токена: \(error.localizedDescription)")
            }
        }
    }

    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}
