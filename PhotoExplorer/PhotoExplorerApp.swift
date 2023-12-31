//
//  PhotoExplorerApp.swift
//  PhotoExplorer
//
//  Created by Marcel Mravec on 02.10.2023.
//

import SwiftUI

@main
struct PhotoExplorerApp: App {
    @StateObject private var flickrAuthViewModel = FlickrAuthViewModel()
    @StateObject private var locationManager = LocationService()
    @StateObject private var mapViewModel = MapViewModel()
    @StateObject private var flickrSettings = FlickrSettings()
    @StateObject private var flickrPhotoService = FlickrPhotoService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(flickrAuthViewModel)
                .environmentObject(locationManager)
                .environmentObject(mapViewModel)
                .environmentObject(flickrSettings)
                .environmentObject(flickrPhotoService)
                .onOpenURL { url in
                            // Check if the URL scheme matches your app's URL scheme
                            if url.scheme == FLICKR_URL_SCHEME {
                                NotificationCenter.default.post(name: .flickrCallback, object: url)
                            }
                        }
        }
    }
}
