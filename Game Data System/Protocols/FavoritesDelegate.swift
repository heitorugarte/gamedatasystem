//
//  FavoritesDelegate.swift
//  Game Data System
//
//  Created by Heitor Silveira on 05/10/21.
//

import Foundation

protocol FavoritesDelegate {
    func addToFavorites(game: Game, imageData : Data?)
    func removeFromFavorites(id: Int32)
}
