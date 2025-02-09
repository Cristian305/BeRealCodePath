//
//  ContentView.swift
//  BeRealCodePath
//
//  Created by Cristian Gonzalez on 2/4/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)

            VStack {
                Text("BeReal.")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.bottom, 40)

                Button(action: {
                    presentLoginViewController()
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

                Button(action: {
                    presentSignUpViewController()
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
            }
        }
    }
}

// ✅ Helper functions to present view controllers manually
func presentLoginViewController() {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let keyWindow = windowScene.windows.first,
          let rootVC = keyWindow.rootViewController else {
        return
    }
    
    let loginVC = LoginViewController()
    loginVC.modalPresentationStyle = .fullScreen
    rootVC.present(loginVC, animated: true)
}

func presentSignUpViewController() {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let keyWindow = windowScene.windows.first,
          let rootVC = keyWindow.rootViewController else {
        return
    }
    
    let signUpVC = SignUpViewController()
    signUpVC.modalPresentationStyle = .fullScreen
    rootVC.present(signUpVC, animated: true)
}

#Preview {
    ContentView()
}

