//
//  PKCEPair.swift
//  CaloriAI_NewAuth
//
//  Created by yuki on 2024/12/25.
//

import Foundation
import CryptoKit
 
public struct PKCE: Sendable {
    public typealias Verifier = String
    
    public typealias Challenge = String
    
    public let codeVerifier: Verifier
    
    public let codeChallenge: Challenge
    
    public init() {
        self.codeVerifier = PKCE.generateCodeVerifier()
        self.codeChallenge = PKCE.generateCodeChallenge(fromVerifier: self.codeVerifier)
    }
    
    public init(codeVerifier: Verifier) {
        self.codeVerifier = codeVerifier
        self.codeChallenge = PKCE.generateCodeChallenge(fromVerifier: codeVerifier)
    }
    
    private static func generateCodeChallenge(fromVerifier verifier: Verifier) -> Challenge {
        let verifierData = verifier.data(using: .ascii)!
        
        let challengeHashed = SHA256.hash(data: verifierData)
        let challengeBase64Encoded = Data(challengeHashed).base64URLEncodedString
        
        return challengeBase64Encoded
    }
    
    private static func generateCodeVerifier() -> Verifier {
        if let codeVerifier = PKCE.generateCryptographicallySecureCodeVerifier() {
            return codeVerifier
        } else {
            return self.generateFallbackCodeVerifier()
        }
    }
    
    private static func generateCryptographicallySecureCodeVerifier() -> String? {
        let count = 32
        var octets = [UInt8](repeating: 0, count: count)
        let status = SecRandomCopyBytes(kSecRandomDefault, count, &octets)
        
        guard status == errSecSuccess else { return nil }
            
        return Data(bytes: octets, count: count).base64URLEncodedString
    }
    
    private static func generateFallbackCodeVerifier() -> Verifier {
        let count = 43
        let base64 = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<count).map{ _ in base64.randomElement()! })
    }
}

extension Data {
    fileprivate var base64URLEncodedString: String {
        base64EncodedString()
            .replacingOccurrences(of: "=", with: "") // Remove any trailing '='s
            .replacingOccurrences(of: "+", with: "-") // 62nd char of encoding
            .replacingOccurrences(of: "/", with: "_") // 63rd char of encoding
            .trimmingCharacters(in: .whitespaces)
    }
}
