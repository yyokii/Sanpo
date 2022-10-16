import Foundation
import os.log

public extension Logger {
    enum Category: String {
        case model = "Model"
        case service = "Service"
        case view = "View"
    }

    /// Create logger for app with Category.
    init(category: Category, file: String = #file) {
        var filename: String = ""
        if let match = file.range(of: "[^/]*$", options: .regularExpression) {
            filename = String(file[match])
        }
        self.init(subsystem: Bundle.main.bundleIdentifier!, category: "\(category.rawValue): \(filename)")
    }
}
