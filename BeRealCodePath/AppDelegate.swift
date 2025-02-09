//
//  AppDelegate.swift
//  BeRealCodePath
//
//  Created by Cristian Gonzalez on 2/4/25.
//

import UIKit
import ParseSwift
import SwiftUI
import Foundation

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    private func getEnv(_ key: String) -> String {
            return Bundle.main.object(forInfoDictionaryKey: key) as? String ?? ""
        }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        print("🚀 AppDelegate started")
        
        ParseSwift.initialize(
            applicationId: getEnv("PARSE_APP_ID"),
            clientKey: getEnv("PARSE_CLIENT_KEY"),
            serverURL: URL(string: "https://parseapi.back4app.com")!
        )
        
         
        
        window = UIWindow(frame: UIScreen.main.bounds)
            guard let window = window else {
                print("❌ ERROR: Window is nil")
                return false
            }
            // ✅ Check if user is logged in
            if User.current != nil {
                print("✅ User is logged in, navigating to FeedViewController")
                
                // ✅ Wrap FeedViewController in a UINavigationController
                let feedVC = FeedViewController()
                let navigationController = UINavigationController(rootViewController: feedVC)
                window.rootViewController = navigationController
            } else {
                print("🔹 No user found, showing ContentView (Login Screen)")
                
                // ✅ Show SwiftUI ContentView as Root using UIHostingController
                let hostingController = UIHostingController(rootView: ContentView())
                window.rootViewController = hostingController
            }
        window.makeKeyAndVisible()
        let feedVC = FeedViewController()
        let navigationController = UINavigationController(rootViewController: feedVC)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()

        saveTestParseObject()
        return true
    }

    // ✅ Function to Save Test Parse Object
    private func saveTestParseObject() {
        var score = GameScore()
        score.playerName = "Kingsley"
        score.points = 13

        score.save { result in
            switch result {
            case .success(let savedScore):
                print("✅ Parse Object SAVED!: Player: \(savedScore.playerName ?? "Unknown"), Score: \(savedScore.points ?? 0)")
            case .failure(let error):
                print("❌ Error saving: \(error.localizedDescription)")
            }
        }
    }
}

// ✅ Define the Parse Object Struct
struct GameScore: ParseObject {
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?
    var originalData: Data?

    // Custom properties
    var playerName: String?
    var points: Int?
}

// ✅ Optional Custom Initializer
extension GameScore {
    init(playerName: String, points: Int) {
        self.playerName = playerName
        self.points = points
    }
}
