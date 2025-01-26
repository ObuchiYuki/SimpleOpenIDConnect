//
//  OIDCError.swift
//  CaloriAI_NewAuth
//
//  Created by yuki on 2024/12/25.
//

import Foundation

public enum OIDCError: Error {
    case invalidURL
    case missingAuthorizationCode
    case networkError(URLResponse)
    case decodeError
}
