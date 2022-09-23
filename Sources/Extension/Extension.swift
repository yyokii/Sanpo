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

extension View {
    @ViewBuilder
    public func asyncState(_ phase: AsyncStatePhase,
                                                 initialContent: View,
                                                 loadingContent: View,
                                                 emptyContent: View,
                                                 failureContent: View) -> some View {
        switch phase {
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

@propertyWrapper
public struct AsyncState<Value: Codable>: DynamicProperty {
    @State public var phase: AsyncStatePhase = .initial

    @State private var value: Value

    public var wrappedValue: Value {
        get { value }
        nonmutating set {
            value = newValue
        }
    }

    public var isEmpty: Bool {
        if (value as AnyObject) is NSNull {
            return true
        } else if let val = value as? Array<Any>, val.isEmpty {
            return true
        } else {
            return false
        }
    }

    public init(wrappedValue value: Value) {
        self._value = State(initialValue: value)
    }

    @State private var retryTask: (() async throws -> Value)? = nil

    public func fetch(expiration: TimeInterval = 120, task: @escaping () async throws -> Value) async {
        self.retryTask = nil

        if !(phase.lastUpdated?.hasExpired(in: expiration) ?? true) {
            return
        }

        Task {
            do {
                phase = .loading
                value = try await task()
                if isEmpty {
                    self.retryTask = task
                    phase = .empty
                } else {
                    phase = .success(Date())
                }
            } catch _ as CancellationError {
                // Keep current state (loading)
            } catch {
                self.retryTask = task
                phase = .failure(error)
            }
        }
    }

    public func retry() async {
        guard let task = retryTask else { return }
        await fetch(task: task)
    }

    public func hasExpired(in interval: TimeInterval) -> Bool {
        phase.lastUpdated?.hasExpired(in: interval) ?? true
    }

    public func invalidate() {
        if case .success = phase {
            phase = .success(.distantPast)
        }
    }
}

extension View {
    @ViewBuilder
    public func asyncState<T: Codable,
                           InitialContent: View,
                           LoadingContent: View,
                           EmptyContent: View,
                           FailureContent: View>(_ state: AsyncState<T>,
                                                 initialContent: InitialContent,
                                                 loadingContent: LoadingContent,
                                                 emptyContent: EmptyContent,
                                                 failureContent: FailureContent) -> some View {
        asyncState(state.phase,
                   initialContent: initialContent,
                   loadingContent: loadingContent,
                   emptyContent: emptyContent,
                   failureContent: failureContent)
    }
}

extension Date {
    func hasExpired(in interval: TimeInterval) -> Bool {
        timeIntervalSince(self) >= interval
    }
}
