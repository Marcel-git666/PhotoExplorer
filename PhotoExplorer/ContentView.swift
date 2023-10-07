//
//  ContentView.swift
//  PhotoExplorer
//
//  Created by Marcel Mravec on 02.10.2023.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: FlickrAuthViewModel
    @State private var showSafariView = false
    
    var body: some View {
        VStack {
            if viewModel.isAuthenticated {
                Text("User is authenticated!")
                Button("Logout") {
                    viewModel.logout()
                }
            } else {
                Button("Authenticate") {
                    showSafariView = true
                }
            }
        }
        .padding()
        .sheet(isPresented: $viewModel.oauthService.showSheet) {
                    SafariView(url: viewModel.oauthService.authUrl!)
                        .edgesIgnoringSafeArea(.all)
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
