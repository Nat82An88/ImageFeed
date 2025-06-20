import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case noToken
    case decodingError(Error)
    case invalidBaseURL
    case invalidURLComponents
}

extension URLSession {
    func data(
        for request: URLRequest, tokenStorage: OAuth2TokenStorage,
        completion: @escaping (Result<String?, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletionOnTheMainThread: (Result<String?, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        let task = URLSession.shared.dataTask(with: request) { data, responce, error in
            if let error {
                print("Сетевая ошибка:\(error)")
                fulfillCompletionOnTheMainThread(.failure(error))
                return
            }
            guard let data else {
                let error = NSError(domain: "No data", code: 0, userInfo: nil)
                fulfillCompletionOnTheMainThread(.failure(error))
                return
            }
                do {
                    let tokenResponse = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                    let token = tokenResponse.accessToken
                    tokenStorage.token = token
                    fulfillCompletionOnTheMainThread(.success(token))
                }
                catch {
                    print(" Ошибка декодирования токена: \(error)")
                    fulfillCompletionOnTheMainThread(.failure(error))
                }
            }
            task.resume()
            return task
        }
    }
