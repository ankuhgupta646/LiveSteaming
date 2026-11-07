import Foundation

/// Local-only simulation. This does not connect to a server or other viewers.
@MainActor
final class DemoCommentSimulator {
    private var task: Task<Void, Never>?

    func start(onComment: @escaping @MainActor () -> Void) {
        stop()
        task = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(4))
                guard !Task.isCancelled else { break }
                onComment()
            }
        }
    }

    func stop() {
        task?.cancel()
        task = nil
    }

    deinit {
        task?.cancel()
    }
}
