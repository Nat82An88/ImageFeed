import UIKit

final class ImagesListService {
    
    // MARK: - Private Properties
    
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")
    
    private(set) var photos: [Photo] = []
    private var lastLoadedPage = 1
    private var isLoading = false
    private let session = URLSession.shared
    private let perPage = 10
    // MARK: - Private Methods
    
    func fetchPhotosNextPage() {
        guard !isLoading else { return }
        isLoading = true
        
        guard let url = URL(string: "https://api.unsplash.com/photos?page=\(lastLoadedPage)&per_page=\(perPage)") else {
            print("Неверный URL")
            return
        }
        var request = URLRequest(url: url)
        if let accessToken = OAuth2TokenStorage().token {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            guard let self else { return }
            defer { self.isLoading = false }
            if let error {
                print("Ошибка загрузки: \(error.localizedDescription)")
                return
            }
            guard let data else {
                print("Данные не получены")
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                print("Статус ответа сервера: \(httpResponse.statusCode)")
            } else {
                print("Не удалось получить статус ответа")
            }
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let photoResults = try decoder.decode([PhotoResult].self, from: data)
                print("Получено \(photoResults.count) фотографий")
                let newPhotos = photoResults.map { result in
                    Photo(
                        id: result.id,
                        size: CGSize(width: CGFloat(result.width), height: CGFloat(result.height)),
                        createdAt: result.createdAt,
                        welcomeDescription: result.description ?? "",
                        thumbImageURL: result.urls.thumb,
                        largeImageURL: result.urls.regular,
                        isLiked: result.likedByUser
                    )
                }
                DispatchQueue.main.async {
                    self.photos.append(contentsOf: newPhotos)
                    self.lastLoadedPage += 1
                    NotificationCenter.default.post(name: Self.didChangeNotification, object: nil)
                }
            } catch {
                print("Ошибка декодирования: (error.localizedDescription)")
            }
        }
        task.resume()
    }
    
    func changeLike(photoId: String, isLiked: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let accessToken = OAuth2TokenStorage().token else {
            completion(.failure(NSError(domain: "NoAccessToken", code: 401, userInfo: nil)))
            return
        }
        guard let url = URL(string: "https://api.unsplash.com/photos/\(photoId)/likes") else {
            completion(.failure(NSError(domain: "InvalidURL", code: -1, userInfo: nil)))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = isLiked ? "POST" : "DELETE"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            guard let self else { return }
            if let error {
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "InvalidResponse", code: -1, userInfo: nil)))
                return
            }
            let isSuccess = (httpResponse.statusCode == 201 && isLiked) ||
            (httpResponse.statusCode == 204 && !isLiked)
            if isSuccess {
                if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                    var updatedPhoto = self.photos[index]
                    updatedPhoto.isLiked = isLiked
                    self.updatePhoto(updatedPhoto, at: index)
                    completion(.success(()))
                } else {
                    completion(.failure(NSError(domain: "PhotoNotFound", code: -1, userInfo: nil)))
                }
            } else {
                completion(.failure(NSError(domain: "RequestFailed", code: httpResponse.statusCode, userInfo: nil)))
            }
        }
        task.resume()
    }
}

extension ImagesListService {
    static let photoUpdatedNotification = Notification.Name("PhotoUpdated")
    
    func updatePhoto(_ photo: Photo, at index: Int) {
        photos[index] = photo
        NotificationCenter.default.post(
            name: ImagesListService.photoUpdatedNotification,
            object: index
        )
    }
}
