import Foundation

protocol NetworkRouting {
    
    func fetchOAuthToken(code: String, handler: @escaping (Result<Data, Error>) -> Void)
}
