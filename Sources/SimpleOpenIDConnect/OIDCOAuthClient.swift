//
//  OIDCOAuthClient.swift
//  CaloriAI_NewAuth
//
//  Created by yuki on 2024/12/25.
//

import Foundation

final public class OIDCOAuthClient {
    private let pkce: PKCE
        
    public init(pkce: PKCE) {
        self.pkce = pkce
    }
    
    public func getAllTokens(tokenEndpoint: URL, clientID: String, redirectURI: URL, scopes: String, authCode: String) async throws -> OIDCTokenResponse {
        let bodyDict = [
            "grant_type":    "authorization_code",
            "code":          authCode,
            "client_id":     clientID,
            "redirect_uri":  redirectURI.absoluteString,
            "scope":         scopes,
            "code_verifier": self.pkce.codeVerifier
        ]
        
        var request = URLRequest(url: tokenEndpoint)
        request.httpMethod = "POST"
        request.httpBody = bodyDict.urlEncoded().data(using: .utf8)
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw OIDCError.networkError(response, data)
        }
        
        guard let tokenResponse = try? JSONDecoder().decode(OIDCTokenResponse.self, from: data) else {
            throw OIDCError.decodeError(data)
        }
                
        return tokenResponse
    }
    
    public static func refreshTokens(
        tokenEndpoint: URL,
        clientID: String,
        scopes: String,
        refreshToken: String
    ) async throws -> OIDCTokenResponse {
        let bodyDict = [
            "grant_type":    "refresh_token",
            "client_id":     clientID,
            "scope":         scopes,
            "refresh_token": refreshToken
        ]
        
        var request = URLRequest(url: tokenEndpoint)
        request.httpMethod = "POST"
        request.httpBody = bodyDict.urlEncoded().data(using: .utf8)
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw OIDCError.networkError(response, data)
        }
        
        guard let tokenResponse = try? JSONDecoder().decode(OIDCTokenResponse.self, from: data) else {
            throw OIDCError.decodeError(data)
        }
        return tokenResponse
    }
}

extension [String: String] {
    fileprivate func urlEncoded() -> String {
        self.map { "\($0.key.urlEncoded())=\($0.value.urlEncoded())" }
            .joined(separator: "&")
    }
}

extension String {
    fileprivate func urlEncoded() -> String {
        self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? self
    }
}
