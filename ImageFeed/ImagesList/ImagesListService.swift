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
        let task = session.dataTask(with: url) { [weak self] data, _, error in
            guard let self else { return }
            defer { self.isLoading = false }
            guard let data, error == nil else {
                print("Ошибка загрузки: \(error?.localizedDescription ?? "Неизвестная ошибка")")
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let photoResults = try decoder.decode([PhotoResult].self, from: data)
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
                print("Ошибка декодирования: \(error.localizedDescription)")
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
