//
//  Article.swift
//  SpaceNews
//
//  Created by ArifRachman on 12/04/25.
//

import Foundation

struct ArticleResponse: Codable {
  let previous: String?
  let results: [Article]
  let count: Int
  let next: String?
}

struct Article: Codable, Identifiable {
  let id: Int
  let publishedAt: String
  let launches: [Launch]?
  let newsSite: String
  let imageUrl: String
  let authors: [Author]?
  let url: String?
  let featured: Bool?
  let title: String
  let summary: String
  let updatedAt: String?
  let events: [Event]?
  
  enum CodingKeys: String, CodingKey {
    case id, launches, authors, url, featured, title, summary, events
    case newsSite = "news_site"
    case imageUrl = "image_url"
    case publishedAt = "published_at"
    case updatedAt = "updated_at"
  }
}

struct Author: Codable {
  let name: String
  let socials: Socials?
}

struct Socials: Codable {
  let youtube: String?
  let linkedin: String?
  let mastodon: String?
  let bluesky: String?
  let x: String?
  let instagram: String?
}

struct Launch: Codable {
  let launchId: String
  let provider: String
  
  enum CodingKeys: String, CodingKey {
    case launchId = "launch_id"
    case provider
  }
}

struct Event: Codable {
  let eventId: Int
  let provider: String
  
  enum CodingKeys: String, CodingKey {
    case eventId = "event_id"
    case provider
  }
}
