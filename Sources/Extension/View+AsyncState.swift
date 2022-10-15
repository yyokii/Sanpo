import SwiftUI

public enum AsyncStatePhase {
    case initial
    case loading
    case empty
    case success(Date)
    case failure(Error)

    public var isLoading: Bool {
        if case .loading = self {
            return true
        }

        return false
    }

    public var lastUpdated: Date? {
        if case let .success(date) = self {
            return date
        }

        return nil
    }

    public var error: Error? {
        if case let .failure(error) = self {
            return error
        }

        return nil
    }
}

public extension View {

    @ViewBuilder
    func asyncState<T: Codable,
                           InitialContent: View,
                           LoadingContent: View,
                           EmptyContent: View,
                           FailureContent: View>(_ state: AsyncState<T>,
                                                 initialContent: InitialContent,
                                                 loadingContent: LoadingContent,
                                                 emptyContent: EmptyContent,
                                                 failureContent: FailureContent) -> some View {
        switch state.phase {
        case .initial:
            initialContent
        case .loading:
            loadingContent
        case .empty:
            emptyContent
        case .success:
            self
        case .failure:
            failureContent
        }
    }
}
