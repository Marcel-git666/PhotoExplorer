//
//  FlickrAuthViewModel.swift
//  PhotoExplorer
//
//  Created by Marcel Mravec on 03.10.2023.
//

import Foundation
import Combine

class FlickrAuthViewModel: ObservableObject {
    @Published var authenticationState: AuthenticationState = .noAuthenticationAttempted
    @Published var isAuthenticationCompleted = false
    private var flickrOAuthService: FlickrOAuthService
    
    var authUrl: URL? {
        return flickrOAuthService.authUrl
    }
    
    init(flickrOAuthService: FlickrOAuthService) {
        self.flickrOAuthService = flickrOAuthService
        self.flickrOAuthService.oauthClient = flickrOAuthService.createOAuthClient(args: FlickrOAuthService.FlickrOAuthClientInput(consumerKey: FLICKR_CONSUMER_KEY, consumerSecret: FLICKR_CONSUMER_SECRET, accessToken: self.flickrOAuthService.credential?.accessToken ?? "", accessTokenSecret: self.flickrOAuthService.credential?.accessTokenSecret ?? ""))
        // Subscribe to authenticationState changes from FlickrOAuthService
        self.flickrOAuthService.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &cancellables)
    }
    
    // Add functions to handle authorization and logout if needed
    // For example:
    func authorize() {
        flickrOAuthService.authorize()
    }
    
    func handleOAuthCallback(url: URL) {
        // Parse the OAuth callback URL and handle the response
        
        // If authentication is successful, set isAuthenticated to true
        authenticationState = .successfullyAuthenticated
        isAuthenticationCompleted = true
    }
    
    func getUserPhotos(completion: @escaping (Result<Data, Error>) -> Void) {
        flickrOAuthService.getUserPhotos(completion: completion)
    }
    
    
    func logout() {
        flickrOAuthService.logout()
    }
    
    private var cancellables = Set<AnyCancellable>()
}
