import Foundation

import Constant

public extension UserDefaults {
    static let app = UserDefaults(suiteName: UserDefaultsSuitName.app.rawValue)!
}
