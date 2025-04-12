//
//  Profile.swift
//  SpaceNews
//
//  Created by ArifRachman on 11/04/25.
//

import Foundation
import Auth0

struct Profile: Codable {
  let id: String
  let name: String?
  let nickname: String?
  let email: String?
  let picture: URL?
  
  init(from userInfo: UserInfo) {
    self.id = userInfo.sub
    self.name = userInfo.name
    self.nickname = userInfo.nickname
    self.email = userInfo.email
    self.picture = userInfo.picture
  }
}
