import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private let tokenStorage = OAuth2TokenStorage()
    private var profileImageServiceObserver: NSObjectProtocol?
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private lazy var nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.text = ""
        nameLabel.font = .systemFont(ofSize: 23, weight: .bold)
        nameLabel.textColor = .ypWhite
        return nameLabel
    }()
    private lazy var loginNameLabel: UILabel = {
        loginNameLabel = UILabel()
        loginNameLabel.text = ""
        loginNameLabel.font = .systemFont(ofSize: 13, weight: .regular)
        loginNameLabel.textColor = .ypGray
        return loginNameLabel
    }()
    private lazy var descriptionLabel: UILabel = {
        let descriptionLabel = UILabel()
        descriptionLabel.text = ""
        descriptionLabel.font = .systemFont(ofSize: 13, weight: .regular)
        descriptionLabel.textColor = .ypWhite
        descriptionLabel.numberOfLines = 0
        return descriptionLabel
    }()
    private lazy var logoutButton: UIButton = {
        let logoutButton = UIButton.systemButton(
            with: UIImage(named: "Exit")!,
            target: self,
            action: #selector(Self.didTapLogoutButton)
        )
        logoutButton.tintColor = .ypRed
        return logoutButton
    }()
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypBlack
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            print("Получено уведомление об изменении аватарки")
            self.updateAvatar()
        }
        updateAvatar()
        addSubviews()
        setupConstraints()
        fetchProfileData()
    }
    // MARK: - Private Methods
    
    private func updateAvatar() {
        guard let profileImageURL = ProfileImageService.shared.avatarURL,
              let url = URL(string: profileImageURL) else {
            print("Аватарка не найдена")
            imageView.image = UIImage(named: "Avatar")
            return }
        imageView.kf.setImage(
            with: url,
            placeholder: UIImage(named: "placeholder.jpeg"),
            options: [
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(0.3))
            ]
        )
    }
    
    private func fetchProfileData() {
        guard let accessToken = tokenStorage.token else {
            print("Токен не найден")
            return
        }
        ProfileService.shared.fetchProfile(accessToken) { [weak self] result in
            switch result {
            case .success(let profile):
                DispatchQueue.main.async {
                    self?.updateProfileDetails(profile: profile)
                    ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { [weak self] result in
                        switch result {
                        case .success(let url):
                            print("Получен URL аватарки: \(url)")
                            guard let self else { return }
                            if let imageURL = URL(string: url) {
                                self.imageView.kf.setImage(with: imageURL)
                            } else {
                                print("Неверный формат URL")
                                return
                            }
                        case .failure(let error):
                            print("Ошибка получения URL аватарки: \(error.localizedDescription)")
                        }
                    }
                }
                
            case .failure(let error):
                print("Ошибка загрузки профиля: \(error.localizedDescription)")
            }
        }
    }
    
    private func updateProfileDetails(profile: Profile) {
        nameLabel.text = profile.name
        loginNameLabel.text = "@\(profile.username)"
        descriptionLabel.text = profile.bio
    }
    
    private func addSubviews() {
        [imageView, nameLabel, loginNameLabel, descriptionLabel, logoutButton].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(view)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            
            // Ограничения для imageView
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            imageView.widthAnchor.constraint(equalToConstant: 70),
            imageView.heightAnchor.constraint(equalToConstant: 70),
            
            // Ограничения для nameLabel
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 16),
            
            // Ограничения для loginNameLabel
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            loginNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            loginNameLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            // Ограничения для descriptionLabel
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            // Ограничения для logoutButton
            logoutButton.widthAnchor.constraint(equalToConstant: 44),
            logoutButton.heightAnchor.constraint(equalToConstant: 44),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            logoutButton.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
        ])
    }
    
    @objc
    private func didTapLogoutButton() {
        tokenStorage.token = nil
        let authViewController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "AuthViewController") as! AuthViewController
        present(authViewController, animated: true, completion: nil)
    }
}
