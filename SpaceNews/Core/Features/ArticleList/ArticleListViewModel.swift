//
//  ArticleListViewModel.swift
//  SpaceNews
//
//  Created by ArifRachman on 12/04/25.
//

import Foundation
import Combine

final class ArticleListViewModel: ObservableObject {
  @Published var articles: [Article] = []
  @Published var isLoadingMore: Bool = false
  @Published var errorMessage: String?
  @Published var availableNewsSites: [String]?
  @Published var canLoadNext = true
  
  @Published var showRecentSearches = false
  var recentSearchViewModel = RecentSearchViewModel()
  
  private var currentPage = 0
  private let limit = 10
  private var cancellables = Set<AnyCancellable>()
  private let cacheKey: String
  private let userDefaults = UserDefaults.standard
  
  let category: SectionCategory
  
  init(category: SectionCategory) {
    self.category = category
    self.cacheKey = "\(category.rawValue)_last_articles"
    loadCachedArticles()
    loadInitialArticles()
  }
  
  func loadInitialArticles() {
    currentPage = 0
    canLoadNext = true
    articles.removeAll()
    loadMoreArticles()
  }
  
  func loadMoreArticles() {
    guard canLoadNext && !isLoadingMore else { return }
    isLoadingMore = true
    
    let apiEndpoint: APIEndpoint
    switch category {
    case .articles:
      apiEndpoint = .articles(limit: limit, offset: currentPage * limit)
    case .blog:
      apiEndpoint = .blogs(limit: limit, offset: currentPage * limit)
    case .report:
      apiEndpoint = .reports(limit: limit, offset: currentPage * limit)
    }
    
    NetworkManager.shared.request(endpoint: apiEndpoint, responseType: ArticleResponse.self) { [weak self] result in
      DispatchQueue.main.async {
        guard let self = self else { return }
        self.isLoadingMore = false
        switch result {
        case .success(let response):
          let newArticles = response.results
          self.articles.append(contentsOf: newArticles)
          self.cacheLastLoadedArticles(newArticles)
          if response.next == nil || newArticles.isEmpty {
            self.canLoadNext = false
          } else {
            self.currentPage += 1
          }
        case .failure(let error):
          self.errorMessage = error.localizedDescription
        }
      }
    }
  }
  
  func fetchAvailableNewsSites(for category: SectionCategory) {
    let apiEndpoint: APIEndpoint
    switch category {
    case .articles:
      apiEndpoint = .articles(limit: 1, offset: 0)
    case .blog:
      apiEndpoint = .blogs(limit: 1, offset: 0)
    case .report:
      apiEndpoint = .reports(limit: 1, offset: 0)
    }
    
    NetworkManager.shared.request(endpoint: apiEndpoint, responseType: ArticleResponse.self) { [weak self] result in
      DispatchQueue.main.async {
        guard let self = self else { return }
        switch result {
        case .success(let response):
          let allSites = response.results.map { $0.newsSite }
          let combinedSites = Set(self.articles.map { $0.newsSite } + allSites)
          self.availableNewsSites = Array(combinedSites).sorted()
        case .failure(let error):
          print("Error fetching news sites: \(error)")
        }
      }
    }
  }
  
  func isLastItem(_ article: Article) -> Bool {
    guard let lastArticle = articles.last else { return false }
    return article.id == lastArticle.id
  }
  
  private func cacheLastLoadedArticles(_ newArticles: [Article]) {
    if let encoded = try? JSONEncoder().encode(newArticles) {
      userDefaults.set(encoded, forKey: cacheKey)
    }
  }
  
  private func loadCachedArticles() {
    if let savedArticlesData = userDefaults.data(forKey: cacheKey),
       let savedArticles = try? JSONDecoder().decode([Article].self, from: savedArticlesData) {
      articles = savedArticles
    }
  }
}

enum SortOrder {
  case none
  case ascending
  case descending
}

enum SectionCategory: String, CaseIterable {
  case articles
  case blog
  case report
}
