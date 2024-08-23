import Foundation

enum HealthDataError: Error, LocalizedError {
    /// データ操作の許可がされていない
    case notAvailable
    /// 読み込み失敗
    case loadFailed(Error?)
}
