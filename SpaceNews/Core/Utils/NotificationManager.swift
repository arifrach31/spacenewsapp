//
//  NotificationManager.swift
//  SpaceNews
//
//  Created by ArifRachman on 11/04/25.
//

import Foundation
import UserNotifications

class NotificationManager {
  static let shared = NotificationManager()
  
  private init() {}
  
  func requestPermission() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
      if let error = error {
        print("Notification permission error: \(error.localizedDescription)")
      } else {
        print("Permission granted: \(granted)")
      }
    }
  }
  
  func scheduleLocalNotification(
    after seconds: TimeInterval,
    title: String,
    body: String,
    identifier: String = UUID().uuidString
  ) {
    let content = UNMutableNotificationContent()
    content.title = title
    content.body = body
    content.sound = .default
    
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
    let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
    
    UNUserNotificationCenter.current().add(request)
  }

  func removeAllNotifications() {
    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
  }
}
