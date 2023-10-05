//
//  PhotoExplorerApp.swift
//  PhotoExplorer
//
//  Created by Marcel Mravec on 02.10.2023.
//

import SwiftUI

@main
struct PhotoExplorerApp: App {
    @StateObject private var flickrAuthViewModel = FlickrAuthViewModel(flickrOAuthService: FlickrOAuthService())

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(flickrAuthViewModel)
                .onOpenURL { url in
                    // Check if the URL scheme matches your app's URL scheme
                    if url.scheme == FLICKR_URL_SCHEME {
                        flickrAuthViewModel.handleOAuthCallback(url: url)
                    }
                }
        }
    }
}
