//
//  MenuBarController.swift
//  YTMusic-macos
//
//  Created by Francesco Vezzani on 03/11/25.
//

import AppKit
import SwiftUI
import Combine

@MainActor
class MenuBarController: ObservableObject {
    private var statusBarItem: NSStatusItem?
    
    init() {
        setupMenuBar()
    }
    
    private func setupMenuBar() {
        // Create status bar item
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        // Create menu
        let menu = NSMenu()
        
        // Open Window menu item
        let openItem = NSMenuItem(title: "Open YouTube Music", action: #selector(openWindow), keyEquivalent: "")
        openItem.target = self
        menu.addItem(openItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Quit menu item
        let quitItem = NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        
        statusBarItem?.menu = menu
        
        // Set button title (simple text to avoid shader issues)
        if let button = statusBarItem?.button {
            button.title = "?"
            button.font = NSFont.systemFont(ofSize: 16)
        }
    }
    
    @objc private func openWindow() {
        // Find and show the main window
        if let window = NSApplication.shared.windows.first(where: { $0.isMainWindow || $0.isKeyWindow }) {
            window.makeKeyAndOrderFront(nil)
        } else {
            // Create new window if none exists
            if let window = NSApplication.shared.windows.first {
                window.makeKeyAndOrderFront(nil)
            }
        }
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
    
    deinit {
        if let statusBarItem = statusBarItem {
            NSStatusBar.system.removeStatusItem(statusBarItem)
        }
    }
}
