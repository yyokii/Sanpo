import Foundation

public struct WeatherDataAttribution {
    public let imageURL: URL
    public let url: URL

    public init?(imageURL: URL?, url: URL?) {
        guard let imageURL, let url else { return nil }
        self.imageURL = imageURL
        self.url = url
    }
}
