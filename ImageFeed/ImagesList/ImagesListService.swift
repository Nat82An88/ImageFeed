import UIKit
import ProgressHUD

final class ImagesListService: ImagesListServiceProtocol {
    // MARK: - Properties
    private(set) var photos: [Photo] = []
    private(set) var isLoading = false
    private var lastLoadedPage = 1
    private let perPage = 10
    private let session = URLSession.shared
    
    // MARK: - Public Methods
    func fetchPhotosNextPage(completion: @escaping (Result<[Photo], Error>) -> Void) {
        guard !isLoading else { return }
        isLoading = true
        
        guard let url = makeURL(page: lastLoadedPage, perPage: perPage) else {
            isLoading = false
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        if let token = OAuth2TokenStorage().token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            defer { self.isLoading = false }
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let photoResults = try decoder.decode([PhotoResult].self, from: data)
                let newPhotos = photoResults.map { $0.toPhoto() }
                
                DispatchQueue.main.async {
                    self.photos.append(contentsOf: newPhotos)
                    self.lastLoadedPage += 1
                    completion(.success(newPhotos))
                }
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    func changeLike(photoId: String, isLiked: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "https://api.unsplash.com/photos/\(photoId)/like") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = isLiked ? "POST" : "DELETE"
        
        if let token = OAuth2TokenStorage().token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NetworkError.requestFailed))
                return
            }
            
            DispatchQueue.main.async {
                if let index = self?.photos.firstIndex(where: { $0.id == photoId }) {
                    self?.photos[index].isLiked = isLiked
                }
                completion(.success(()))
            }
        }
        
        task.resume()
    }
    
    // MARK: - Private Methods
    private func makeURL(page: Int, perPage: Int) -> URL? {
        var components = URLComponents(string: "https://api.unsplash.com/photos")
        components?.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "\(perPage)")
        ]
        return components?.url
    }
}
extension PhotoResult {
    func toPhoto() -> Photo {
        return Photo(
            id: self.id,
            size: CGSize(width: CGFloat(self.width), height: CGFloat(self.height)),
            createdAt: self.createdAt,
            welcomeDescription: self.description ?? "",
            thumbImageURL: self.urls.thumb,
            largeImageURL: self.urls.regular,
            isLiked: self.likedByUser
        )
    }
}
