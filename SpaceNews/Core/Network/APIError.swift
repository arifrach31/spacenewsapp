//
//  APIError.swift
//  SpaceNews
//
//  Created by ArifRachman on 12/04/25.
//

import Foundation

public enum NetworkError: Error, Equatable {
  case noInternetConnection
  case requestTimeout
  case invalidRequest
  case unknownError
  
  public var description: String {
    switch self {
    case .noInternetConnection:
      return "No internet connection."
    case .requestTimeout:
      return "The request timed out."
    case .invalidRequest:
      return "The request was invalid."
    case .unknownError:
      return "An unknown network error occurred."
    }
  }
}

public enum APIError: Error {
  case decodingFailed
  case middlewareError(code: Int, message: String?)
  case httpError(statusCode: Int)
  case clientError(statusCode: Int)
  case serverError(statusCode: Int)
  case failedMapping
  case customError(info: [String: Any])
  case invalidRequest
  case noInternet
  case unauthorized
  case tokenExpired
  case forceLogout
  
  public var description: String {
    switch self {
    case .decodingFailed:
      return "Failed to decode response from server."
    case .middlewareError(let code, let message):
      return "Server error (\(code)): \(message ?? "No message available")."
    case .httpError(let statusCode):
      return "HTTP error with status code: \(statusCode)."
    case .clientError(let statusCode):
      return "Client error with status code: \(statusCode)."
    case .serverError(let statusCode):
      return "Server error with status code: \(statusCode)."
    case .failedMapping:
      return "Failed to map the data."
    case .customError(let info):
      return "Custom error: \(info.debugDescription)."
    case .invalidRequest:
      return "The request was invalid."
    case .noInternet:
      return "No internet connection. Check your network and please try again."
    case .unauthorized:
      return "Unauthorized access. Please check your credentials."
    case .tokenExpired:
      return "Access token has expired. Refreshing token..."
    case .forceLogout:
      return "Your session has expired. Please log in again."
    }
  }
}
