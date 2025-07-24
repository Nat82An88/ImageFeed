import Foundation
import WebKit

final class ProfileLogoutService {
    
    static let shared = ProfileLogoutService()
    
    private init() { }
    
    func logout() {
        cleanCookies()
        resetProfileData()
    }
    
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    private func resetProfileData() {
        OAuth2TokenStorage.shared.token = nil
        ProfileService.shared.reset()
        ProfileImageService.shared.reset()
    }
    
}
