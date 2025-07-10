import Foundation

struct PhotoResult: Decodable {
    let id: String
    let createdAt: Date
    let width: Int
    let height: Int
    let description: String?
    let likes: Int
    let likedByUser: Bool
    let urls: UrlsResult
    
    private enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case width, height, description, likes
        case likedByUser = "liked_by_user"
        case urls
    }
}

struct UrlsResult: Decodable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
}
