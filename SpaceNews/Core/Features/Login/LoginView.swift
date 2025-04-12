//
//  LoginView.swift
//  SpaceNews
//
//  Created by ArifRachman on 11/04/25.
//

import SwiftUI
import Auth0

struct LoginView: View {
  @EnvironmentObject var sessionVM: SessionViewModel
  
  var body: some View {
    VStack(spacing: 20) {
      Text("Space News")
        .font(.largeTitle)
      
      Button("Login/Register", action: sessionVM.loginAuth0)
      .padding()
      .background(Color.blue)
      .foregroundColor(.white)
      .cornerRadius(10)
    }
  }
}
