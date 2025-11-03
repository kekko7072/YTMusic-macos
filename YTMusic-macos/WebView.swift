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
    @Binding var isLoading: Bool
    
    func makeNSView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = WKWebsiteDataStore.default()
        
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        configuration.preferences = preferences
        
        configuration.applicationNameForUserAgent = "YTMusic-macos"
        configuration.allowsAirPlayForMediaPlayback = false
        configuration.mediaTypesRequiringUserActionForPlayback = []
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Safari/605.1.15"
        
        // Set background to black
        webView.setValue(false, forKey: "drawsBackground")
        
        #if DEBUG
        if #available(macOS 13.0, *) {
            webView.isInspectable = true
        }
        #endif
        
        // Load URL immediately when view is created
        let request = URLRequest(url: url)
        webView.load(request)
        
        return webView
    }
    
    func updateNSView(_ webView: WKWebView, context: Context) {
        // Only reload if URL has changed
        if let currentURL = webView.url, currentURL.absoluteString != url.absoluteString {
            let request = URLRequest(url: url)
            webView.load(request)
        } else if webView.url == nil {
            // If no URL is loaded, load it
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(isLoading: $isLoading)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        @Binding var isLoading: Bool
        private var mainFrameNavigation: WKNavigation?
        private var hasLoadedInitially = false
        private var initialURL: String?
        
        init(isLoading: Binding<Bool>) {
            _isLoading = isLoading
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            // Store initial URL if not set yet
            if initialURL == nil && !hasLoadedInitially {
                let isMainFrame = navigationAction.targetFrame?.isMainFrame ?? true
                if isMainFrame {
                    initialURL = navigationAction.request.url?.absoluteString ?? ""
                }
            }
            
            decisionHandler(.allow)
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
            decisionHandler(.allow)
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            // Only show loading for initial load, not for subsequent navigations
            // This prevents loading screen from appearing during scrolling or SPA navigation
            if !hasLoadedInitially {
                mainFrameNavigation = navigation
                isLoading = true
                #if DEBUG
                if let url = webView.url {
                    print("Initial loading: \(url.absoluteString)")
                }
                #endif
            }
        }
        
        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            // This is called when content starts loading for the frame
            #if DEBUG
            if !hasLoadedInitially {
                print("Committed initial navigation")
            }
            #endif
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Hide loading when main frame finishes
            // Only update if this is the initial load
            if !hasLoadedInitially && navigation == mainFrameNavigation {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    // Mark initial load as complete and hide loading
                    self.hasLoadedInitially = true
                    self.isLoading = false
                    self.mainFrameNavigation = nil
                }
                #if DEBUG
                print("Initial page loaded successfully!")
                #endif
            }
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            let nsError = error as NSError
            let harmlessCodes = [102, 204] // Frame load interrupted, Plug-in handled load
            
            if !harmlessCodes.contains(nsError.code) {
                print("Navigation failed: \(error.localizedDescription)")
            }
            
            // Hide loading on failure only if it's the initial load
            if !hasLoadedInitially && navigation == mainFrameNavigation {
                hasLoadedInitially = true
                isLoading = false
                mainFrameNavigation = nil
            }
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            let nsError = error as NSError
            let harmlessCodes = [102, 204]
            
            if !harmlessCodes.contains(nsError.code) {
                print("Provisional navigation failed: \(error.localizedDescription) (Code: \(nsError.code))")
            }
            
            // Hide loading on failure only if it's the initial load
            if !hasLoadedInitially && navigation == mainFrameNavigation {
                hasLoadedInitially = true
                isLoading = false
                mainFrameNavigation = nil
            }
        }
    }
}
