import UIKit

final class OAuth2Service {
    
    static let shared = OAuth2Service()
    private init() {}
    
    func makeOAuthTokenRequest(code: String) -> URLRequest {
        guard let baseURL = URL(string: "https://unsplash.com") else {
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
            fatalError("Не удалось сформировать URL для запроса токена Unsplash")
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        return request
    }
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        let request = makeOAuthTokenRequest(code: code)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error {
                print("Сетевая ошибка: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            guard let response = response as? HTTPURLResponse else {
                print("Ошибка: Не удалось получить HTTP ответ")
                completion(.failure(NetworkError.httpStatusCode(500)))
                return
            }
            guard response.statusCode >= 200 && response.statusCode < 300 else {
                print("Ошибка сервера: \(response.statusCode)")
                completion(.failure(NetworkError.httpStatusCode(response.statusCode)))
                return
            }
            guard let data else {
                print( "Ошибка: Нет данных в ответе")
                completion(.failure(NetworkError.httpStatusCode(500)))
                return
            }
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                guard let accessToken = response.accessToken else {
                    completion(.failure(NetworkError.noToken))
                    return
                }
                completion(.success(accessToken))
            } catch {
                print( "Ошибка декодирования JSON: \(error.localizedDescription)")
                completion(.failure(NetworkError.decodingError(error)))
            }
        }
        task.resume()
    }
}
