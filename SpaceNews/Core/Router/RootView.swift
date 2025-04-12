//
//  RootView.swift
//  SpaceNews
//
//  Created by ArifRachman on 11/04/25.
//

import Foundation
import SwiftUI

struct RootView: View {
  @EnvironmentObject var router: NavigationRouter
  @EnvironmentObject var sessionVM: SessionViewModel
  
  var body: some View {
    NavigationStack(path: $router.path) {
      initialView
        .navigationDestination(for: AppRouter.self) { page in
          router.build(page: page)
        }
    }
  }
  
  @ViewBuilder
  private var initialView: some View {
    if sessionVM.isLoggedIn {
      router.build(page: .home)
    } else {
      router.build(page: .login)
    }
  }
}
