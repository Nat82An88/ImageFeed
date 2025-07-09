import Foundation

struct Profile: Codable {
    let username: String
    let name: String
    let loginName: String
    let bio: String?
    
    init(from profileResult: ProfileResult) {
        self.username = profileResult.username
        self.name = "\(profileResult.first_name) \(profileResult.last_name)"
        self.loginName = "@\(profileResult.username)"
        self.bio = profileResult.bio
    }
}
