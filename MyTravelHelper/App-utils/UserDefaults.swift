
import Foundation

extension UserDefaults {
    static var key = "FAV_KEY"
    static var shared: UserDefaults {
        let combined = UserDefaults.standard
        combined.addSuite(named: "com.example.com.")
        return combined
    }
    
    func setFavourite(name: String) {
        UserDefaults.shared.setValue(name, forKey: UserDefaults.key)
    }
    
    func removeFavourite(name: String) {
        UserDefaults.shared.removeObject(forKey: UserDefaults.key)
    }

    func getFavourite() -> String? {
        guard let key = UserDefaults.shared.object(forKey: UserDefaults.key) else { return nil }
        return (key as! String)
    }
}
