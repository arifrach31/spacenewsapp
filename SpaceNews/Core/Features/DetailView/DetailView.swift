//
//  DetailView.swift
//  SpaceNews
//
//  Created by ArifRachman on 12/04/25.
//

import SwiftUI

struct ArticleDetailView: View {
  @ObservedObject var recentSearchViewModel = RecentSearchViewModel()
  
  let article: Article
  
  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 16) {
        AsyncImage(url: URL(string: article.imageUrl)) { phase in
          switch phase {
          case .empty:
            ProgressView()
          case .success(let image):
            image
              .resizable()
              .scaledToFit()
          case .failure:
            Image(systemName: "photo.fill")
              .foregroundColor(.gray)
          @unknown default:
            EmptyView()
          }
        }
        .frame(maxWidth: .infinity)
        
        Text(article.title)
          .font(.title2)
          .bold()
          .lineLimit(5)
        
        Text("Published: \(formatPublishedDate(article.publishedAt))")
          .font(.subheadline)
          .foregroundColor(.secondary)
        
        Text(getFirstSentence(from: article.summary))
          .font(.body)
      }
      .padding()
    }
    .navigationTitle(article.title)
    .navigationBarTitleDisplayMode(.inline)
    .onAppear {
      recentSearchViewModel.addRecentSearch(article: article)
    }
  }
  
  private func formatPublishedDate(_ dateString: String) -> String {
    let dateFormatter = ISO8601DateFormatter()
    if let date = dateFormatter.date(from: dateString) {
      let outputFormatter = DateFormatter()
      outputFormatter.dateFormat = "d MMMM yyyy, HH:mm"
      outputFormatter.locale = Locale.current
      return outputFormatter.string(from: date)
    }
    return "N/A"
  }
  
  private func getFirstSentence(from text: String) -> String {
    if let dotRange = text.range(of: ".") {
      let firstSentence = text[..<dotRange.upperBound].trimmingCharacters(in: .whitespacesAndNewlines)
      return firstSentence
    } else {
      return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
  }
}
