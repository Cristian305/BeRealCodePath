//
//  ViewControllerBridge.swift
//  BeRealCodePath
//
//  Created by Cristian Gonzalez on 2/5/25.
//

import SwiftUI
import UIKit

// Bridge for LoginViewController
struct LoginViewControllerBridge: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UINavigationController {
        // Create an instance of LoginViewController
        let loginVC = LoginViewController()
        
        // Wrap it in a UINavigationController
        let navController = UINavigationController(rootViewController: loginVC)
        return navController
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}

// Bridge for SignUpViewController
struct SignUpViewControllerBridge: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UINavigationController {
        // Create an instance of SignUpViewController
        let signUpVC = SignUpViewController()
        
        // Wrap it in a UINavigationController
        let navController = UINavigationController(rootViewController: signUpVC)
        return navController
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}

struct PostViewControllerBridge: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> PostViewController {
        print("✅ PostViewControllerBridge called.")
        return PostViewController()
    }
    
    func updateUIViewController(_ uiViewController: PostViewController, context: Context) {}
}

struct FeedViewControllerBridge: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UINavigationController {
        print("✅ FeedViewControllerBridge called.")
        let feedVC = FeedViewController()
        return UINavigationController(rootViewController: feedVC)
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}
