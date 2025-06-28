import UIKit

enum AuthServiceError: Error {
    case invalidRequest
}

final class OAuth2Service {
    
    // MARK: - Private Properties
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    
    // MARK: - Singleton
    
    static let shared = OAuth2Service()
    private init() {}
    // MARK: - Request Creation
    
    func makeOAuthTokenRequest(code: String)throws -> URLRequest {
        guard let baseURL = URL(string: "https://unsplash.com") else {
            print("Не удалось создать базовый URL для запроса токена Unsplash")
            throw AuthServiceError.invalidRequest
        }
        var components = URLComponents(url: baseURL.appendingPathComponent("/oauth/token"), resolvingAgainstBaseURL: true)
        components?.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectUri),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "code", value: code)
        ]
        guard let url = components?.url else {
            print("Не удалось сформировать URL для запроса токена Unsplash")
            throw AuthServiceError.invalidRequest
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        return request
    }
    // MARK: - Token Fetching
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        if task != nil {
            if lastCode != code {
                task?.cancel()
            } else {
                completion(.failure(AuthServiceError.invalidRequest))
                return
            }
        } else {
            if lastCode == code {
                completion(.failure(AuthServiceError.invalidRequest))
                return
            }
        }
        lastCode = code
        do{
            let request = try makeOAuthTokenRequest(code: code)
            task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
                DispatchQueue.main.async {
                    guard let self else { return }
                    if self.lastCode != code {
                        completion(.failure(AuthServiceError.invalidRequest))
                        self.resetState()
                        return
                    }
                    switch result {
                    case .success(let tokenResponse):
                        guard let accessToken = tokenResponse.accessToken else {
                            completion(.failure(NetworkError.missingToken))
                            self.resetState()
                            return
                        }
                        let tokenStorage = OAuth2TokenStorage()
                        tokenStorage.token = accessToken
                        completion(.success(accessToken))
                    case .failure(let error):
                        print("Ошибка: \(error.localizedDescription)")
                        completion(.failure(error))
                        self.resetState()
                    }
                }
            }
            
            task?.resume()
        } catch {
            completion(.failure(error))
        }
    }
    
    private func resetState() {
        task = nil
        lastCode = nil
    }
}
