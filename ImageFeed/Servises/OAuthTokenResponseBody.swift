import Foundation

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String?
    let tokenType: String
    let refreshToken: String
    let scope: String
    let createdAt: Date
    let userId: Int
    let username: String
    
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case refreshToken = "refresh_token"
        case scope
        case createdAt = "created_at"
        case userId = "user_id"
        case username
    }
    init (from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        accessToken = try container.decodeIfPresent(String.self, forKey: .accessToken)
        guard let accessToken, !accessToken.isEmpty else {
            throw DecodingError.dataCorrupted(.init(codingPath: container.codingPath, debugDescription: "Access token is missing or empty"))
        }
        tokenType = try container.decode(String.self, forKey: .tokenType)
        refreshToken = try container.decode(String.self, forKey: .refreshToken)
        scope = try container.decode(String.self, forKey: .scope)
        let createdAtTimestamp = try container.decode(Int.self, forKey: .createdAt)
        createdAt = Date(timeIntervalSince1970: TimeInterval(createdAtTimestamp))
        userId = try container.decode(Int.self, forKey: .userId)
        username = try container.decode(String.self, forKey: .username)
    }
}
