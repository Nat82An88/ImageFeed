import UIKit

final class OAuth2Service {
    
    // MARK: - Singleton
    
    static let shared = OAuth2Service()
    private init() {}
    private let decoder = JSONDecoder()
    // MARK: - Request Creation
    
    func makeOAuthTokenRequest(code: String) -> URLRequest {
        guard let baseURL = URL(string: "https://unsplash.com") else {
            print("Ошибка: Не удалось создать базовый URL для запроса токена Unsplash")
            fatalError("Не удалось создать базовый URL для запроса токена Unsplash")
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
            fatalError("Не удалось сформировать URL для запроса токена Unsplash")
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        return request
    }
    // MARK: - Token Fetching
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        let url = makeOAuthTokenRequest(code: code)
        
        let task = URLSession.shared.data(for: url) { result in
            switch result {
            case .success(let data):
                do {
                    let tokenResponse = try self.decoder.decode(OAuthTokenResponseBody.self, from: data)
                    guard let accessToken = tokenResponse.accessToken else {
                        throw NetworkError.missingToken
                    }
                    completion(.success(accessToken))
                } catch {
                    print("Ошибка декодирования:\(error.localizedDescription)")
                    completion(.failure(error))
                }
            case .failure(let error):
                print("Ошибка сети:\(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
