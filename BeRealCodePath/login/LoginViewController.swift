//
//  LoginView.swift
//  BeRealCodePath
//
//  Created by Cristian Gonzalez on 2/4/25.
//

import SwiftUI
import ParseSwift

struct LoginViewController: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isAuthenticated = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    // Back Button
                    HStack {
                        Button(action: {
                            dismissLogin()
                        }) {
                            Image(systemName: "arrow.left")
                                .foregroundColor(.white)
                                .font(.system(size: 24, weight: .bold))
                        }
                        .padding(.leading)
                        Spacer()
                    }

                    // Title
                    Text("Login")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    // Username Field
                    TextField("Username", text: $username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .padding()
                        .background(Color.black.opacity(0.2))
                        .cornerRadius(10)
                        .foregroundColor(.black)

                    // Password Field
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .background(Color.black.opacity(0.2))
                        .cornerRadius(10)
                        .foregroundColor(.white)

                    // Login Button
                    Button(action: login) {
                        Text("Login")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)

                    Spacer()
                }
                .padding()
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Login Failed"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .fullScreenCover(isPresented: $isAuthenticated) {
                FeedViewController() // SwiftUI version
            }
        }
    }

    // Handle login logic
    private func login() {
        guard !username.isEmpty, !password.isEmpty else {
            alertMessage = "All fields are required"
            showAlert = true
            return
        }

        User.login(username: username, password: password) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    print("✅ Successfully logged in as user: \(user)")
                    isAuthenticated = true
                case .failure(let error):
                    alertMessage = error.localizedDescription
                    showAlert = true
                }
            }
        }
    }

    // Dismiss the login screen
    private func dismissLogin() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first {
            window.rootViewController?.dismiss(animated: true)
        }
    }
}

#Preview {
    LoginViewController()
}
