import Foundation

func checkAllHealthDataFetch() async throws {
    let now: Date = .now
    _ = try await ActiveEnergyBurned.load(for: now)
    _ = try await DistanceWalkingRunning.today()
    _ = try await StepCount.load(for: now)
    _ = try await WalkingSpeed.load(for: now)
    _ = try await WalkingStepLength.load(for: now)
}
