//
//  SearchViewController.swift
//  Game Data System
//
//  Created by Heitor Silveira on 06/10/21.
//

import Foundation
import UIKit
import CoreData

class SearchViewController : UIViewController {
    
    //MARK: Properties
    var dataController : DataController!
    var fetchedFavoritesListController:NSFetchedResultsController<StoredGame>!
    
    var searchQuery: String!
    
    var searchResultsList: [Game] = []
    var imagesDictionary: [Int32:Data] = [:]
    
    var page = 1
    
    var loading: Bool = false
    
    //MARK: Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tfSearch: UITextField!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var resultLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFetchedFavoritesController()
        tfSearch.delegate = self
        self.tfSearch.text = searchQuery
        self.resultLabel.isHidden = true
        self.collectionView.isHidden = true
        self.loadingView.isHidden = false
        self.activityIndicator.startAnimating()
        RawgApi.searchGame(page: page, searchQuery: searchQuery, completion:  {response, error in self.handleSearchResponse(response: response, error: error, appendResults: false)})
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    func searchGame(appendResult: Bool) {
        if let text = tfSearch.text {
            if !appendResult {
                self.resultLabel.isHidden = true
                self.collectionView.isHidden = true
                self.loadingView.isHidden = false
                self.activityIndicator.startAnimating()
            } else {
                showToast(message: "Loading...")
            }
            RawgApi.searchGame(page: page, searchQuery: text, completion: {response, error in self.handleSearchResponse(response: response, error: error, appendResults: appendResult)})
        }
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
    
    private func handleSearchResponse(response : GetGamesListResponse?, error: Error?, appendResults: Bool) {
        self.loading = false
        
        if !appendResults {
            self.activityIndicator.stopAnimating()
            self.loadingView.isHidden = true
            self.collectionView.isHidden = false
        }
        
        guard let response = response else {
            if let error = error?.localizedDescription, error.localizedStandardContains("offline")  || error.localizedStandardContains( "Could not connect to the server") {    self.resultLabel.isHidden = false
                self.resultLabel.text = "Could not connect to server."
                self.collectionView.isHidden = true
            } else {
                if appendResults{return}
                self.searchResultsList = []
                self.collectionView.isHidden = true
                self.resultLabel.text = "No games found."
                self.resultLabel.isHidden = false
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
            return
        }
        self.resultLabel.isHidden = true
        if !appendResults{
            self.searchResultsList = response.results
        } else {
            self.searchResultsList.append(contentsOf: response.results)
        }
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    private func checkIsFavorite(game: Game) -> Bool{
        if let favoritesList = fetchedFavoritesListController.fetchedObjects {
            return favoritesList.contains(where: {$0.id == game.id})
        }
        return false
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

extension SearchViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.collectionView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        self.page = 1
        searchGame(appendResult: false)
        return true
    }
}

extension SearchViewController : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > scrollView.contentSize.height / 2, !self.loading {
            self.loading = true
            self.page += 1
            searchGame(appendResult: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        searchResultsList.count
    }
    
    private func setImage(_ game: Game, _ cell: GameCell) {
        if let gameImageData = self.imagesDictionary[game.id] {
            cell.imageView.image = UIImage(data: gameImageData)
        } else if let imageUrlString = game.backgroundImage {
            cell.imageView.image = nil
            cell.activityIndicator.isHidden = false
            cell.activityIndicator.startAnimating()
            RawgApi.downloadImage(urlString: imageUrlString, completion: {imageData, error in
                guard let imageData = imageData else {
                    return
                }
                DispatchQueue.main.async {
                    cell.activityIndicator.stopAnimating()
                    self.imagesDictionary[game.id] = imageData
                    cell.imageView.image = UIImage(data: imageData)
                }
            })
        } else {
            cell.imageView.image = UIImage(named: "no-image")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "gameCell", for: indexPath) as! GameCell
        cell.delegate = self
        let game = self.searchResultsList[indexPath.item]
        cell.setGame(game: game, isFavorite: checkIsFavorite(game: game))
        setImage(game, cell)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width / 2 - 20, height: 250)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? GameCell {
            animatePress(cellView: cell.contentView)
            let game = self.searchResultsList[indexPath.item]
            RawgApi.getGameDetails(id: game.id, completion: {response, error in
                DispatchQueue.main.async {
                    guard let response = response else {
                        self.showToast(message: "Could not fetch game details!")
                        return
                    }
                    let gameDetailsVc = self.storyboard?.instantiateViewController(withIdentifier: "details") as! GameDetailsViewController
                    gameDetailsVc.dataController = self.dataController
                    gameDetailsVc.game = response
                    gameDetailsVc.isFavorite = self.checkIsFavorite(game: game)
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

extension SearchViewController : FavoritesDelegate {
    func addToFavorites(game: Game, imageData: Data?) {
        let newFavorite = StoredGame(context: dataController.viewContext)
        newFavorite.id = game.id
        newFavorite.name = game.name
        newFavorite.slug = game.slug
        newFavorite.metacritic = Int32(game.metacritic ?? 0)
        if let imageData = imageData {
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
        showToast(message: "Added to favorites.")
    }
    
    func removeFromFavorites(id: Int32) {
        if let favoritesList = fetchedFavoritesListController.fetchedObjects{
            let favorite = favoritesList.first(where: {$0.id == id})
            if let favorite = favorite {
                dataController.viewContext.delete(favorite)
                showToast(message: "Removed from favorites.")
                try? dataController.viewContext.save()
            }
        }
    }
}

extension SearchViewController : NSFetchedResultsControllerDelegate  {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.collectionView.reloadData()
    }
}
