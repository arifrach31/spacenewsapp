//
//  SpaceNewsApp.swift
//  SpaceNews
//
//  Created by ArifRachman on 11/04/25.
//

import SwiftUI
import netfox

@main
struct SpaceNewsApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  
  @StateObject var router = NavigationRouter()
  @StateObject var sessionVM = SessionViewModel()
  
  init() {
    UNUserNotificationCenter.current().delegate = appDelegate
#if DEBUG
    NFX.sharedInstance().start()
#endif
  }
  
  var body: some Scene {
    WindowGroup {
      RootView()
        .environmentObject(router)
        .environmentObject(sessionVM)
    }
  }
}
