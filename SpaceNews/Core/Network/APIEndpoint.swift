//
//  APIEndpoint.swift
//  SpaceNews
//
//  Created by ArifRachman on 12/04/25.
//

import Foundation

public enum HTTPMethod: String {
  case GET
  case POST
  case PUT
  case DELETE
}

public protocol API {
  var serviceType: ServiceType { get }
  var path: String { get }
  var method: HTTPMethod { get }
  var parameters: Encodable? { get }
  var headers: [String: String] { get }
  
  func urlRequest() throws -> URLRequest
}

public enum APIEndpoint: API {
  case articles(limit: Int?, offset: Int?)
  case blogs(limit: Int?, offset: Int?)
  case reports(limit: Int?, offset: Int?)
  case article(id: Int)
  
  public var serviceType: ServiceType {
    switch self {
    default:
      return .spaceflightnewsapi
    }
  }
  
  public var path: String {
    switch self {
    case .articles:
      return "/articles"
    case .blogs:
      return "/blogs"
    case .reports:
      return "/reports"
    case .article(let id):
      return "/articles/\(id)"
    }
  }
  
  public var method: HTTPMethod {
    switch self {
    case .articles,
        .blogs,
        .reports,
        .article:
      return .GET
    }
  }
  
  public var parameters: Encodable? {
    switch self {
    case .articles(let limit, let offset),
        .blogs(let limit, let offset),
        .reports(let limit, let offset):
      return [
        "limit": limit,
        "offset": offset
      ]
    default:
      return nil
    }
  }
  
  public var headers: [String: String] {
    let defaultHeaders = ["Content-Type": "application/json"]
    return defaultHeaders
  }
  
  public func urlRequest() throws -> URLRequest {
    guard let url = URL(string: serviceType.baseURL + path) else {
      throw APIError.httpError(statusCode: 400)
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = method.rawValue
    request.allHTTPHeaderFields = headers
    
    if let parameters = parameters {
      switch method {
      case .GET:
        var components = URLComponents(string: url.absoluteString)
        let queryItems = parameters.toDictionary().map { URLQueryItem(name: $0.key, value: "\($0.value)") }
        components?.queryItems = queryItems
        request.url = components?.url
        
      case .POST, .PUT, .DELETE:
        do {
          request.httpBody = try JSONEncoder().encode(parameters)
        } catch {
          throw APIError.decodingFailed
        }
      }
    }
    
    return request
  }
}

extension Encodable {
  func toDictionary() -> [String: Any] {
    guard let data = try? JSONEncoder().encode(self) else { return [:] }
    return (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any] ?? [:]
  }
}

class SSLPinningDelegate: NSObject, URLSessionDelegate {
  private let serverTrust: SecTrust
  
  init(serverTrust: SecTrust) {
    self.serverTrust = serverTrust
    super.init()
  }
  
  func urlSession(_ session: URLSession,
                  didReceive challenge: URLAuthenticationChallenge,
                  completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
    
    guard let serverTrust = challenge.protectionSpace.serverTrust else {
      completionHandler(.cancelAuthenticationChallenge, nil)
      return
    }
    
    let isServerTrusted = SecTrustEvaluateWithError(serverTrust, nil)
    
    if isServerTrusted {
      let credential = URLCredential(trust: serverTrust)
      completionHandler(.useCredential, credential)
    } else {
      completionHandler(.cancelAuthenticationChallenge, nil)
    }
  }
}
