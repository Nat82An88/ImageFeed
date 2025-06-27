import UIKit

final class ProfileService {
    
    // MARK: - Private Properties
    
    private let urlSession = URLSession.shared
    private let decoder = JSONDecoder()
    private var activeTasks = Set<URLSessionDataTask>()
    private var isFetching = false // Флаг для предотвращения гонок
    // MARK: - Singleton
    
    static let shared = ProfileService()
    private init() {}
    // MARK: - Request Creation
    
    private func makeProfileRequest(accessToken: String) throws -> URLRequest {
        guard let baseURL = URL(string: "https://api.unsplash.com/users/me") else {
            throw NetworkError.invalidURL
        }
        var request = URLRequest(url: baseURL)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        return request
    }
    // MARK: - Profile Fetching
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        guard !isFetching else {
            print("Профиль уже загружается, повторный запрос проигнорирован")
            return
        }
        isFetching = true
        do {
            let request = try makeProfileRequest(accessToken: token)
            let task = urlSession.dataTask(with: request) { [weak self] data, response, error in
                DispatchQueue.main.async {
                    guard let self else { return }
                    self.isFetching = false
                    if let error = error {
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
                        let profileResult = try self.decoder.decode(ProfileResult.self, from: data)
                        let profile = Profile(from: profileResult)
                        completion(.success(profile))
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
    }
}
