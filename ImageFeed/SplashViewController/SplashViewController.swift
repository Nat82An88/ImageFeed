import UIKit

final class SplashViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private let ShowAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    private let oauth2Service = OAuth2Service.shared
    private let oauth2TokenStorage = OAuth2TokenStorage()
    private let profileService = ProfileService.shared
    // MARK: - View Lifecycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let token = oauth2TokenStorage.token {
                   fetchProfile(with: token)
               } else {
                   performSegue(withIdentifier: ShowAuthenticationScreenSegueIdentifier, sender: nil)
               }
           }
           // MARK: - Profile Fetching
           
           private func fetchProfile(with token: String) {
               profileService.fetchProfile(token) { [weak self] result in
                   switch result {
                   case .success(let profile):
                       ProfileImageService.shared.fetchProfileImageURL(username: profile.username) {_ in}
                       DispatchQueue.main.async {
                           self?.switchToTabBarController()
                       }
                   case .failure(let error):
                       print("Ошибка загрузки профиля: \(error.localizedDescription)")
                       self?.switchToTabBarController()
                   }
               }
           }
    // MARK: - Navigation
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
           print("Не удалось открыть окно приложения")
            return }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
}
// MARK: - Segue Preparation

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowAuthenticationScreenSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else { fatalError("Failed to prepare for \(ShowAuthenticationScreenSegueIdentifier)") }
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}
// MARK: - AuthViewControllerDelegate

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        dismiss(animated: true)
        fetchOAuthToken(code)
    }
    
    private func fetchOAuthToken(_ code: String) {
        oauth2Service.fetchOAuthToken(code: code) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                self.switchToTabBarController()
            case .failure:
                // TODO [Sprint 11]
                break
            }
        }
    }
}
