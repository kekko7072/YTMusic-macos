//
//  YTMusic_macosApp.swift
//  YTMusic-macos
//
//  Created by Francesco Vezzani on 03/11/25.
//

import SwiftUI
import AppKit

@main
struct YTMusic_macosApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .background(Color.black)
                .onAppear {
                    // Set window background to black
                    if let window = NSApplication.shared.windows.first {
                        window.backgroundColor = .black
                        window.isOpaque = false
                    }
                }
        }
        .windowStyle(.automatic)
        .defaultSize(width: 1400, height: 900)
        .windowToolbarStyle(.unified)
        .commands {
            CommandGroup(replacing: .newItem) {}
        }
    }
}
