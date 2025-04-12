//
//  RecentSearchView.swift
//  SpaceNews
//
//  Created by ArifRachman on 12/04/25.
//

import SwiftUI

struct RecentSearchView: View {
  @Environment(\.dismiss) var dismiss
  @ObservedObject var viewModel: RecentSearchViewModel
  @State private var searchText = ""
  
  var body: some View {
    NavigationView {
      VStack {
        TextField("Search recent articles", text: $searchText)
          .padding(7)
          .background(Color(.systemGray6))
          .cornerRadius(8)
          .padding(.horizontal)
        
        List {
          ForEach(viewModel.filteredRecentSearches(searchText: searchText)) { recentSearch in
            NavigationLink(destination: ArticleDetailView(article: recentSearch.article)) {
              VStack(alignment: .leading) {
                Text(recentSearch.article.title)
                  .font(.headline)
                Text("Searched on: \(recentSearch.formattedTimestamp)")
                  .font(.subheadline)
                  .foregroundColor(.gray)
                if let editedText = recentSearch.editedText, !editedText.isEmpty {
                  Text("Edited: \(editedText)")
                    .font(.caption)
                    .foregroundColor(.orange)
                }
              }
            }
          }
          .onDelete(perform: viewModel.removeRecentSearch)
        }
        .listStyle(PlainListStyle())
      }
      .navigationTitle("Recent Searches")
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

