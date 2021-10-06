//
//  GetGamesListResponse.swift
//  Game Data System
//
//  Created by Heitor Silveira on 04/10/21.
//

import Foundation

struct GetGamesListResponse : Codable {
    let count: Int32
    let next: String
    let previous: String?
    var results: [Game]
}

struct Game : Codable {
    let id: Int32
    let slug: String
    let name: String
    let released: String?
    let tba: Bool
    let backgroundImage: String?
    let rating: Double
    let metacritic: Int?
    let updated: String
    let esrbRating: EsrbRating?
    let platforms: [PlatformWrapper]
    
    enum CodingKeys : String, CodingKey {
        case id
        case slug
        case name
        case released
        case tba
        case backgroundImage = "background_image"
        case rating
        case metacritic
        case updated
        case esrbRating = "esrb_rating"
        case platforms
    }
}

struct PlatformWrapper: Codable {
    let platform: Platform
    let releasedAt: String?
    
    enum CodingKeys : String, CodingKey {
        case platform
        case releasedAt = "released_at"
    }
}

struct Platform : Codable {
    let id: Int
    let slug: String
    let name: String
}

struct SystemRequirements: Codable {
    let minimum: String
    let recommended: String
}

struct EsrbRating : Codable {
    let id: Int
    let slug: String
    let name: String
}
