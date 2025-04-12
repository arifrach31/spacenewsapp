//
//  HomeViewModel.swift
//  SpaceNews
//
//  Created by ArifRachman on 12/04/25.
//

import Foundation
import Combine

final class HomeViewModel: ObservableObject {
  @Published var articles: [Article] = []
  @Published var blogs: [Article] = []
  @Published var reports: [Article] = []
  
  @Published var isLoading: Bool = false
  @Published var errorMessage: String?
  
  private var cancellables = Set<AnyCancellable>()
  
  func fetchArticles() {
    isLoading = true
    errorMessage = nil
    
    NetworkManager.shared.request(
      endpoint: .articles(limit: 10, offset: 0),
      responseType: ArticleResponse.self
    ) { [weak self] result in
      DispatchQueue.main.async {
        self?.isLoading = false
        switch result {
        case .success(let response):
          self?.articles = response.results
        case .failure(let error):
          self?.errorMessage = error.localizedDescription
        }
      }
    }
  }
  
  func fetchBlogs() {
    isLoading = true
    errorMessage = nil
    
    NetworkManager.shared.request(
      endpoint: .blogs(limit: 10, offset: 0),
      responseType: ArticleResponse.self
    ) { [weak self] result in
      DispatchQueue.main.async {
        self?.isLoading = false
        switch result {
        case .success(let response):
          self?.blogs = response.results
        case .failure(let error):
          self?.errorMessage = error.localizedDescription
        }
      }
    }
  }
  
  func fetchReports() {
    isLoading = true
    errorMessage = nil
    
    NetworkManager.shared.request(
      endpoint: .reports(limit: 10, offset: 0),
      responseType: ArticleResponse.self
    ) { [weak self] result in
      DispatchQueue.main.async {
        self?.isLoading = false
        switch result {
        case .success(let response):
          self?.reports = response.results
        case .failure(let error):
          self?.errorMessage = error.localizedDescription
        }
      }
    }
  }
}
