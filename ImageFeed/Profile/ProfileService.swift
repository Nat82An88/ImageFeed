import UIKit

final class ProfileService {
    // MARK: - Private Properties
    
    private let urlSession = URLSession.shared
    private var activeTasks = Set<URLSessionTask>()
    private var isFetching = false
    private(set) var profile: Profile?
    // MARK: - Singleton
    
    static let shared = ProfileService()
    private init() {}
    // MARK: - Reset Method
    
    func reset() {
        profile = nil
        activeTasks.forEach { $0.cancel() }
        activeTasks.removeAll()
        isFetching = false
    }
    // MARK: - Request Creation
    
    private func makeProfileRequest(accessToken: String) throws -> URLRequest {
        guard let baseURL = URL(string: "https://api.unsplash.com/me") else {
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
            let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
                DispatchQueue.main.async {
                    guard let self else { return }
                    self.isFetching = false
                    switch result {
                    case .success(let profileResult):
                        let profile = Profile(from: profileResult)
                        self.profile = profile
                        completion(.success(profile))
                    case .failure(let error):
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
