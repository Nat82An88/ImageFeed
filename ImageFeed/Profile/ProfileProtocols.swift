import Foundation
public protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func performLogout()
    func didTapLogoutButton()
    func handleAvatarUpdate(_ notification: Notification)
}

public protocol ProfileViewControllerProtocol: AnyObject {
    func updateProfileDetails(profile: Profile)
    func updateAvatar(url: URL)
    func showDefaultAvatar()
    func showLogoutConfirmationAlert()
    func switchToSplashScreen()
}

public protocol ProfileServiceProtocol: AnyObject {
    var profile: Profile? { get }
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void)
    func reset()
}

extension ProfileService: ProfileServiceProtocol {}

public protocol ProfileImageServiceProtocol: AnyObject {
    var avatarURL: String? { get }
    func fetchProfileImageURL(username: String, completion: @escaping (Result<String, Error>) -> Void)
    func reset()
}

extension ProfileImageService: ProfileImageServiceProtocol {}

public protocol ProfileLogoutServiceProtocol: AnyObject {
    func logout()
}

extension ProfileLogoutService: ProfileLogoutServiceProtocol {}
