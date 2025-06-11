import Foundation

struct NetworkClient: NetworkRouting {
    private enum NetworkError: Error {
        case codeError
    }
    func fetchOAuthToken(code: String, handler: @escaping (Result<Data, Error>) -> Void) {
        let request = OAuth2Service.shared.makeOAuthTokenRequest(code: code)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error {handler(.failure(error)); return
            }
            guard let response = response as? HTTPURLResponse else {
                handler(.failure(NetworkError.codeError))
                return
            }
            guard response.statusCode >= 200 && response.statusCode < 300 else {
                handler(.failure(NetworkError.codeError))
                return
            }
            guard let data else {
                handler(.failure(NetworkError.codeError))
                return
            }
            handler(.success(data))
        }
        task.resume()
    }
}
