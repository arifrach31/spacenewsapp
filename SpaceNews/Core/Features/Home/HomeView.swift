//
//  HomeView.swift
//  SpaceNews
//
//  Created by ArifRachman on 11/04/25.
//

import SwiftUI

struct HomeView: View {
  @EnvironmentObject var sessionVM: SessionViewModel
  @EnvironmentObject var router: NavigationRouter
  @StateObject private var homeVM = HomeViewModel()
  
  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 24) {
        
        VStack(alignment: .center, spacing: 4) {
          Text(getGreeting())
            .font(.title2)
            .bold()
          Text(sessionVM.userProfile?.nickname ?? "-")
            .font(.title3)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
        
        SectionView(title: "Article") {
          ForEach(homeVM.articles) { article in
            NavigationLink(destination: ArticleDetailView(article: article)) {
              CardView(item: article)
            }
          }
        } seeMoreAction: {
          router.push(to: .articleList(category: .articles))
        }
        
        SectionView(title: "Blog") {
          ForEach(homeVM.blogs) { blog in
            NavigationLink(destination: ArticleDetailView(article: blog)) {
              CardView(item: blog)
            }
          }
        } seeMoreAction: {
          router.push(to: .articleList(category: .blog))
        }
        
        SectionView(title: "Report") {
          ForEach(homeVM.reports) { report in
            NavigationLink(destination: ArticleDetailView(article: report)) {
              CardView(item: report)
            }
          }
        } seeMoreAction: {
          router.push(to: .articleList(category: .report))
        }
      }
      .padding(.vertical)
      .onAppear {
        homeVM.fetchArticles()
        homeVM.fetchBlogs()
        homeVM.fetchReports()
      }
    }
  }
  
  private func getGreeting() -> String {
    let hour = Calendar.current.component(.hour, from: Date())
    switch hour {
    case 0..<12:
      return "Good Morning"
    case 12..<17:
      return "Good Afternoon"
    case 17..<20:
      return "Good Evening"
    default:
      return "Good Night"
    }
  }
}

struct SectionView<Content: View>: View {
  let title: String
  let content: () -> Content
  let seeMoreAction: (() -> Void)?
  
  init(title: String, @ViewBuilder content: @escaping () -> Content, seeMoreAction: (() -> Void)? = nil) {
    self.title = title
    self.content = content
    self.seeMoreAction = seeMoreAction
  }
  
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Text(title)
          .font(.headline)
        Spacer()
        Button("See More") {
          seeMoreAction?()
        }
        .font(.subheadline)
      }
      .padding(.horizontal)
      
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 16) {
          content()
        }
        .padding(.horizontal)
      }
    }
  }
}

struct CardView: View {
  let item: Article
  
  var body: some View {
    VStack(alignment: .leading) {
      AsyncImage(url: URL(string: item.imageUrl)) { phase in
        if let image = phase.image {
          image.resizable().scaledToFit()
        } else {
          Rectangle().foregroundColor(.gray)
        }
      }
      .frame(width: 150, height: 150)
      .clipped()
      
      Text(item.title)
        .font(.caption)
        .lineLimit(2)
    }
    .frame(width: 150)
  }
}
