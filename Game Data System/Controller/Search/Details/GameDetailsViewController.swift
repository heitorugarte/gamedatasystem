//
//  GameDetailsViewController.swift
//  Game Data System
//
//  Created by Heitor Silveira on 06/10/21.
//

import Foundation
import UIKit
import CoreData

class GameDetailsViewController : UIViewController {
    
    var dataController : DataController!
    var game: GameDetailsResponse!
    var image: UIImage! = nil
    var isFavorite: Bool!
    
    var fetchedFavoritesListController:NSFetchedResultsController<StoredGame>!
    
    @IBOutlet weak var gameImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var metacriticLabel: UILabel!
    @IBOutlet weak var favoriteImage: UIImageView!
    @IBOutlet weak var favoriteLabel: UILabel!
    @IBOutlet weak var favoriteView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        setupGestureRecognizer()
        setupFetchedFavoritesController()
        
        let alphaGradientLayer = CAGradientLayer()
        alphaGradientLayer.frame = self.gameImage.bounds
        alphaGradientLayer.colors = [UIColor.black.withAlphaComponent(0.25).cgColor, UIColor.black.withAlphaComponent(1)]
        alphaGradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        alphaGradientLayer.endPoint = CGPoint(x: 0.0, y: 0.20)
        self.gameImage.layer.insertSublayer(alphaGradientLayer, at: 0)
        self.gameImage.layer.cornerRadius = 10
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupViewWithGame()
    }
    
    fileprivate func setupFetchedFavoritesController() {
        let fetchRequest:NSFetchRequest<StoredGame> = StoredGame.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedFavoritesListController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "favorites")
        do {
            try fetchedFavoritesListController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    func setupViewWithGame(){
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.titleLabel.text = game.name
        let descriptionText = game.description.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil).replacingOccurrences(of: "\n", with: " ").replacingOccurrences(of: "&#39;", with: "'")
        print(descriptionText)
        self.descriptionLabel.text = descriptionText
        if let releaseDate = game.released {
            let splitDate = releaseDate.split(separator: "-")
            let formattedDate = "\(splitDate[2])/\(splitDate[1])/\(splitDate[0])"
            self.releaseDateLabel.text = "Release date: \(formattedDate)"
        } else {
            self.releaseDateLabel.isHidden = true
        }
        if let metacritic = game.metacritic {
            self.metacriticLabel.text = String(metacritic)
        } else {
            self.metacriticLabel.text = "N/A"
        }
        setFavorite()
        if self.image != nil {
            self.gameImage.image = self.image
        } else if let imageUrl = game.image {
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
            RawgApi.downloadImage(urlString: imageUrl, completion: {imageData, error in
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    guard let imageData = imageData else {
                        self.gameImage.image = UIImage(named: "no-image")
                        return
                    }
                    let image = UIImage(data: imageData)
                    self.gameImage.image = image
                }
            })
        }
    }
    
    func setFavorite(){
        if isFavorite {
            self.favoriteImage.image = UIImage(systemName: "heart.fill")
            self.favoriteImage.tintColor = UIColor.red
            self.favoriteLabel.text = "Remove from favorites"
        } else {
            self.favoriteImage.image = UIImage(systemName: "heart")
            self.favoriteImage.tintColor = UIColor.systemBlue
            self.favoriteLabel.text = "Add to favorites"
        }
    }
    
    func setupGestureRecognizer(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(handlePressFavorite))
        self.favoriteView.addGestureRecognizer(tap)
    }
    
    @objc func handlePressFavorite(){
        if !isFavorite {
            self.isFavorite = true
            setFavorite()
            let newFavorite = StoredGame(context: dataController.viewContext)
            newFavorite.id = game.id
            newFavorite.name = game.name
            newFavorite.slug = game.slug
            newFavorite.metacritic = Int32(game.metacritic ?? 0)
            if let imageData = self.gameImage.image?.jpegData(compressionQuality: 1.0) {
                newFavorite.image = imageData
            }
            let platforms : [StoredPlatform] = game.platforms.map({let platform = StoredPlatform(context: dataController.viewContext)
                platform.id = Int32($0.platform.id)
                platform.name = $0.platform.name
                platform.slug = $0.platform.slug
                platform.releasedAt = $0.releasedAt
                return platform
            })
            let platformsSet = NSSet(array: platforms)
            newFavorite.addToPlatforms(platformsSet)
            try? dataController.viewContext.save()
            showToast(message: "Added to favorites.", font: UIFont(name: "Apple SD Gothic Neo", size: 12)!)
        } else {
            self.isFavorite = false
            setFavorite()
            showToast(message: "Removed from favorites.")
            if let favoritesList = fetchedFavoritesListController.fetchedObjects{
                let favorite = favoritesList.first(where: {$0.id == game.id})
                if let favorite = favorite {
                    dataController.viewContext.delete(favorite)
                    showToast(message: "Removed from favorites.")
                    try? dataController.viewContext.save()
                }
            }
        }
    }
    
    func showToast(message : String, font: UIFont = UIFont(name: "Apple SD Gothic Neo", size: 12)!) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-150, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}
