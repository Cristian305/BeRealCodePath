//
//  ContentView.swift
//  BeRealCodePath
//
//  Created by Cristian Gonzalez on 2/4/25.
//

import SwiftUI

struct ContentView: View {
    @State private var isShowingLogin = false
    @State private var isShowingSignUp = false

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                // Title
                Text("BeReal.")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.bottom, 40)

                // Sign In Button
                Button(action: {
                    isShowingLogin = true
                }) {
                    Text("Sign In")
                        .font(.title2)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 40)
                .fullScreenCover(isPresented: $isShowingLogin) {
                    LoginViewController()
                }

                // Sign Up Button
                Button(action: {
                    isShowingSignUp = true
                }) {
                    Text("Sign Up")
                        .font(.title2)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 40)
                .padding(.top, 10)
                .fullScreenCover(isPresented: $isShowingSignUp) {
                    SignUpViewController()
                }
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
