//
//  OIDCAuthenticator.swift
//  CaloriAI_NewAuth
//
//  Created by yuki on 2024/12/25.
//

import Foundation

final public class OIDCAuthenticator: Sendable {
    public let pkce: PKCE
    
    public let authorizationBaseURL: URL
    public let authorizeEndpointPath: String
    public let tokenEndpointPath: String
    
    public let clientID: String
    public let redirectURI: URL
    public let scopes: [String]
    
    public init(
        authorizationBaseURL: URL,
        authorizeEndpointPath: String,
        tokenEndpointPath: String,
        clientID: String,
        redirectURI: URL,
        scopes: [String],
        pkce: PKCE = PKCE()
    ) {
        precondition(authorizationBaseURL.scheme == "https" || authorizationBaseURL.scheme == "http", "Authorization base URL must be HTTPS or HTTP")
        
        self.authorizationBaseURL = authorizationBaseURL
        self.authorizeEndpointPath = authorizeEndpointPath
        self.tokenEndpointPath = tokenEndpointPath
        self.clientID = clientID
        self.redirectURI = redirectURI
        self.scopes = scopes
        self.pkce = pkce
    }
        
    public func buildAuthorizationURL(
        extraQueryParams: [String: String] = [:]
    ) -> URL? {
        guard var components = URLComponents(url: self.authorizationBaseURL, resolvingAgainstBaseURL: false) else {
            return nil
        }
        components.path.append(contentsOf: self.authorizeEndpointPath)
        
        let queryParameters = [
            "client_id": self.clientID,
            "redirect_uri": self.redirectURI.absoluteString,
            "scope": self.scopes.joined(separator: " "),
            "response_type": "code",
            "code_challenge": self.pkce.codeChallenge,
            "code_challenge_method": "S256",
            "nonce": "defaultNonce"
        ]
        
        var queryItems = [URLQueryItem]()
        
        for (key, value) in queryParameters.merging(extraQueryParams, uniquingKeysWith: { old, new in old }) {
            queryItems.append(URLQueryItem(name: key, value: value))
        }
        
        components.queryItems = queryItems
        
        guard let url = components.url else { return nil }
        
        return url
    }
    
    public func acquireTokens(from url: URL) async throws -> (accessToken: String, refreshToken: String?, idToken: String?) {
        guard let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems,
              let codeItem = queryItems.first(where: { $0.name == "code" }),
              let authCode = codeItem.value
        else {
            throw OIDCError.missingAuthorizationCode
        }
        
        let tokenEndpoint = self.authorizationBaseURL.appendingPathComponent(self.tokenEndpointPath)
        
        let oauthClient = OIDCOAuthClient(pkce: self.pkce)
        let scopeString = self.scopes.joined(separator: " ")
        
        let tokenResponse = try await oauthClient.getAllTokens(
            tokenEndpoint: tokenEndpoint,
            clientID: self.clientID,
            redirectURI: self.redirectURI,
            scopes: scopeString,
            authCode: authCode
        )
        
        return (
            accessToken: tokenResponse.accessToken,
            refreshToken: tokenResponse.refreshToken,
            idToken: tokenResponse.idToken
        )
    }
    
    public func refreshTokens(refreshToken: String) async throws -> (accessToken: String, refreshToken: String?, idToken: String?) {
        let tokenEndpoint = self.authorizationBaseURL.appendingPathComponent(self.tokenEndpointPath)
        
        let scopeString = self.scopes.joined(separator: " ")
        let tokenResponse = try await OIDCOAuthClient.refreshTokens(
            tokenEndpoint: tokenEndpoint,
            clientID: self.clientID,
            scopes: scopeString,
            refreshToken: refreshToken
        )
        
        return (
            accessToken: tokenResponse.accessToken,
            refreshToken: tokenResponse.refreshToken,
            idToken: tokenResponse.idToken
        )
    }
}
