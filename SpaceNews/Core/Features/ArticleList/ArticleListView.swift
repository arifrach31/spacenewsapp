//
//  ArticleListView.swift
//  SpaceNews
//
//  Created by ArifRachman on 12/04/25.
//

import SwiftUI
import Combine

struct ArticleListView: View {
  @StateObject private var viewModel: ArticleListViewModel
  @State private var searchText = ""
  @State private var selectedNewsSite: String? = nil
  @State private var sortOrder: SortOrder = .none
  @State private var showFilterSortOptions = false
  
  let category: SectionCategory
  let columns = [GridItem(.adaptive(minimum: 300, maximum: .infinity), spacing: 16)]
  
  init(category: SectionCategory) {
    self._viewModel = StateObject(wrappedValue: ArticleListViewModel(category: category))
    self.category = category
  }
  
  private var filteredAndSortedArticles: [Article] {
    ArticleFilterSort.filterAndSort(
      articles: viewModel.articles,
      searchText: searchText,
      selectedNewsSite: selectedNewsSite,
      sortOrder: sortOrder
    )
  }
  
  var body: some View {
    NavigationView {
      VStack {
        SearchFilterHeaderView(
          searchText: $searchText,
          showFilterSortOptions: $showFilterSortOptions
        )
        
        ScrollView {
          LazyVGrid(columns: columns, spacing: 16) {
            ForEach(filteredAndSortedArticles) { article in
              NavigationLink(destination: ArticleDetailView(article: article)) {
                ArticleCardView(article: article)
              }
              .onTapGesture {
                viewModel.recentSearchViewModel.addRecentSearch(article: article)
              }
              .onAppear {
                if viewModel.isLastItem(article) && viewModel.canLoadNext {
                  viewModel.loadMoreArticles()
                }
              }
            }
            
            if viewModel.isLoadingMore {
              ProgressView()
                .frame(maxWidth: .infinity)
                .padding()
            }
            
            if let errorMessage = viewModel.errorMessage {
              ErrorView(message: "Error loading \(navigationTitle(for: category).lowercased()): \(errorMessage)")
            }
          }
          .padding()
        }
      }
      .navigationTitle(category.rawValue.uppercased())
      .toolbar {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
          Button {
            viewModel.showRecentSearches = true
          } label: {
            Image(systemName: "clock.arrow.circlepath")
          }
          
          FilterSortMenuView(
            viewModel: viewModel,
            selectedNewsSite: $selectedNewsSite,
            sortOrder: $sortOrder
          )
        }
      }
      .onAppear {
        viewModel.loadInitialArticles()
        viewModel.fetchAvailableNewsSites(for: category)
      }
    }
    .sheet(isPresented: $showFilterSortOptions) {
      FilterSortView(
        viewModel: viewModel,
        selectedNewsSite: $selectedNewsSite,
        sortOrder: $sortOrder
      )
    }
    .sheet(isPresented: $viewModel.showRecentSearches) {
      RecentSearchView(viewModel: viewModel.recentSearchViewModel)
    }
  }
  
  private func navigationTitle(for category: SectionCategory) -> String {
    switch category {
    case .articles: return "Articles"
    case .blog: return "Blogs"
    case .report: return "Reports"
    }
  }
}

struct SearchFilterHeaderView: View {
  @Binding var searchText: String
  @Binding var showFilterSortOptions: Bool
  
  var body: some View {
    HStack {
      TextField("Search title", text: $searchText)
        .padding(7)
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .padding(.horizontal)
      
      Button {
        showFilterSortOptions.toggle()
      } label: {
        Image(systemName: "line.3.horizontal.decrease.circle")
          .font(.title2)
      }
      .padding(.trailing)
    }
  }
}

struct FilterSortMenuView: View {
  @ObservedObject var viewModel: ArticleListViewModel
  @Binding var selectedNewsSite: String?
  @Binding var sortOrder: SortOrder
  
