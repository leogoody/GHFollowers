//
//  GFError.swift
//  GHFollowers
//
//  Created by Леонид Кузнецов on 28.03.2020.
//  Copyright © 2020 Leonid Kuznetcov. All rights reserved.
//

import Foundation

enum GFError: String, Error {
    
    case invalidUsername    = "This username created an invalid request. Please try again."
    case unableToComplete   = "Unable to complete your request. Please check your Internet connection."
    case invalidResponse    = "Invalid response from the server. Please try again."
    case invalidData        = "The data received from the server is invalid. Please try again."
    case unableToFavorite   = "Error adding user to favorites."
    case alreadyInFavorites = "This user is already in your favorites."
}
