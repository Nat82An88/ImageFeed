import Foundation
import UIKit
import Kingfisher

final class ProfilePresenter: ProfilePresenterProtocol {
    // MARK: - Properties
    
    weak var view: ProfileViewControllerProtocol?
    private let profileService: ProfileServiceProtocol
    private let profileImageService: ProfileImageServiceProtocol
    private let tokenStorage: OAuth2TokenStorageProtocol
    private let logoutService: ProfileLogoutServiceProtocol
    // MARK: - Initializer
    
    init(
        profileService: ProfileServiceProtocol = ProfileService.shared,
        profileImageService: ProfileImageServiceProtocol = ProfileImageService.shared,
        tokenStorage: OAuth2TokenStorageProtocol = OAuth2TokenStorage.shared,
        logoutService: ProfileLogoutServiceProtocol = ProfileLogoutService.shared
    ) {
        self.profileService = profileService
        self.profileImageService = profileImageService
        self.tokenStorage = tokenStorage
        self.logoutService = logoutService
    }
    // MARK: - ProfilePresenterProtocol
    
    func viewDidLoad() {
        fetchProfileData()
    }
    
    func didTapLogoutButton() {
        view?.showLogoutConfirmationAlert()
    }
    
    func performLogout() {
        logoutService.logout()
        view?.switchToSplashScreen()
    }
    
    func handleAvatarUpdate(_ notification: Notification) {
        guard let urlString = notification.userInfo?["URL"] as? String,
              let url = URL(string: urlString) else {
            view?.showDefaultAvatar()
            return
        }
        view?.updateAvatar(url: url)
    }
    // MARK: - Private Methods
    
    private func fetchProfileData() {
        guard let token = tokenStorage.token else {
            assertionFailure("No token found")
            return
        }
        
        profileService.fetchProfile(token) { [weak self] result in
            switch result {
            case .success(let profile):
                self?.view?.updateProfileDetails(profile: profile)
                self?.fetchProfileImage(username: profile.username)
            case .failure(let error):
                print("Failed to fetch profile: \(error.localizedDescription)")
            }
        }
    }
    
    private func fetchProfileImage(username: String) {
        profileImageService.fetchProfileImageURL(username: username) { [weak self] result in
            switch result {
            case .success(let urlString):
                if let url = URL(string: urlString) {
                    self?.view?.updateAvatar(url: url)
                } else {
                    self?.view?.showDefaultAvatar()
                }
            case .failure:
                self?.view?.showDefaultAvatar()
            }
        }
    }
}
