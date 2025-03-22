import FirebaseFirestore
import FirebaseAuth

public protocol AppClientProtocol {
    // User status
    func registerStateListener(userUpdatedListener: @escaping () -> Void)
}

public class AppClient: AppClientProtocol {

    var user: AppUser = .getUninitializedData()

    private var authListenerHandle: AuthStateDidChangeListenerHandle?
    private var db: Firestore!

    public static let shared = AppClient()

    private init() {
        db = Firestore.firestore()
    }

    public func registerStateListener(userUpdatedListener: @escaping () -> Void) {
        if let authListenerHandle {
            Auth.auth().removeStateDidChangeListener(authListenerHandle)
        }

        authListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] (_, user) in
            guard let self = self else { return }

            self.user = AppUser(from: user)

            if self.user.status == .uninitialized {
                Task {
                    do {
                        let user = try await self.signInAnonymously()
                        self.user = user
                        userUpdatedListener()
                    } catch {
                        print("🚨 failed signInAnonymously")
                    }
                }
            } else {
                print("📝 User signed in.\nUser status:\(self.user.status)\nUser ID: \(self.user.id)\n")
                userUpdatedListener()
            }
        }
    }

    private func signInAnonymously() async throws -> AppUser {
        let user: User? = Auth.auth().currentUser
        let appUser = AppUser(from: user)

        switch appUser.status {
        case .uninitialized:
            let result = try await Auth.auth().signInAnonymously()
            return .init(from: result.user)
        case .authenticatedAnonymously, .authenticated:
            return appUser
        }
    }
}

public enum AppClientError: Error, LocalizedError {
    /// データが存在しない
    case notFoundItem
    /// 画像のアップロードに失敗
    case failedCrateImageData

    public var recoverySuggestion: String? {
        switch self {
        case .notFoundItem:
            "not-found-item-error"
        case .failedCrateImageData:
            "failed-create-image-data"
        }
    }
}
