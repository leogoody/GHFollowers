//
//  Follower.swift
//  GHFollowers
//
//  Created by Леонид Кузнецов on 20.03.2020.
//  Copyright © 2020 Leonid Kuznetcov. All rights reserved.
//

import Foundation

struct Follower: Codable, Hashable {
    var login: String
    var avatarUrl: String
}
