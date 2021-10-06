//
//  GetGameDetailsResponse.swift
//  Game Data System
//
//  Created by Heitor Silveira on 06/10/21.
//

import Foundation

struct GameDetailsResponse : Codable {
    let id : Int32
    let slug: String
    let name: String
    let description: String
    let metacritic: Int16?
    let released: String?
    let image: String?
    let platforms: [PlatformWrapper]
    
    enum CodingKeys: String, CodingKey {
        case id
        case slug
        case name
        case description
        case metacritic
        case released
        case image = "background_image"
        case platforms
    }
}
