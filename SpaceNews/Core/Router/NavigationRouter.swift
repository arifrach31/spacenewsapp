//
//  NavigationRouter.swift
//  SpaceNews
//
//  Created by ArifRachman on 11/04/25.
//

import SwiftUI

class NavigationRouter: ObservableObject {
  @Published var path = NavigationPath()
  
  func push(to route: AppRouter) {
    path.append(route)
  }
  
  func pop() {
    path.removeLast()
  }
  
  func popToRoot() {
    path = NavigationPath()
  }
  
  func resetToRoot() {
    path.removeLast(path.count)
  }
  
  @ViewBuilder
  func build(page: AppRouter) -> some View {
    switch page {
    case .login:
      LoginView()
    case .home:
      HomeView()
    case .articleList(let category):
      ArticleListView(category: category)
    }
  }
}
