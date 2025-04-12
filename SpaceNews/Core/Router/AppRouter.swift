//
//  AppRouter.swift
//  SpaceNews
//
//  Created by ArifRachman on 11/04/25.
//

import Foundation

enum AppRouter: Hashable {
  case login
  case home
  case articleList(category: SectionCategory)
}
