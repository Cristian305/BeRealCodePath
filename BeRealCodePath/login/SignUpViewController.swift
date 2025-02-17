//
//  SignUpView.swift
//  BeRealCodePath
//
//  Created by Cristian Gonzalez on 2/4/25.
//

import SwiftUI
import ParseSwift

struct SignUpViewController: View {
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    // Back Button
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "arrow.left")
                                .foregroundColor(.white)
                                .font(.system(size: 24, weight: .bold))
                        }
                        .padding(.leading)
                        Spacer()
                    }

                    // Title
                    Text("Sign Up")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    // Username Field
                    TextField("Username", text: $username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .foregroundColor(.white)

                    // Email Field
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .foregroundColor(.white)

                    // Password Field
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .foregroundColor(.white)

                    // Sign Up Button
                    Button(action: signUp) {
                        Text("Sign Up")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)

                    Spacer()
                }
                .padding()
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Sign-Up Failed"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }

    // Handle sign-up logic
    private func signUp() {
        guard !username.isEmpty, !email.isEmpty, !password.isEmpty else {
            alertMessage = "All fields are required"
            showAlert = true
            return
        }

        // Log out current user if any
        if let currentUser = User.current {
            try? User.logout()
        }

        // Create new user
        var newUser = User()
        newUser.username = username
        newUser.email = email
        newUser.password = password

        newUser.signup { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    print("✅ Successfully signed up user: \(user)")
                    dismiss()
                case .failure(let error):
                    alertMessage = error.localizedDescription
                    showAlert = true
                }
            }
        }
    }
}

#Preview {
    SignUpViewController()
}
