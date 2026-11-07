import Foundation

struct LiveComment: Identifiable, Equatable {
    let id = UUID()
    let username: String
    let message: String
    let isHost: Bool
}
