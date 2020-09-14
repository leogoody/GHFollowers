//
//  User.swift
//  GHFollowers
//
//  Created by Леонид Кузнецов on 20.03.2020.
//  Copyright © 2020 Leonid Kuznetcov. All rights reserved.
//

import Foundation

struct User: Codable {
    let login: String
    let avatarUrl: String
    var name: String?
    var location: String?
    var bio: String?
    let publicRepos: Int
    let publicGists: Int
    let htmlUrl: String
    let following: Int
    let followers: Int
    let createdAt: Date
}
