//
//  FlickrAuthService.swift
//  PhotoExplorer
//
//  Created by Marcel Mravec on 03.10.2023.
//

import Combine
import CommonCrypto
import OAuthSwift
import Security
import SwiftUI

let FLICKR_CONSUMER_KEY = FlickrAPI.apiKey
let FLICKR_CONSUMER_SECRET = FlickrAPI.secret
let FLICKR_URL_SCHEME = "flickrsdk"



class FlickrOAuthService: NSObject, ObservableObject {
    
    let objectWillChange = PassthroughSubject<FlickrOAuthService,Never>()
    
    @Published var authenticationState: AuthenticationState = .noAuthenticationAttempted {
        willSet { self.objectWillChange.send(self) }
    }
    
    @Published var authUrl: URL? {
        willSet { self.objectWillChange.send(self) }
    }
    
    @Published var showSheet: Bool = false {
        willSet { self.objectWillChange.send(self) }
    }
    
    @Published var oauthClient: OAuthSwiftClient?
    
    var callbackObserver: Any? {
        willSet {
            // we will add and remove this observer on an as-needed basis
            guard let token = callbackObserver else { return }
            NotificationCenter.default.removeObserver(token)
        }
    }
    
    func signatureKey(_ consumerSecret: String,_ oauthTokenSecret: String?) -> String {
        
        guard let oauthSecret = oauthTokenSecret?.urlEncoded
        else { return consumerSecret.urlEncoded+"&" }
        
        return consumerSecret.urlEncoded+"&"+oauthSecret
        
    }
    
    func signatureParameterString(params: [String: Any]) -> String {
        var result: [String] = []
        for param in params {
            let key = param.key.urlEncoded
            let val = "\(param.value)".urlEncoded
            result.append("\(key)=\(val)")
        }
        return result.sorted().joined(separator: "&")
    }
    
    func signatureBaseString(_ httpMethod: String = "POST",_ url: String,
                             _ params: [String:Any]) -> String {
        
        let parameterString = signatureParameterString(params: params)
        return httpMethod + "&" + url.urlEncoded + "&" + parameterString.urlEncoded
        
    }
    
