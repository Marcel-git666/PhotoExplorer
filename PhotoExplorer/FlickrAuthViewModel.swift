//
//  FlickrAuthViewModel.swift
//  PhotoExplorer
//
//  Created by Marcel Mravec on 03.10.2023.
//

import SwiftUI

class FlickrAuthViewModel: ObservableObject {
    @Published var oauthService = FlickrOAuthService()
    @Published var isAuthenticated: Bool = false

    init() {
        // Initialize your OAuth service and check if the user is already authenticated
        checkAuthentication()
    }

    func checkAuthentication() {
        // Check if the user is already authenticated
        if oauthService.authenticationState == .successfullyAuthenticated {
            isAuthenticated = true
        } else {
            isAuthenticated = false
        }
    }

    func authenticate() {
        // Start the authentication process
        oauthService.authorize()
    }

    func logout() {
        // Log out the user
        oauthService.logout()
        isAuthenticated = false
    }
}
