# Native iOS Live Streaming Demo (SwiftUI)

A single-screen Instagram Live-inspired **local UI demo** using Swift, SwiftUI, MVVM, and a small local comment simulator.

## What works locally

- SwiftUI live-style layout and controls
- Add comments from the text field
- Animated hearts
- Follow/unfollow, mute toggle, show/hide comments
- Simulated viewer count and generated demo comments
- End/restart demo session

## What is simulated

The default video background is a visual placeholder, not a video feed.
Comments and viewer count are local-only; they are not shared with other users.
The mute button changes UI state only while using the placeholder.
Follow and end/restart actions do not call a server.

## Open in Xcode

1. In Xcode, choose **File → New → Project → iOS → App**.
2. Set Interface to **SwiftUI**, Language to **Swift**.
3. Name it `LiveStreamSwiftUIDemo`.
4. Add the included `.swift` files to the project (ensure **Copy items if needed** and your app target are selected).
5. Organize files into `Models`, `ViewModels`, `Services`, and `Views` groups if desired.
6. Set deployment target to **iOS 17 or later**.
7. Build and run on an iPhone simulator or device. No third-party package is required.

Alternatively, create a new Xcode project, replace its generated app entry point with `LiveStreamSwiftUIDemoApp.swift`, and add the other source files.

## Play a real HLS stream

In `Views/LiveStreamView.swift`, replace:

```swift
private let streamURL: URL? = nil
```

with a valid, permitted HLS URL ending in `.m3u8`, for example a URL supplied by your streaming provider:

```swift
private let streamURL = URL(string: "https://YOUR-CDN.example.com/live/playlist.m3u8")
```

The provided `VideoPlayer(player: AVPlayer(url: streamURL))` path plays supported HLS video. For production, manage the `AVPlayer` lifecycle, playback status, buffering, errors, and app background/foreground transitions. The sample does not include a real stream URL.

**Playback is not broadcasting.** To broadcast camera video, use a streaming SDK or implement capture/encoding and publish to a compatible ingest service (commonly WebRTC or RTMP-based ingest). Protect stream credentials and use TLS.

## Production architecture to explain in an interview

- **View (`LiveStreamView`)**: renders UI and forwards user actions.
- **ViewModel (`LiveStreamViewModel`)**: owns UI state and user actions.
- **Model (`LiveComment`)**: represents one chat message.
- **Service (`DemoCommentSimulator`)**: simulates server events locally.

For a production system, replace the simulator with services such as:
- `StreamingPlayerService`: AVPlayer/HLS playback and player state.
- `LiveChatService`: authenticated WebSocket or provider SDK for real-time chat.
- `LiveSessionService`: fetch live session metadata and server-authoritative viewer count.
- `LiveBroadcastService`: camera capture and publishing, if the user is the broadcaster.

Use reconnection/backoff, message IDs and ordering, rate limiting, moderation, authentication, analytics, and tests. Do not store streaming secrets in the app.
