//
//  ContentView.swift
//  YTMusic-macos
//
//  Created by Francesco Vezzani on 03/11/25.
//

import SwiftUI

struct ContentView: View {
    private let youtubeMusicURL = URL(string: "https://music.youtube.com")!
    
    var body: some View {
        WebView(url: youtubeMusicURL)
            .frame(minWidth: 1200, minHeight: 800)
    }
}

#Preview {
    ContentView()
}
