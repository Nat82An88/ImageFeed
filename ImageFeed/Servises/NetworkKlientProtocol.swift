import Foundation

protocol NetworkRouting {
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void)
}
