import Foundation

public struct StepCountAnalysis: Codable, Equatable {
    public let trend: String
    public let advice: String
    
    public init(trend: String, advice: String) {
        self.trend = trend
        self.advice = advice
    }
}
