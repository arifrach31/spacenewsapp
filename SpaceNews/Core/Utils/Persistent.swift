//
//  Persistent.swift
//  SpaceNews
//
//  Created by ArifRachman on 11/04/25.
//

import Foundation

public enum PersistentType: String {
  case loginSessionTime
  case userProfile
}

public struct Persistent {
  public static let shared = Persistent()
  
  private let userDefaults = UserDefaults.standard
  
  public func set(key: PersistentType, value: String) {
    userDefaults.set(value, forKey: key.rawValue)
  }
  
  public func get(key: PersistentType) -> String? {
    return userDefaults.string(forKey: key.rawValue)
  }
  
  public func delete(key: PersistentType) {
    userDefaults.removeObject(forKey: key.rawValue)
  }
  
  public func setCodable<T: Codable>(key: PersistentType, value: T) {
    let encoder = JSONEncoder()
    if let data = try? encoder.encode(value) {
      userDefaults.set(data, forKey: key.rawValue)
    }
  }
  
  public func getCodable<T: Codable>(key: PersistentType, type: T.Type) -> T? {
    if let data = userDefaults.data(forKey: key.rawValue) {
      let decoder = JSONDecoder()
      do {
        let decoded = try decoder.decode(T.self, from: data)
        return decoded
      } catch {
        print("❌ Failed to decode \(key.rawValue): \(error)")
      }
    } else {
      print("⚠️ No data found for \(key.rawValue)")
    }
    return nil
  }

}
