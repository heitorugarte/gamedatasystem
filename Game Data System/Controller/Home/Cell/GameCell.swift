//
//  GameCell.swift
//  Game Data System
//
//  Created by Heitor Silveira on 04/10/21.
//

import Foundation
import UIKit

class GameCell : UICollectionViewCell {
    var game: Game!
    var storedGame: StoredGame!
    var delegate: FavoritesDelegate!
    
    var hasAddedGradient: Bool = false
    
    private var isFavorite: Bool!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var btFavorite: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if !hasAddedGradient{
            self.backgroundColor = self.superview?.backgroundColor
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = self.contentView.bounds
            gradientLayer.colors = [UIColor.white.cgColor, UIColor.black.cgColor]
            
            let alphaGradientLayer = CAGradientLayer()
            alphaGradientLayer.frame = self.imageView.bounds
            alphaGradientLayer.colors = [UIColor.black.withAlphaComponent(0.5).cgColor, UIColor.black.withAlphaComponent(1)]
            alphaGradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
            alphaGradientLayer.endPoint = CGPoint(x: 0.0, y: 0.15)
            
            self.imageView.layer.insertSublayer(alphaGradientLayer, at: 0)
            self.contentView.layer.insertSublayer(gradientLayer, at: 0)
            hasAddedGradient = true
        }
        
    }
    
    @IBAction func handlePressFavorite(_ sender: Any) {
        if !isFavorite{
            delegate.addToFavorites(game: game, imageData: imageView.image?.jpegData(compressionQuality: 1.0))
            isFavorite = true
        } else {
            delegate.removeFromFavorites(id: game != nil ? game.id : storedGame.id)
            isFavorite = false
        }
        setFavoriteImage()
    }
    
    func setFavoriteImage(){
        if isFavorite {
            self.btFavorite.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            self.btFavorite.tintColor = UIColor.red
        } else {
            self.btFavorite.setImage(UIImage(systemName: "heart"), for: .normal)
            self.btFavorite.tintColor = UIColor.systemBlue
        }
    }
    
    func setGame(game: Game, isFavorite: Bool){
        self.game = game
        self.titleLabel.text = game.name
        self.isFavorite = isFavorite
        setFavoriteImage()
    }
    
    func setStoredGame(game: StoredGame){
        self.storedGame = game
        self.titleLabel.text = game.name
        self.isFavorite = true
        setFavoriteImage()
    }
}
