//
//  OIDCTokenResponse.swift
//  CaloriAI_NewAuth
//
//  Created by yuki on 2024/12/25.
//

import Foundation

public struct OIDCTokenResponse: Decodable, Sendable {
    public let accessToken: String
    public let refreshToken: String?
    public let idToken: String?
    public let refreshTokenExpireTime: Int?
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case idToken = "id_token"
        case refreshTokenExpiresIn = "refresh_token_expires_in"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        guard let accessToken = try container.decodeIfPresent(String.self, forKey: .accessToken) else {
            throw DecodingError.dataCorruptedError(forKey: .accessToken, in: container, debugDescription: "Access token is missing")
        }
        guard !accessToken.isEmpty else {
            throw DecodingError.dataCorruptedError(forKey: .accessToken, in: container, debugDescription: "Access token is empty")
        }
        self.accessToken = accessToken
        
        self.refreshToken = try container.decodeIfPresent(String.self, forKey: .refreshToken)
        self.idToken      = try container.decodeIfPresent(String.self, forKey: .idToken)
        
        if let secondsFromNow = try container.decodeIfPresent(Int.self, forKey: .refreshTokenExpiresIn) {
            let nowSeconds = Int(Date().timeIntervalSince1970)
            self.refreshTokenExpireTime = nowSeconds + secondsFromNow
        } else {
            self.refreshTokenExpireTime = nil
        }
    }
    
    public init(accessToken: String, refreshToken: String?, idToken: String?, refreshTokenExpireTime: Int?) {
        self.accessToken  = accessToken
        self.refreshToken = refreshToken
        self.idToken      = idToken
        self.refreshTokenExpireTime = refreshTokenExpireTime
    }
}
