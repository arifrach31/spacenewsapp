//
//  RecentSearchViewModel.swift
//  SpaceNews
//
//  Created by ArifRachman on 12/04/25.
//

import Foundation

final class RecentSearchViewModel: ObservableObject {
  @Published var recentSearches: [RecentSearch] = []
  
  init() {
    loadRecentSearches()
  }
  
  func addRecentSearch(article: Article, editedText: String? = nil) {
    let newRecentSearch = RecentSearch(article: article, timestamp: Date(), editedText: editedText)
    if let index = recentSearches.firstIndex(where: { $0.article.id == article.id }) {
      recentSearches[index] = newRecentSearch
    } else {
      recentSearches.insert(newRecentSearch, at: 0)
    }
    saveRecentSearches()
  }
  
  func removeRecentSearch(at offsets: IndexSet) {
    recentSearches.remove(atOffsets: offsets)
    saveRecentSearches()
  }
  
  func filteredRecentSearches(searchText: String) -> [RecentSearch] {
    if searchText.isEmpty {
      return recentSearches
    } else {
      return recentSearches.filter {
        $0.article.title.localizedCaseInsensitiveContains(searchText) ||
        ($0.editedText?.localizedCaseInsensitiveContains(searchText) ?? false)
      }
    }
  }
  
  private func saveRecentSearches() {
    if let encoded = try? JSONEncoder().encode(recentSearches) {
      UserDefaults.standard.set(encoded, forKey: "recentSearches")
    }
  }
  
  private func loadRecentSearches() {
    if let savedSearchesData = UserDefaults.standard.data(forKey: "recentSearches"),
       let savedSearches = try? JSONDecoder().decode([RecentSearch].self, from: savedSearchesData) {
      recentSearches = savedSearches
    }
  }
}
