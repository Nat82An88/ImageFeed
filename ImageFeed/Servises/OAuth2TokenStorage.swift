import UIKit

final class OAuth2TokenStorage {
    private let userDefaults = UserDefaults.standard
    private let key = "accessToken"
    var token: String? {
        get {
            return userDefaults.string(forKey: key)
        }
        set {
            if let newValue = newValue {
                userDefaults.set(newValue, forKey: key)
            } else {
                userDefaults.removeObject(forKey: key)
            }
        }
    }
}
