//
//  WebView.swift
//  YTMusic-macos
//
//  Created by Francesco Vezzani on 03/11/25.
//

import SwiftUI
import WebKit

struct WebView: NSViewRepresentable {
    let url: URL
    
    func makeNSView(context: Context) -> WKWebView {
        // Configure website data store with persistent cookie storage
        let configuration = WKWebViewConfiguration()
        
        // Use non-persistent data store first, then switch to persistent if needed
        // This helps with sandbox compatibility
        let dataStore = WKWebsiteDataStore.default()
        configuration.websiteDataStore = dataStore
        
        // Configure preferences for better sandbox compatibility
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        configuration.preferences = preferences
        
        // Set user agent to ensure proper compatibility
        configuration.applicationNameForUserAgent = "YTMusic-macos"
        
        // Configure process pool for better resource management
        let processPool = WKProcessPool()
        configuration.processPool = processPool
        
        // Create web view
        let webView = WKWebView(frame: .zero, configuration: configuration)
        
        // Configure preferences
        webView.navigationDelegate = context.coordinator
        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Safari/605.1.15"
        
        // Allow media playback
        webView.configuration.allowsAirPlayForMediaPlayback = false
        webView.configuration.mediaTypesRequiringUserActionForPlayback = []
        
        // Enable developer extras (optional, for debugging)
        #if DEBUG
        if #available(macOS 13.0, *) {
            webView.isInspectable = true
        }
        #endif
        
        return webView
    }
    
    func updateNSView(_ webView: WKWebView, context: Context) {
        // Load URL if not already loaded
        if webView.url == nil || webView.url?.absoluteString != url.absoluteString {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            // Allow all navigation
            decisionHandler(.allow)
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Optionally inject JavaScript or handle page load completion
            print("? Page loaded successfully!")
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("? Navigation failed: \(error.localizedDescription)")
        }
    }
}
