//
//  post.swift
//  BeRealCodePath
//
//  Created by Cristian Gonzalez on 2/4/25.
//
import Foundation
import ParseSwift

struct Post: ParseObject {
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?
    var originalData: Data?

    var caption: String?
    var imageFile: ParseFile?
    var user: User?  // Assuming you have a `User` model
    
    var location: [String: Double]? // ✅ Add this to store latitude & longitude
    var comments: [Comment]?

    // MARK: - Computed Property: Should Blur
    var shouldBlur: Bool {
        guard let lastPostedDate = User.current?.lastPostedDate else {
            print("⚠️ No lastPostedDate found for current user")
            return true
        }

        guard let postDate = createdAt else {
            print("⚠️ No createdAt found for post \(objectId ?? "unknown")")
            return true
        }

        let calendar = Calendar.current
        guard let thresholdDate = calendar.date(byAdding: .day, value: -1, to: lastPostedDate) else {
            print("⚠️ Failed to calculate threshold date")
            return true
        }

        let shouldBlur = postDate < thresholdDate
        print("🔍 Post Date: \(postDate) | Threshold Date: \(thresholdDate) | Should Blur: \(shouldBlur)")

        return shouldBlur
    }

    init() { }
}
