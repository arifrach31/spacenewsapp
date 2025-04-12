//
//  SessionViewModel.swift
//  SpaceNews
//
//  Created by ArifRachman on 11/04/25.
//

import Foundation
import UserNotifications
import Auth0

class SessionViewModel: ObservableObject {
  @Published var credentials: UserCredentials?
  @Published var userProfile: Profile?
  @Published var isLoggedIn: Bool = false
  
  private var timer: Timer?
  private let sessionTimeout: TimeInterval = 600
  
  init() {
    userProfile = Persistent.shared.getCodable(key: .userProfile, type: Profile.self)
    NotificationManager.shared.requestPermission()
    checkSessionValidity()
  }
  
  func login() {
    saveLoginTime()
    NotificationManager.shared.scheduleLocalNotification(
      after: self.sessionTimeout,
      title: "Session Expired",
      body: "Akun anda sudah terlogout"
    )
    startSessionTimer()
    isLoggedIn = true
  }
  
  func logout() {
    clearSessionData()
    isLoggedIn = false
  }
  
  func checkSessionValidity() {
    guard let loginTime = getLoginTime() else {
      isLoggedIn = false
      return
    }
    
    if isSessionExpired(since: loginTime) {
      logout()
    } else {
      isLoggedIn = true
      startSessionTimer()
    }
  }
  
  private func startSessionTimer() {
    timer?.invalidate()
    
    timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
      guard let self = self, let loginTime = self.getLoginTime() else { return }
      
      if self.isSessionExpired(since: loginTime) {
        self.logout()
        self.timer?.invalidate()
      }
    }
  }
  
  private func saveLoginTime() {
    Persistent.shared.setCodable(key: .loginSessionTime, value: Date())
  }
  
  private func clearSessionData() {
    Persistent.shared.delete(key: .loginSessionTime)
    NotificationManager.shared.removeAllNotifications()
    timer?.invalidate()
    logoutAuth0()
  }
  
  private func getLoginTime() -> Date? {
    Persistent.shared.getCodable(key: .loginSessionTime, type: Date.self)
  }
  
  private func isSessionExpired(since loginTime: Date) -> Bool {
    return Date().timeIntervalSince(loginTime) >= sessionTimeout
  }
}


extension SessionViewModel {
  func loginAuth0() {
    Auth0
      .webAuth()
      .useHTTPS()
      .start { result in
        switch result {
        case .success(let credential):
          let auth = UserCredentials(from: credential)
          self.credentials = auth
          self.login()
          self.loadProfileAuth0()
        case .failure(let error):
          print("Failed with: \(error)")
        }
      }
  }
  
  
  func logoutAuth0() {
    Auth0
      .webAuth()
      .useHTTPS()
      .clearSession { result in
        switch result {
        case .success:
          self.credentials = nil
          self.userProfile = nil
          Persistent.shared.delete(key: .userProfile)
        case .failure(let error):
          print("Failed with: \(error)")
        }
      }
  }
  
  func loadProfileAuth0() {
    guard let accessToken = credentials?.accessToken else {
      print("Access Token not available")
      return
    }
    
    Auth0
      .authentication()
      .userInfo(withAccessToken: accessToken)
      .start { [weak self] result in
        switch result {
        case .success(let userInfo):
          DispatchQueue.main.async {
            let profile = Profile(from: userInfo)
            self?.userProfile = profile
            Persistent.shared.setCodable(key: .userProfile, value: profile)
          }
        case .failure(let error):
          print("Failed to load profile: \(error)")
        }
      }
  }
}
