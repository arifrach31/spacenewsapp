//
//  NetworkManager.swift
//  SpaceNews
//
//  Created by ArifRachman on 12/04/25.
//

import Foundation
import Combine

public enum HTTPStatusCode: Int {
  case ok = 200
  case created = 201
  case accepted = 202
  case badRequest = 400
  case unauthorized = 401
  case forbidden = 403
  case notFound = 404
  case internalServerError = 500
  case badGateway = 502
  case serviceUnavailable = 503
  case gatewayTimeout = 504
  
  public static func from(rawValue: Int) -> HTTPStatusCode? {
    return HTTPStatusCode(rawValue: rawValue)
  }
}

public enum ServiceType {
  case spaceflightnewsapi
  
  var baseURL: String {
    switch self {
    case .spaceflightnewsapi:
      return "https://api.spaceflightnewsapi.net/v4"
    }
  }
}

public class NetworkManager {
  public static let shared = NetworkManager()
  
  private let session: URLSession
  private var cancellables = Set<AnyCancellable>()
  
  private var isRefreshingToken = false
  private var refreshTokenPublisher: PassthroughSubject<Bool, Never> = .init()
  private var refreshTokenRetryCount = 0
  private let maxRefreshTokenRetry = 1
  
  public init(session: URLSession = .shared) {
    self.session = session
  }
  
  public func request<T: Decodable>(
    endpoint: APIEndpoint,
    responseType: T.Type,
    completion: @escaping (Result<T, APIError>) -> Void
  ) {
    
    do {
      let request = try endpoint.urlRequest()
      
      session.dataTaskPublisher(for: request)
        .tryMap { [weak self] result in
          try self?.handleResponse(result) ?? Data()
        }
        .decode(type: T.self, decoder: JSONDecoder())
        .mapError { [weak self] error -> APIError in
          return self?.handleError(error) ?? APIError.decodingFailed
        }
        .sink(receiveCompletion: { completionResult in
          if case .failure(let error) = completionResult {
            self.handleCompletionFailure(error: error, endpoint: endpoint, responseType: responseType, completion: completion)
          }
        }, receiveValue: { value in
          completion(.success(value))
        })
        .store(in: &cancellables)
    } catch {
      completion(.failure(.invalidRequest))
    }
  }
  
  private func handleResponse(_ result: URLSession.DataTaskPublisher.Output) throws -> Data {
    
    guard let httpResponse = result.response as? HTTPURLResponse else {
      throw APIError.httpError(statusCode: 500)
    }
    
    guard let statusCode = HTTPStatusCode.from(rawValue: httpResponse.statusCode) else {
      throw APIError.httpError(statusCode: httpResponse.statusCode)
    }
    
    if let jsonObject = try? JSONSerialization.jsonObject(with: result.data, options: []) as? [String: Any],
       let message = jsonObject["message"] as? String {
      let lowercasedMessage = message.lowercased()
      
      if statusCode == .unauthorized {
        if lowercasedMessage == "access token expired." {
          throw APIError.tokenExpired
        } else if ["invalid token.", "unauthorized.", "unauthenticated."].contains(lowercasedMessage) {
          throw APIError.forceLogout
        }
      }
    }
    
    switch statusCode {
    case .ok, .created, .accepted:
      return result.data
    case .badRequest, .forbidden, .notFound, .unauthorized:
      throw APIError.clientError(statusCode: httpResponse.statusCode)
    case .internalServerError, .badGateway, .serviceUnavailable, .gatewayTimeout:
      throw APIError.serverError(statusCode: httpResponse.statusCode)
    }
  }
  
  private func handleError(_ error: Error) -> APIError {
    if let urlError = error as? URLError, urlError.code == .notConnectedToInternet {
      return .noInternet
    }
    
    return error as? APIError ?? .decodingFailed
  }
  
  private func handleCompletionFailure<T: Decodable>(
    error: APIError,
    endpoint: APIEndpoint,
    responseType: T.Type,
    completion: @escaping (Result<T, APIError>) -> Void
  ) {
    switch error {
    default:
      completion(.failure(error))
    }
  }
}
