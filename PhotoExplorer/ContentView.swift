//
//  ContentView.swift
//  PhotoExplorer
//
//  Created by Marcel Mravec on 02.10.2023.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: FlickrAuthViewModel
    @State private var showSafari = false
    // Create a computed property for the custom binding
    private var debugShowSheetBinding: Binding<Bool> {
        Binding(
            get: {
                print("Reading showSheet: \(self.viewModel.oauthService.showSheet)")
                return self.viewModel.oauthService.showSheet
            },
            set: {
                print("Setting showSheet to \($0)")
                self.viewModel.oauthService.showSheet = $0
            }
        )
    }
    
    var body: some View {
        VStack {
            Button("Open Safari") {
                showSafari = true
            }
            .sheet(isPresented: $showSafari) {
                SafariView(url: URL(string: "https://www.google.com")!)
            }
            
            if viewModel.isAuthenticated {
                // Authenticated UI
            } else {
                Button("Authenticate") {
                    DispatchQueue.main.async {
                        viewModel.authenticate()
                    }
                }
            }
        }
        .padding()
        .sheet(isPresented: debugShowSheetBinding) {
            if let authUrl = viewModel.oauthService.authUrl {
                SafariView(url: authUrl)
                    .edgesIgnoringSafeArea(.all)
                    .onDisappear {
                        DispatchQueue.main.async {
                            viewModel.oauthService.showSheet = false
                        }
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
