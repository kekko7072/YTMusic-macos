//
//  ContentView.swift
//  YTMusic-macos
//
//  Created by Francesco Vezzani on 03/11/25.
//

import SwiftUI

struct ContentView: View {
    @State private var isLoading = true
    @State private var loadingMessageIndex = 0
    @State private var pulseScale: CGFloat = 1.0
    @State private var messageTimer: Timer?
    private let youtubeMusicURL = URL(string: "https://music.youtube.com")!
    
    private let loadingMessages = [
        "Tuning the music vibes...",
        "Warming up the speakers...",
        "Summoning the perfect playlist...",
        "Preparing your audio journey...",
        "Fine-tuning the sound waves...",
        "Getting the rhythm ready...",
        "Almost there, hold the beat...",
        "Polishing the sound quality..."
    ]
    
    var body: some View {
        ZStack {
            // Black background to match YouTube Music theme
            Color.black
                .ignoresSafeArea()
            
            // WebView
            WebView(url: youtubeMusicURL, isLoading: $isLoading)
                .frame(minWidth: 1200, minHeight: 800)
            
            // Loading indicator
            if isLoading {
                VStack(spacing: 30) {
                    // Animated progress indicator with pulse effect
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.2), lineWidth: 4)
                            .frame(width: 80, height: 80)
                            .scaleEffect(pulseScale)
                            .opacity(2 - pulseScale)
                        
                        ProgressView()
                            .scaleEffect(1.5)
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    }
                    
                    // Animated loading message
                    Text(loadingMessages[loadingMessageIndex])
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .semibold))
                        .transition(.opacity.combined(with: .scale))
                        .id(loadingMessageIndex)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.85))
                .onAppear {
                    startAnimations()
                }
                .onDisappear {
                    stopAnimations()
                }
                .onChange(of: isLoading) { newValue in
                    if !newValue {
                        stopAnimations()
                    }
                }
            }
        }
    }
    
    private func startAnimations() {
        // Pulse animation
        withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
            pulseScale = 1.3
        }
        
        // Message rotation
        messageTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            if isLoading {
                withAnimation(.easeInOut(duration: 0.5)) {
                    loadingMessageIndex = (loadingMessageIndex + 1) % loadingMessages.count
                }
            }
        }
    }
    
    private func stopAnimations() {
        messageTimer?.invalidate()
        messageTimer = nil
        pulseScale = 1.0
        loadingMessageIndex = 0
    }
}

#Preview {
    ContentView()
}
