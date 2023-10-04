//
//  PhotoExplorerApp.swift
//  PhotoExplorer
//
//  Created by Marcel Mravec on 02.10.2023.
//

import SwiftUI

@main
struct PhotoExplorerApp: App {
    let flickrOAuthService = FlickrOAuthService() // Create an instance of FlickrOAuthService
    
    var body: some Scene {
        WindowGroup {
            
            ContentView(flickrOAuthService: flickrOAuthService)
        }
    }
}