    func hmac_sha1(signingKey: String, signatureBase: String) -> String {
        // HMAC-SHA1 hashing algorithm returned as a base64 encoded string
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA1), signingKey, signingKey.count, signatureBase, signatureBase.count, &digest)
        let data = Data(digest)
        return data.base64EncodedString()
    }
    
    func oauthSignature(httpMethod: String = "POST", url: String,
                        params: [String: Any], consumerSecret: String,
                        oauthTokenSecret: String? = nil) -> String {
        
        let signingKey = signatureKey(consumerSecret, oauthTokenSecret)
        print("signingKey: \(signingKey)")
        
        let signatureBase = signatureBaseString(httpMethod, url, params)
        print("signatureBase: \(signatureBase)")
        
        let signature = hmac_sha1(signingKey: signingKey, signatureBase: signatureBase)
        print("signature: \(signature)")
        
        return signature
        
    }
    
    struct RequestOAuthTokenInput {
        let consumerKey: String
        let consumerSecret: String
        let callbackScheme: String
    }
    
    struct RequestOAuthTokenResponse {
        let oauthToken: String
        let oauthTokenSecret: String
        let oauthCallbackConfirmed: String
    }
    
    func requestOAuthToken(args: RequestOAuthTokenInput,_ complete: @escaping (RequestOAuthTokenResponse) -> Void) {
        let request = (url: FlickrAPI.requestTokenURL, httpMethod: "POST")
        let callback = args.callbackScheme + "://success"
        
        var params: [String: Any] = [
            "oauth_callback" : callback,
            "oauth_consumer_key" : args.consumerKey,
            "oauth_nonce" : UUID().uuidString, // nonce can be any 32-bit string made up of random ASCII values
            "oauth_signature_method" : "HMAC-SHA1",
            "oauth_timestamp" : String(Int(NSDate().timeIntervalSince1970)),
            "oauth_version" : "1.0"
        ]
        // Build the OAuth Signature from Parameters
        params["oauth_signature"] = oauthSignature(httpMethod: request.httpMethod, url: request.url, params: params, consumerSecret: args.consumerSecret)
        
        // Once OAuth Signature is included in our parameters, build the authorization header
        let authHeader = authorizationHeader(params: params)
        
        guard let url = URL(string: request.url) else { return }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.httpMethod
        urlRequest.setValue(authHeader, forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            guard let data = data else { return }
            guard let dataString = String(data: data, encoding: .utf8) else { return }
            // dataString should return: oauth_token=XXXX&oauth_token_secret=YYYY&oauth_callback_confirmed=true
            let attributes = dataString.urlQueryStringParameters
            let result = RequestOAuthTokenResponse(oauthToken: attributes["oauth_token"] ?? "",
                                                   oauthTokenSecret: attributes["oauth_token_secret"] ?? "",
                                                   oauthCallbackConfirmed: attributes["oauth_callback_confirmed"] ?? "")
            complete(result)
        }
        print("•••\nRequest OAuth Token completed\n•••")
        task.resume()
    }
    
    struct RequestAccessTokenInput {
        let consumerKey: String
        let consumerSecret: String
        let requestToken: String // = RequestOAuthTokenResponse.oauthToken
        let requestTokenSecret: String // = RequestOAuthTokenResponse.oauthTokenSecret
        let oauthVerifier: String
    }
    struct RequestAccessTokenResponse: Codable {
        let accessToken: String
        let accessTokenSecret: String
        let userId: String
        let screenName: String

        enum CodingKeys: String, CodingKey {
            case accessToken
            case accessTokenSecret
            case userId = "user_nsid"
            case screenName = "username"
        }
    }

    func requestAccessToken(args: RequestAccessTokenInput,
                            _ complete: @escaping (RequestAccessTokenResponse) -> Void) {
        let request = (url: FlickrAPI.accessTokenURL, httpMethod: "POST")
        
        var params: [String: Any] = [
            "oauth_token" : args.requestToken,
            "oauth_verifier" : args.oauthVerifier,
            "oauth_consumer_key" : args.consumerKey,
            "oauth_nonce" : UUID().uuidString, // nonce can be any 32-bit string made up of random ASCII values
            "oauth_signature_method" : "HMAC-SHA1",
            "oauth_timestamp" : String(Int(NSDate().timeIntervalSince1970)),
            "oauth_version" : "1.0"
        ]
        
        // Build the OAuth Signature from Parameters
        params["oauth_signature"] = oauthSignature(httpMethod: request.httpMethod,
                                                   url: request.url,
                                                   params: params, consumerSecret: args.consumerSecret,
                                                   oauthTokenSecret: args.requestTokenSecret)
        
        // Once OAuth Signature is included in our parameters, build the authorization header
        let authHeader = authorizationHeader(params: params)
        
        guard let url = URL(string: request.url) else { return }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.httpMethod
        urlRequest.setValue(authHeader, forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            guard let data = data else { return }
            guard let dataString = String(data: data, encoding: .utf8) else { return }
            let attributes = dataString.urlQueryStringParameters
            let result = RequestAccessTokenResponse(accessToken: attributes["oauth_token"] ?? "",
                                                    accessTokenSecret: attributes["oauth_token_secret"] ?? "",
                                                    userId: attributes["user_nsid"] ?? "",
                                                    screenName: attributes["username"] ?? "")
            complete(result)
        }
        print("•••\nRequest Access Token completed\n•••")
        task.resume()
    }
    
    @Published var credential: RequestAccessTokenResponse? {
        willSet { self.objectWillChange.send(self) }
    }
    
    
    func authorize() {
        let keychain = KeychainPreferences.shared

        // Check if authorization is already set up in the keychain
        if let credentials = keychain.loadCredentialsFromKeychain() {
            // Use credentials and set authentication state
            self.credential = credentials
            self.oauthClient = self.createOAuthClient(args: FlickrOAuthClientInput(consumerKey: FLICKR_CONSUMER_KEY,
                                                                         consumerSecret: FLICKR_CONSUMER_SECRET,
                                                                         accessToken: credentials.accessToken,
                                                                         accessTokenSecret: credentials.accessTokenSecret))
            self.authenticationState = .successfullyAuthenticated
            return
        }

        // Continue with authorization if no saved credentials were found
        
        self.showSheet = true // opens the sheet containing our safari view
        
        // Start Step 1: Requesting an access token
        let oAuthTokenInput = RequestOAuthTokenInput(consumerKey: FLICKR_CONSUMER_KEY,
                                                     consumerSecret: FLICKR_CONSUMER_SECRET,
                                                     callbackScheme: FLICKR_URL_SCHEME)
        
        requestOAuthToken(args: oAuthTokenInput) { oAuthTokenResponse in
            // Kick off our Step 2 observer: start listening for user login callback in scene delegate (from handleOpenUrl)
            self.callbackObserver = NotificationCenter.default.addObserver(forName: .flickrCallback, object: nil, queue: .main) { notification in
                self.callbackObserver = nil // remove notification observer
                self.showSheet = false      // hide sheet containing safari view
                self.authUrl = nil          // remove safari view
                guard let url = notification.object as? URL else { return }
                guard let parameters = url.query?.urlQueryStringParameters else { return }
                guard let verifier = parameters["oauth_verifier"] else { return }
                
                // Start Step 3: Request Access Token
                let accessTokenInput = RequestAccessTokenInput(consumerKey: FLICKR_CONSUMER_KEY,
                                                               consumerSecret: FLICKR_CONSUMER_SECRET,
                                                               requestToken: oAuthTokenResponse.oauthToken,
                                                               requestTokenSecret: oAuthTokenResponse.oauthTokenSecret,
                                                               oauthVerifier: verifier)
                
                self.requestAccessToken(args: accessTokenInput) { accessTokenResponse in
                    // Process Completed Successfully!
                    DispatchQueue.main.async {
                        self.credential = accessTokenResponse
                        self.authUrl = nil
                        
                        // Save credentials to keychain
                        keychain.saveCredentialsToKeychain(accessTokenResponse)
                        
                        // Set your OAuth client accordingly
                        self.oauthClient = self.createOAuthClient(args: FlickrOAuthClientInput(consumerKey: FLICKR_CONSUMER_KEY,
                                                                                               consumerSecret: FLICKR_CONSUMER_SECRET,
                                                                                               accessToken: self.credential!.accessToken,
                                                                                               accessTokenSecret: self.credential!.accessTokenSecret))
                    }
                    
                    self.authenticationState = .successfullyAuthenticated
                }
            }
            
            // Start Step 2: User Flickr Login
            let urlString = "\(FlickrAPI.authorizeURL)?oauth_token=\(oAuthTokenResponse.oauthToken)&perms=write"
            guard let oauthUrl = URL(string: urlString) else { return }
            DispatchQueue.main.async {
                self.authUrl = oauthUrl // sets our safari view url
            }
        }
    }

    
    func logout() {
        let keychain = KeychainPreferences.shared
        keychain.removeCredentialsFromKeychain()
        self.authenticationState = .noAuthenticationAttempted
    }
    
    func handleOAuthCallback(url: URL, completion: @escaping (Result<RequestAccessTokenResponse, Error>) -> Void) { 
            // Handle OAuth callback and retrieve access token
            // Call the completion handler with the access token or an error
        let accessTokenResponse = RequestAccessTokenResponse(accessToken: "your_access_token", accessTokenSecret: "your_access_token_secret", userId: "user_id", screenName: "username")
        completion(.success(accessTokenResponse))
        }
    
        
        func getUserPhotos(completion: @escaping (Result<Data, Error>) -> Void) {
            // Make authenticated API request to get user photos
            // Call the completion handler with the API response data or an error
        }
    
    class KeychainPreferences {
        static let shared = KeychainPreferences()

        private let service: String = "com.yourapp.flickrAuth"

        func saveCredentialsToKeychain(_ credentials: RequestAccessTokenResponse) {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: "flickrCredentials",
                kSecValueData as String: try! JSONEncoder().encode(credentials)
            ]

            SecItemDelete(query as CFDictionary)
            let status = SecItemAdd(query as CFDictionary, nil)
            guard status == errSecSuccess else { return }
        }

        func loadCredentialsFromKeychain() -> RequestAccessTokenResponse? {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: "flickrCredentials",
                kSecReturnData as String: kCFBooleanTrue as Any,
                kSecMatchLimit as String: kSecMatchLimitOne
            ]

            var result: AnyObject?
            let status = SecItemCopyMatching(query as CFDictionary, &result)

            if status == errSecSuccess, let data = result as? Data {
                return try? JSONDecoder().decode(RequestAccessTokenResponse.self, from: data)
            } else {
                return nil
            }
        }

        func removeCredentialsFromKeychain() {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: "flickrCredentials"
            ]

            SecItemDelete(query as CFDictionary)
        }
    }

}



