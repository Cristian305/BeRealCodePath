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

    init() { }
}
