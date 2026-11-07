//
//  LiveSteamingDemoApp.swift
//  LiveSteamingDemo
//
//  Created by APPLE on 22/10/26.
//

import SwiftUI

@main
struct LiveSteamingDemoApp: App {
    var body: some Scene {
        WindowGroup {
            LiveStreamView()
                .preferredColorScheme(.dark)
        }
    }
}
