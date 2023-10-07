//
//  ContentView.swift
//  PhotoExplorer
//
//  Created by Marcel Mravec on 02.10.2023.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: FlickrAuthViewModel
    @State private var selectedTab: Int = 0  // 0 for main view, 1 for settings
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Main View Tab
            Text("PhotoExplorer")
                .tabItem {
                    Image(systemName: "photo")
                    Text("Explore")
                }.tag(0)
            
            // Settings Tab
            VStack(spacing: 20) {
                Text("Authentication State: \(viewModel.isAuthenticated ? "Authenticated" : "Not Authenticated")")
                
                if viewModel.isAuthenticated {
                    Button("Logout") {
                        viewModel.logout()
                    }
                } else {
                    Button("Authenticate") {
                        viewModel.authenticate()
                    }
                }
            }
            .padding()
            .tabItem {
                Image(systemName: "gearshape")
                Text("Settings")
            }.tag(1)
        }
        .sheet(isPresented: $viewModel.showSheet) {
                    if let authUrl = viewModel.oauthService.authUrl {
                        SafariView(url: authUrl)
                            .edgesIgnoringSafeArea(.all)
                            .onDisappear {
                                viewModel.showSheet = false
                            }
                    }
                }
    }
}


#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(FlickrAuthViewModel()) // Initialize the viewModel
    }
}
#endif
