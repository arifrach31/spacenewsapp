//
//  UserCredentials.swift
//  SpaceNews
//
//  Created by ArifRachman on 12/04/25.
//

import Foundation
import Auth0

struct UserCredentials: Codable {
  let accessToken: String
  let tokenType: String
  let idToken: String
  let refreshToken: String?
  let expiresIn: Date
  let scope: String?
  let recoveryCode: String?
  
  init(from credentials: Auth0.Credentials) {
    self.accessToken = credentials.accessToken
    self.tokenType = credentials.tokenType
    self.idToken = credentials.idToken
    self.refreshToken = credentials.refreshToken
    self.expiresIn = credentials.expiresIn
    self.scope = credentials.scope
    self.recoveryCode = credentials.recoveryCode
  }
}
