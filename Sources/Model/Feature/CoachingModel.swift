import Foundation
import Service

@Observable
public class CoachingModel {
    private let aiClient: AIClientProtocol

    public init(
        aiClient: AIClientProtocol
    ) {
        self.aiClient = aiClient
    }
}
