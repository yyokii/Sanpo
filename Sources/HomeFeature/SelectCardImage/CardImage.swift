import Foundation

enum CardImage: CaseIterable {
    case cliffSea1
    case cliffSea2
    case cliffSea3
    case countryside1
    case countryside2
    case desert1
    case desert2
    case forest1
    case forest2
    case lake1
    case lake2
    case mountain1
    case mountain2
    case mountain3
    case night1
    case sea1
    case snow1
    case snow2
    case starryNightSky1
    case starryNightSky2

    var fileName: String {
        switch self {
        case .cliffSea1:
            return "cliff-sea-1"
        case .cliffSea2:
            return "cliff-sea-2"
        case .cliffSea3:
            return "cliff-sea-3"
        case .countryside1:
            return "countryside-1"
        case .countryside2:
            return "countryside-2"
        case .desert1:
            return "desert-1"
        case .desert2:
            return "desert-2"
        case .forest1:
            return "forest-1"
        case .forest2:
            return "forest-2"
        case .lake1:
            return "lake-1"
        case .lake2:
            return "lake-2"
        case .mountain1:
            return "mountain-1"
        case .mountain2:
            return "mountain-2"
        case .mountain3:
            return "mountain-3"
        case .night1:
            return "night-1"
        case .sea1:
            return "sea-1"
        case .snow1:
            return "snow-1"
        case .snow2:
            return "snow-2"
        case .starryNightSky1:
            return "starry-night-sky-1"
        case .starryNightSky2:
            return "starry-night-sky-2"
        }
    }

    var title: String {
        switch self {
        case .cliffSea1:
            return "Cliff Sea 1"
        case .cliffSea2:
            return "Cliff Sea 2"
        case .cliffSea3:
            return "Cliff Sea 3"
        case .countryside1:
            return "Countryside 1"
        case .countryside2:
            return "Countryside 2"
        case .desert1:
            return "Desert 1"
        case .desert2:
            return "Desert 2"
        case .forest1:
            return "Forest 1"
        case .forest2:
            return "Forest 2"
        case .lake1:
            return "Lake 1"
        case .lake2:
            return "Lake 2"
        case .mountain1:
            return "Mountain 1"
        case .mountain2:
            return "Mountain 2"
        case .mountain3:
            return "Mountain 3"
        case .night1:
            return "Night 1"
        case .sea1:
            return "Sea 1"
        case .snow1:
            return "Snow 1"
        case .snow2:
            return "Snow 2"
        case .starryNightSky1:
            return "Starry Night Sky 1"
        case .starryNightSky2:
            return "Starry Night Sky 2"
        }
    }
}
