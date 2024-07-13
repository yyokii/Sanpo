import Foundation

enum TabItem: Identifiable, CaseIterable {
    case home
    case myPage

    var id: String {
        switch self {
        case .home:
            return "Today"
        case .myPage:
            return "Data"
        }
    }

    var title: String {
        switch self {
        case .home:
            return "Today"
        case .myPage:
            return "Data"
        }
    }

    var iconName: String {
        switch self {
        case .home:
            return "figure.walk"
        case .myPage:
            return "clock"
        }
    }
}
