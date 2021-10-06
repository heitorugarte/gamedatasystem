//
//  FavoritesViewController.swift
//  Game Data System
//
//  Created by Heitor Silveira on 04/10/21.
//

import Foundation
import UIKit
import CoreData

class FavoritesViewController : UIViewController {
    var dataController : DataController!
    var fetchedFavoritesListController:NSFetchedResultsController<StoredGame>!
    
    @IBOutlet weak var favoritesCollection: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFetchedFavoritesController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.topItem!.title = "Favorites"
    }
    
    fileprivate func setupFetchedFavoritesController() {
        let fetchRequest:NSFetchRequest<StoredGame> = StoredGame.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedFavoritesListController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "favorites")
        fetchedFavoritesListController.delegate = self
        do {
            try fetchedFavoritesListController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
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

extension FavoritesViewController : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedFavoritesListController.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "gameCell", for: indexPath) as! GameCell
        cell.delegate = self
        let game = fetchedFavoritesListController.object(at: indexPath)
        cell.storedGame = game
        if let imageData = game.image {
            cell.imageView.image = UIImage(data: imageData)
        } else {
            cell.imageView.image = UIImage(named: "no-image")
        }
        cell.setStoredGame(game: game)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width / 2 - 10, height: 250)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? GameCell {
            animatePress(cellView: cell.contentView)
            let game = fetchedFavoritesListController.object(at: indexPath)
            cell.activityIndicator.startAnimating()
            RawgApi.getGameDetails(id: game.id, completion: {response, error in
                cell.activityIndicator.stopAnimating()
                DispatchQueue.main.async {
                    guard let response = response else {
                        self.showToast(message: "Could not connect to server.")
                        return
                    }
                    let gameDetailsVc = self.storyboard?.instantiateViewController(withIdentifier: "details") as! GameDetailsViewController
                    gameDetailsVc.dataController = self.dataController
                    gameDetailsVc.game = response
                    gameDetailsVc.isFavorite = true
                    gameDetailsVc.image = cell.imageView.image
                    self.navigationController?.pushViewController(gameDetailsVc, animated: true)
                }
            })
        }
    }
    
    func animatePress(cellView : UIView) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2,
                           animations: {
                            cellView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                           },
                           completion: { _ in
                            UIView.animate(withDuration: 0.2) {
                                cellView.transform = CGAffineTransform.identity
                            }
                           })
        }
    }
}

extension FavoritesViewController : NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.favoritesCollection.reloadData()
    }
}

extension FavoritesViewController: FavoritesDelegate {
    func addToFavorites(game: Game, imageData: Data?) {
        return
    }
    
    func removeFromFavorites(id: Int32) {
        showToast(message: "Removed from favorites.")
        if let favoritesList = fetchedFavoritesListController.fetchedObjects{
            let favorite = favoritesList.first(where: {$0.id == id})
            if let favorite = favorite {
                dataController.viewContext.delete(favorite)
                try? dataController.viewContext.save()
            }
        }
    }
}
