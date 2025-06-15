import Foundation

extension URLSession {
    func mainQueueDataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionTask {
        return dataTask(with:request){ data, response, error in
            DispatchQueue.main.async {
                completionHandler(data, response, error)
            }
        }
    }
}

struct NetworkClient: NetworkRouting {
    
    private enum NetworkError: Error {
        case codeError
        case decodingError(Error)
        case invalidToken
        case noToken
    }
    private let tokenStorage = OAuth2TokenStorage()
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        let request = OAuth2Service.shared.makeOAuthTokenRequest(code: code)
        let task = URLSession.shared.mainQueueDataTask(with: request) {data, response, error in
            if let error {
                print("Сетевая ошибка: \(error.localizedDescription)")
               completion(.failure(error))
                return
            }
            guard let response = response as? HTTPURLResponse else {
                print("Ошибка: Не удалось получить HTTP ответ")
                completion(.failure(NetworkError.codeError))
                return
            }
            guard response.statusCode >= 200 && response.statusCode < 300 else {
                print("Ошибка сервера: \(response.statusCode)")
                completion(.failure(NetworkError.codeError))
                return
            }
            guard let data else {
                print( "Ошибка: Нет данных в ответе")
                completion(.failure(NetworkError.codeError))
                return
            }
            do{
                let decoder = JSONDecoder()
                let response = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                self.tokenStorage.token = response.accessToken
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

struct ErrorResponse: Decodable {
    let errors: String
}

