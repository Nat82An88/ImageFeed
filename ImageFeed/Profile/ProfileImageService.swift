import UIKit

final class ProfileImageService {
    
    // MARK: - Private Properties
    
    private let urlSession = URLSession.shared
    private let decoder = JSONDecoder()
    private var activeTasks = Set<URLSessionDataTask>()
    private var isFetching = false
    private(set) var avatarURL: String?
    private let tokenStorage = OAuth2TokenStorage()
    // MARK: - Singleton
    
    static let shared = ProfileImageService()
    private init() {}
    // MARK: - Request Creation
    
    private func makeProfileImageRequest(username: String) throws -> URLRequest {
        guard let baseURL = URL(string: "https://api.unsplash.com/users/\(username)") else {
            throw NetworkError.invalidURL
        }
        var request = URLRequest(url: baseURL)
        request.httpMethod = "GET"
        guard let token = tokenStorage.token else {
            throw NetworkError.noToken
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
    // MARK: - Profile Image Fetching
    
    func fetchProfileImageURL(username: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        guard !isFetching else {
            print("Аватарка уже загружается, повторный запрос проигнорирован")
            return
        }
        isFetching = true
        do {
            let request = try makeProfileImageRequest(username: username)
            let task = urlSession.dataTask(with: request) { [weak self] data, response, error in
                DispatchQueue.main.async {
                    guard let self else { return }
                    self.isFetching = false
                    if let error {
                        print("Сетевая ошибка: \(error.localizedDescription)")
                        completion(.failure(error))
                        return
                    }
                    guard let data else {
                        print("Ошибка: полученные данные пусты")
                        completion(.failure(NetworkError.noData))
                        return
                    }
                    do {
                        let userResult = try self.decoder.decode(UserResult.self, from: data)
                        let smallURL = userResult.profileImage.small
                        self.avatarURL = smallURL
                        completion(.success(smallURL))
                    } catch {
                        print("Ошибка декодирования JSON: \(error.localizedDescription)")
                        completion(.failure(error))
                    }
                }
            }
            task.resume()
            self.activeTasks.insert(task)
            let workItem = DispatchWorkItem { [weak self] in
                self?.activeTasks.remove(task)
            }
            workItem.perform()
        } catch {
            print("Ошибка создания запроса: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }
    // MARK: - Error Handling
    
    enum NetworkError: Error {
        case invalidURL
        case noData
        case noToken
    }
}
