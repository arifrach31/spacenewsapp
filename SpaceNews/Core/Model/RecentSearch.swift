//
//  RecentSearch.swift
//  SpaceNews
//
//  Created by ArifRachman on 12/04/25.
//

import Foundation

struct RecentSearch: Identifiable, Codable {
  var id = UUID()
  let article: Article
  let timestamp: Date
  var editedText: String?
  
  var formattedTimestamp: String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter.string(from: timestamp)
  }
}
