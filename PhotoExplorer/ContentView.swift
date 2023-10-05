//
//  ContentView.swift
//  PhotoExplorer
//
//  Created by Marcel Mravec on 02.10.2023.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var viewModel: FlickrAuthViewModel
    @State private var isShowingSafariView = false
    @State private var safariURL: URL?
    
    //    init(flickrOAuthService: FlickrOAuthService) {
    //        self.viewModel = FlickrAuthViewModel(flickrOAuthService: flickrOAuthService)
    //    }
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Authentication State: \(viewModel.authenticationState.rawValue)")
                    .padding()
                
                if viewModel.authenticationState == .noAuthenticationAttempted {
                    Button("Authorize") {
                        viewModel.authorize()
                    }
                    .padding()
                } else if viewModel.authenticationState == .successfullyAuthenticated {
                    Text("Authenticated!")
                        .padding()
                    Button("Get User Photos") {
                        viewModel.getUserPhotos { result in
                            switch result {
                            case .success(let data):
                                print("Success, we got data: \(data).count")
                            case .failure(let error):
                                // Handle error
                                print("Failed to fetch user photos: \(error)")
                            }
                        }
                    }
                    .padding()
                    
                    Button("Logout") {
                        viewModel.logout()
                    }
                    .padding()
                }
                
                if let authUrl = viewModel.authUrl {
                    Text("Auth URL: \(authUrl)")
                    NavigationLink("", destination: SafariView(url: authUrl), isActive: $isShowingSafariView)
                        .hidden()
                        .onAppear {
                            safariURL = authUrl
                            isShowingSafariView = true
                        }
                        .onChange(of: viewModel.isAuthenticationCompleted) { isCompleted in
                            if isCompleted {
                                isShowingSafariView = false // Dismiss SafariView
                            }
                        }
                }
            }
            .navigationTitle("Flickr OAuth Example")
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
//        let flickrOAuthService = FlickrOAuthService()
        
        return ContentView()
    }
}
#endif
