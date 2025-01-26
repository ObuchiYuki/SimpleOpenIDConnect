//
//  OIDCError.swift
//  CaloriAI_NewAuth
//
//  Created by yuki on 2024/12/25.
//

import Foundation

public enum OIDCError: Error, LocalizedError, Sendable {
    case missingAuthorizationCode
    case networkError(URLResponse, Data)
    case decodeError(Data)
    
    public var errorDescription: String? {
        switch self {
        case .missingAuthorizationCode:
            return "Missing authorization code in callback URL"
        case .networkError(_, let data):
            if let errorDescription = String(data: data, encoding: .utf8) {
                return "Network error: \(errorDescription)"
            } else {
                return "Network error"
            }
        case .decodeError:
            return "Decode error"
        }
    }
}
