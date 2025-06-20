import Foundation

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String?
    let tokenType: String
    let scope: String
    let createdAt: Int
    let expiresIn: Int
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case scope
        case createdAt = "created_at"
        case expiresIn = "expires_in"
    }
}