extension Notification.Name {
    static let flickrCallback = Notification.Name(rawValue: "Flickr.CallbackNotification.Name")
}

extension String {
    var urlEncoded: String {
        var charset: CharacterSet = .urlQueryAllowed
        charset.remove(charactersIn: "\n:#/?@!$&'()*+,;=")
        return self.addingPercentEncoding(withAllowedCharacters: charset)!
    }
}

extension String {
    var urlQueryStringParameters: Dictionary<String, String> {
        // breaks apart query string into a dictionary of values
        var params = [String: String]()
        let items = self.split(separator: "&")
        for item in items {
            let combo = item.split(separator: "=")
            if combo.count == 2 {
                let key = "\(combo[0])"
                let val = "\(combo[1])"
                params[key] = val
            }
        }
        return params
    }
}

func authorizationHeader(params: [String: Any]) -> String {
    var parts: [String] = []
    for param in params {
        let key = param.key.urlEncoded
        let val = "\(param.value)".urlEncoded
        parts.append("\(key)=\"\(val)\"")
    }
    
    let header = "OAuth " + parts.sorted().joined(separator: ", ")
    print("authorizationHeader: \(header)")
    
    return header
}


extension FlickrOAuthService {
    
    struct FlickrOAuthClientInput {
        let consumerKey: String
        let consumerSecret: String
        let accessToken: String
        let accessTokenSecret: String
    }
    
    func createOAuthClient(args: FlickrOAuthClientInput) -> OAuthSwiftClient {
        
        let client = OAuthSwiftClient(consumerKey: args.consumerKey,
                                      consumerSecret: args.consumerSecret,
                                      oauthToken: args.accessToken,
                                      oauthTokenSecret: args.accessTokenSecret,
                                      version: .oauth1)
        
        return client
    }
    
    
    
}


