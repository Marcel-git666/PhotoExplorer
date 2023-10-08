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
            MapView()
                .tabItem {
                    Image(systemName: "photo")
                    Text("Explore")
                }.tag(0)
            PhotosView()
                .tabItem {
                    Image(systemName: "mappin.circle")
                    Text("Coordinate")
                }.tag(1)
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Settings")
                }.tag(2)
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
        
        
        ContentView().environmentObject(FlickrAuthViewModel())
            .environmentObject(MapViewModel())
    }
}
#endif