  var body: some View {
    Menu {
      Picker("Sort By", selection: $sortOrder) {
        Text("None").tag(SortOrder.none)
        Text("Date Ascending").tag(SortOrder.ascending)
        Text("Date Descending").tag(SortOrder.descending)
      }
      
      if let newsSites = viewModel.availableNewsSites {
        Menu("Filter by News Site") {
          Button("All") {
            selectedNewsSite = nil
          }
          ForEach(newsSites.sorted(), id: \.self) { site in
            Button(site) {
              selectedNewsSite = site
            }
          }
        }
      }
    } label: {
      Image(systemName: "arrow.up.arrow.down")
    }
  }
}

struct ErrorView: View {
  let message: String
  
  var body: some View {
    Text(message)
      .foregroundColor(.red)
      .frame(maxWidth: .infinity)
      .padding()
  }
}

struct FilterSortView: View {
  @ObservedObject var viewModel: ArticleListViewModel
  @Binding var selectedNewsSite: String?
  @Binding var sortOrder: SortOrder
  @Environment(\.dismiss) var dismiss
  
  var body: some View {
    NavigationView {
      Form {
        Section(header: Text("Sort By")) {
          Picker("Sort Order", selection: $sortOrder) {
            Text("None").tag(SortOrder.none)
            Text("Date Ascending").tag(SortOrder.ascending)
            Text("Date Descending").tag(SortOrder.descending)
          }
        }
        
        Section(header: Text("Filter by News Site")) {
          Button("All") {
            selectedNewsSite = nil
            dismiss()
          }
          if let newsSites = viewModel.availableNewsSites?.sorted() {
            ForEach(newsSites, id: \.self) { site in
              Button(site) {
                selectedNewsSite = site
                dismiss()
              }
            }
          } else {
            Text("Loading News Sites...")
          }
        }
      }
      .navigationTitle("Filter & Sort")
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Done") {
            dismiss()
          }
        }
      }
    }
  }
}

struct ArticleCardView: View {
  let article: Article
  
  var body: some View {
    VStack(alignment: .leading) {
      AsyncImage(url: URL(string: article.imageUrl)) { phase in
        switch phase {
        case .empty:
          ProgressView()
        case .success(let image):
          image
            .resizable()
            .scaledToFill()
            .frame(height: 200)
            .clipped()
        case .failure:
          Rectangle()
            .fill(Color.gray.opacity(0.3))
            .frame(height: 200)
            .overlay(Image(systemName: "photo.fill").foregroundColor(.gray))
        @unknown default:
          EmptyView()
        }
      }
      .cornerRadius(8)
      
      VStack(alignment: .leading, spacing: 8) {
        Text(article.title)
          .font(.headline)
          .lineLimit(2)
        Text(article.newsSite)
          .font(.subheadline)
          .foregroundColor(.gray)
        
        HStack {
          VStack(alignment: .leading) {
            Text("Launches:")
              .font(.caption)
              .foregroundColor(.secondary)
            if let launches = article.launches, !launches.isEmpty {
              ForEach(launches, id: \.launchId) { launch in
                Text("- \(launch.provider)")
                  .font(.caption2)
              }
            } else {
              Text("- None")
                .font(.caption2)
            }
          }
          Spacer()
          VStack(alignment: .leading) {
            Text("Events:")
              .font(.caption)
              .foregroundColor(.secondary)
            if let events = article.events, !events.isEmpty {
              ForEach(events, id: \.eventId) { event in
                Text("- \(event.provider)")
                  .font(.caption2)
              }
            } else {
              Text("- None")
                .font(.caption2)
            }
          }
        }
      }
      .padding(8)
    }
    .background(Color.white)
    .cornerRadius(10)
    .shadow(radius: 3)
  }
}

struct ArticleFilterSort {
  static func filterAndSort(articles: [Article], searchText: String, selectedNewsSite: String?, sortOrder: SortOrder) -> [Article] {
    var filtered = articles
    
    if !searchText.isEmpty {
      filtered = filtered.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }
    
    if let selectedNewsSite = selectedNewsSite, selectedNewsSite != "All" {
      filtered = filtered.filter { $0.newsSite == selectedNewsSite }
    }
    
    switch sortOrder {
    case .ascending:
      filtered.sort { $0.publishedAt < $1.publishedAt }
    case .descending:
      filtered.sort { $0.publishedAt > $1.publishedAt }
    case .none:
      break
    }
    
    return filtered
  }
}
