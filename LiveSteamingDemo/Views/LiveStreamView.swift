import SwiftUI
import AVKit

struct LiveStreamView: View {
    @StateObject private var viewModel = LiveStreamViewModel()
    @State private var showEndConfirmation = false

    // Replace with your own permitted HLS test/live URL to play real video.
    // An HLS URL is for playback; it does not publish the phone camera.
    private let streamURL: URL? = nil

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                videoBackground
                    .ignoresSafeArea()

                LinearGradient(
                    colors: [.black.opacity(0.58), .clear, .clear, .black.opacity(0.76)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    topBar
                    Spacer(minLength: 12)

                    if viewModel.isShowingComments {
                        commentsPanel
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .frame(height: min(geometry.size.height * 0.35, 270))
                    }

                    bottomBar
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 8)

                heartsOverlay
                    .allowsHitTesting(false)

                if !viewModel.isLive {
                    endedOverlay
                }
            }
            .background(.black)
            .preferredColorScheme(.dark)
            .confirmationDialog("End this demo live session?", isPresented: $showEndConfirmation) {
                Button("End live session", role: .destructive) {
                    viewModel.endDemoStream()
                }
                Button("Cancel", role: .cancel) {}
            }
        }
        .task {
            let simulator = DemoCommentSimulator()

            simulator.start {
                viewModel.addDemoComment()
            }

            await withTaskCancellationHandler {
                while !Task.isCancelled {
                    do {
                        try await Task.sleep(for: .seconds(1))
                    } catch {
                        break
                    }
                }
            } onCancel: {
                Task { @MainActor in
                    simulator.stop()
                }
            }
        }
    }

    @ViewBuilder
    private var videoBackground: some View {
        if let streamURL {
            VideoPlayer(player: AVPlayer(url: streamURL))
                .ignoresSafeArea()
        } else {
            // Attractive local placeholder. Replace with VideoPlayer for real HLS playback.
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.19, green: 0.08, blue: 0.30),
                        Color(red: 0.05, green: 0.13, blue: 0.24),
                        Color(red: 0.02, green: 0.03, blue: 0.08)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                Circle()
                    .fill(.purple.opacity(0.28))
                    .frame(width: 280, height: 280)
                    .blur(radius: 55)
                    .offset(x: 90, y: -80)
                Circle()
                    .fill(.pink.opacity(0.20))
                    .frame(width: 230, height: 230)
                    .blur(radius: 50)
                    .offset(x: -100, y: 70)
                VStack(spacing: 12) {
                    Image(systemName: "video.fill")
                        .font(.system(size: 38, weight: .light))
                    Text("LIVE VIDEO PREVIEW")
                        .font(.caption.weight(.bold))
                        .tracking(2)
                    Text("Connect an HLS stream to play real video")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 28)
                }
                .foregroundStyle(.white.opacity(0.85))
            }
            .ignoresSafeArea()
        }
    }

    private var topBar: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle().fill(
                    LinearGradient(colors: [.pink, .orange, .purple],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                Image(systemName: "person.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(.white)
            }
            .frame(width: 42, height: 42)
            .overlay(Circle().stroke(.white.opacity(0.9), lineWidth: 1.5))

            VStack(alignment: .leading, spacing: 2) {
                Text("ankush_live")
                    .font(.subheadline.bold())
                Text("iOS Live Demo")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.72))
            }

            Button {
                viewModel.toggleFollow()
            } label: {
                Text(viewModel.isFollowing ? "Following" : "Follow")
                    .font(.caption.bold())
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(viewModel.isFollowing ? .white.opacity(0.18) : .white)
                    .foregroundStyle(viewModel.isFollowing ? .white : .black)
                    .clipShape(Capsule())
            }

            Spacer(minLength: 4)

            HStack(spacing: 5) {
                Circle().fill(.red).frame(width: 7, height: 7)
                Text("LIVE")
                    .font(.caption2.bold())
            }
            .padding(.horizontal, 9)
            .padding(.vertical, 6)
            .background(.black.opacity(0.45), in: Capsule())

            HStack(spacing: 5) {
                Image(systemName: "eye.fill")
                    .font(.caption2)
                Text(viewModel.viewerCount.formatted())
                    .font(.caption.bold().monospacedDigit())
            }
            .padding(.horizontal, 9)
            .padding(.vertical, 6)
            .background(.black.opacity(0.45), in: Capsule())

            Button {
                showEndConfirmation = true
            } label: {
                Image(systemName: "xmark")
                    .font(.caption.bold())
                    .frame(width: 30, height: 30)
                    .background(.black.opacity(0.45), in: Circle())
            }
            .accessibilityLabel("End demo")
        }
        .foregroundStyle(.white)
    }

    private var commentsPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("LIVE CHAT")
                    .font(.caption2.bold())
                    .tracking(1.4)
                    .foregroundStyle(.white.opacity(0.7))
                Spacer()
                Text("Demo messages")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.55))
            }

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 10) {
                        ForEach(viewModel.comments) { comment in
                            HStack(alignment: .top, spacing: 7) {
                                Text(comment.username)
                                    .font(.caption.bold())
                                    .foregroundStyle(comment.isHost ? .orange : .white)
                                Text(comment.message)
                                    .font(.caption)
                                    .foregroundStyle(.white)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 7)
                            .background(.black.opacity(0.32), in: RoundedRectangle(cornerRadius: 12))
                            .id(comment.id)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .scrollIndicators(.hidden)
                .onChange(of: viewModel.comments.count) { _, _ in
                    if let last = viewModel.comments.last {
                        withAnimation(.easeOut(duration: 0.2)) {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 10)
    }

    private var bottomBar: some View {
        HStack(spacing: 10) {
            HStack(spacing: 8) {
                TextField("Add a comment…", text: $viewModel.commentDraft, axis: .vertical)
                    .lineLimit(1...3)
                    .font(.subheadline)
                    .submitLabel(.send)
                    .onSubmit(viewModel.sendComment)
                    .accessibilityLabel("Comment")

                Button(action: viewModel.sendComment) {
                    Image(systemName: "paperplane.fill")
                        .font(.subheadline)
                        .foregroundStyle(.white)
                }
                .accessibilityLabel("Send comment")
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .background(.white.opacity(0.17), in: Capsule())
            .overlay(Capsule().stroke(.white.opacity(0.15), lineWidth: 1))

            Button(action: viewModel.addHeart) {
                Image(systemName: "heart.fill")
                    .font(.title2)
                    .foregroundStyle(.pink)
                    .frame(width: 42, height: 42)
                    .background(.white.opacity(0.12), in: Circle())
            }
            .accessibilityLabel("Send heart")

            Button(action: viewModel.toggleMute) {
                Image(systemName: viewModel.isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                    .font(.title3)
                    .foregroundStyle(.white)
                    .frame(width: 42, height: 42)
                    .background(.white.opacity(0.12), in: Circle())
            }
            .accessibilityLabel(viewModel.isMuted ? "Unmute" : "Mute")
        }
        .padding(.top, 12)
    }

    private var heartsOverlay: some View {
        GeometryReader { geometry in
            ForEach(Array(viewModel.hearts.enumerated()), id: \.element) { index, id in
                FloatingHeart {
                    viewModel.removeHeart(id)
                }
                .position(
                    x: geometry.size.width * 0.76 + CGFloat(index % 3) * 10,
                    y: geometry.size.height * 0.76
                )
                .id(id)
            }
        }
    }

    private var endedOverlay: some View {
        VStack(spacing: 14) {
            Image(systemName: "video.slash.fill")
                .font(.system(size: 42))
            Text("Live session ended")
                .font(.title2.bold())
            Text("This is a local demo session.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
            Button("Restart demo") {
                viewModel.restartDemoStream()
            }
            .font(.subheadline.bold())
            .padding(.horizontal, 20)
            .padding(.vertical, 11)
            .background(.white, in: Capsule())
            .foregroundStyle(.black)
        }
        .padding(28)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black.opacity(0.78))
    }
}

private struct FloatingHeart: View {
    let onFinished: () -> Void
    @State private var rise = false
    @State private var drift: CGFloat = 0
    @State private var opacity = 1.0

    var body: some View {
        Image(systemName: "heart.fill")
            .font(.system(size: 26))
            .foregroundStyle(.pink)
            .offset(x: drift, y: rise ? -180 : 0)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: 1.6)) {
                    rise = true
                    drift = CGFloat.random(in: -45...45)
                    opacity = 0
                }
                Task { @MainActor in
                    try? await Task.sleep(for: .seconds(1.7))
                    onFinished()
                }
            }
    }
}

#Preview {
    LiveStreamView()
}
