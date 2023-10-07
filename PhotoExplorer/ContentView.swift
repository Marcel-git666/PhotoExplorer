//
//  ContentView.swift
//  PhotoExplorer
//
//  Created by Marcel Mravec on 02.10.2023.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: FlickrAuthViewModel
    
    var body: some View {
        VStack {
            if viewModel.isAuthenticated {
                Text("User is authenticated!")
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
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(FlickrAuthViewModel()) // Initialize the viewModel
    }
}
#endif
