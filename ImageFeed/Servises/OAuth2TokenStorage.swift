import UIKit
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    private let key = "accessToken"
    var token: String? {
        get {
            return KeychainWrapper.standard.string(forKey: key)
        }
        set {
            guard let newValue else {
                let success = KeychainWrapper.standard.removeObject(forKey: key)
                assert(success, "Failed to remove access token from keychain")
                return
            }
            let success = KeychainWrapper.standard.set(newValue, forKey: key)
            assert(success, "Failed to save access token to keychain")
        }
    }
}
