import UIKit

final class SplashViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private let oauth2Service = OAuth2Service.shared
    private let oauth2TokenStorage = OAuth2TokenStorage()
    private let profileService = ProfileService.shared
    // MARK: - UIImageView for Logo
    
    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "SplashScreenLogo")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(logoImageView)
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token = oauth2TokenStorage.token {
            fetchProfile(with: token)
        } else {
            showAuthViewController()
        }
    }
    // MARK: - Profile Fetching
    
    private func fetchProfile(with token: String) {
        profileService.fetchProfile(token) { [weak self] result in
            switch result {
            case .success(let profile):
                ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { _ in }
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
            return
        }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
    private func showAuthViewController() {
        guard let authViewController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else {
            fatalError("Не удалось создать AuthViewController")
        }
        
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true, completion: nil)
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
                self.showAuthViewController()
                break
            }
        }
    }
}
