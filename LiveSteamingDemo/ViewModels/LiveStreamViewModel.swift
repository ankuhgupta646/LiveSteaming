import Foundation
import SwiftUI
import Combine
@MainActor
final class LiveStreamViewModel: ObservableObject {
    @Published var comments: [LiveComment] = [
        .init(username: "riya_k", message: "Love this! ❤️", isHost: false),
        .init(username: "arjun.dev", message: "Audio is clear 🔥", isHost: false),
        .init(username: "host", message: "Thanks for joining everyone!", isHost: true)
    ]
    @Published var viewerCount = 128
    @Published var commentDraft = ""
    @Published var isFollowing = false
    @Published var isMuted = false
    @Published var isShowingComments = true
    @Published var isLive = true
    @Published var hearts: [UUID] = []

    private let demoReplies: [(String, String)] = [
        ("meera", "Watching from Pune 👋"),
        ("ios_learner", "Can you explain SwiftUI animations?"),
        ("devraj", "This is awesome!"),
        ("nisha", "❤️❤️❤️"),
        ("mobile_minds", "Hello everyone!")
    ]
    private var replyIndex = 0

    func sendComment() {
        let message = commentDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !message.isEmpty else { return }
        comments.append(.init(username: "you", message: message, isHost: false))
        commentDraft = ""
        trimCommentsIfNeeded()
    }

    func addHeart() {
        let id = UUID()
        hearts.append(id)
        // The view removes the heart after its animation.
    }

    func removeHeart(_ id: UUID) {
        hearts.removeAll { $0 == id }
    }

    func toggleFollow() {
        isFollowing.toggle()
    }

    func toggleMute() {
        isMuted.toggle()
    }

    func toggleComments() {
        isShowingComments.toggle()
    }

    func endDemoStream() {
        isLive = false
    }

    func restartDemoStream() {
        isLive = true
        viewerCount = 128
    }

    func addDemoComment() {
        guard isLive, !demoReplies.isEmpty else { return }
        let reply = demoReplies[replyIndex % demoReplies.count]
        replyIndex += 1
        comments.append(.init(username: reply.0, message: reply.1, isHost: false))
        viewerCount += Int.random(in: 0...2)
        trimCommentsIfNeeded()
    }

    private func trimCommentsIfNeeded() {
        // Keep the most recent comments in memory for this demo.
        if comments.count > 40 {
            comments.removeFirst(comments.count - 40)
        }
    }
}
