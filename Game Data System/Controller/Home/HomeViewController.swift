//
//  HomeViewController.swift
//  Game Data System
//
//  Created by Heitor Silveira on 04/10/21.
//

import Foundation
import UIKit
import CoreData

class HomeViewController : UIViewController {
    
    //MARK: Properties
    var dataController : DataController!
    var fetchedFavoritesListController:NSFetchedResultsController<StoredGame>!
    
    var topRatedPage = 1
    var recentlyReleasedPage = 1
    var pcGamesPage = 1
    var playstationGamesPage = 1
    var xboxGamesPage = 1
    var nintendoGamesPage = 1
    
    var topRatedList : [Game] = []
    var recentlyReleasedList: [Game] = []
    var pcGamesList: [Game] = []
    var playstationGamesList : [Game] = []
    var xboxGamesList : [Game] = []
    var nintendoGamesList: [Game] = []
    
    var loadedTopRated: Bool = false
    var loadedRecentlyReleased: Bool = false
    var loadedPcGames: Bool = false
    var loadedPlaystationGames: Bool = false
    var loadedXboxGamesList: Bool = false
    var loadedNintendoGamesList : Bool = false
    
    var imagesDictionary: [Int32:Data] = [:]
    
    
    private enum GameCategories {
        case topMetacritic
        case recentlyReleased
        case pc
        case playstation
        case xbox
        case nintendo
    }
    
    //MARK: Outlets
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var mainContentScrollView: UIScrollView!
    @IBOutlet weak var topRatedCollectionView: UICollectionView!
    @IBOutlet weak var recentlyReleasedCollectionView: UICollectionView!
    @IBOutlet weak var pcGamesCollectionView: UICollectionView!
    @IBOutlet weak var playstationGamesCollectionView: UICollectionView!
    @IBOutlet weak var xboxGamesCollectionView: UICollectionView!
    @IBOutlet weak var nintendoGamesCollectionView: UICollectionView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var tfSearch: UITextField!
    @IBOutlet weak var errorView: UIView!
    
    //MARK: UIViewController Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        setupFetchedFavoritesController()
        fetchHomeGames()
        tfSearch.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.topItem!.title = "GDS"
    }
    
    //MARK: Private Methods
    fileprivate func setupConstraints(){
        stackView.widthAnchor.constraint(equalToConstant: CGFloat(UIScreen.main.bounds.width - 10)).isActive = true
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
    
    fileprivate func fetchHomeGames() {
        loadingView.isHidden = false
        self.errorView.isHidden = true
        mainContentScrollView.isHidden = true
        
        RawgApi.getTopMetacriticGames(page: topRatedPage, completion: {response, error in
            self.handleGamesResponse(category: .topMetacritic, gamesListResponse: response, error: error)
        })
        RawgApi.getRecentReleasedGames(page: recentlyReleasedPage, completion: {response, error in self.handleGamesResponse(category: .recentlyReleased, gamesListResponse: response, error: error)
        })
        RawgApi.getPcGames(page: pcGamesPage, completion: {response, error in self.handleGamesResponse(category: .pc, gamesListResponse: response, error: error)
        })
        RawgApi.getPlaystationGames(page: playstationGamesPage, completion: {response, error in
            self.handleGamesResponse(category: .playstation, gamesListResponse: response, error: error)
        })
        RawgApi.getXboxGames(page: xboxGamesPage, completion: {response, error in
            self.handleGamesResponse(category: .xbox, gamesListResponse: response, error: error)
        })
        RawgApi.getNintendoGames(page: nintendoGamesPage, completion: {response, error in
            self.handleGamesResponse(category: .nintendo, gamesListResponse: response, error: error)
        })
    }
    
    private func handleGamesResponse(category: GameCategories, gamesListResponse : GetGamesListResponse?, error: Error?) {
        guard let gamesListResponse = gamesListResponse else {
            self.loadingView.isHidden = true
            self.mainContentScrollView.isHidden = true
            self.errorView.isHidden = false
            return
        }
        switch category {
        case .topMetacritic:
            self.loadedTopRated = true
            self.topRatedList.append(contentsOf: gamesListResponse.results)
            self.topRatedCollectionView.reloadData()
            break
        case .recentlyReleased:
            self.loadedRecentlyReleased = true
            self.recentlyReleasedList.append(contentsOf: gamesListResponse.results)
            self.recentlyReleasedCollectionView.reloadData()
            break
        case.pc:
            self.loadedPcGames = true
            self.pcGamesList.append(contentsOf: gamesListResponse.results)
            self.pcGamesCollectionView.reloadData()
            break
        case .playstation:
            self.loadedPlaystationGames = true
            self.playstationGamesList.append(contentsOf: gamesListResponse.results)
            self.playstationGamesCollectionView.reloadData()
        case .xbox:
            self.loadedXboxGamesList = true
            self.xboxGamesList.append(contentsOf: gamesListResponse.results)
            self.xboxGamesCollectionView.reloadData()
        case .nintendo:
            self.loadedNintendoGamesList = true
            self.nintendoGamesList.append(contentsOf: gamesListResponse.results)
            self.nintendoGamesCollectionView.reloadData()
        }
        
        if loadedPcGames, loadedTopRated, loadedRecentlyReleased, loadedPlaystationGames, loadedXboxGamesList {
            self.errorView.isHidden = true
            self.loadingView.isHidden = true
            self.mainContentScrollView.isHidden = false
        }
    }
    
    private func checkIsFavorite(id: Int32) -> Bool{
        if let favoritesList = fetchedFavoritesListController.fetchedObjects {
            return favoritesList.contains(where: {$0.id == id})
        }
        return false
    }
    
    @objc private func fetchNextPage(sender: UIButton){
        switch HomeCollectionViews(rawValue: sender.tag){
        case .TopRated:
            self.topRatedPage += 1
            RawgApi.getTopMetacriticGames(page: self.topRatedPage, completion: {
                response, error in
                self.handleGamesResponse(category: .topMetacritic, gamesListResponse: response, error: error)
            })
            break
        case .RecentlyReleased:
            self.recentlyReleasedPage += 1
            RawgApi.getRecentReleasedGames(page: self.recentlyReleasedPage, completion: {
                response, error in
                self.handleGamesResponse(category: .recentlyReleased, gamesListResponse: response, error: error)
            })
            break
        case .PcGames:
            self.pcGamesPage += 1
            RawgApi.getPcGames(page: self.pcGamesPage, completion: {
                response, error in
                self.handleGamesResponse(category: .pc, gamesListResponse: response, error: error)
            })
            break
        case .PlaystationGames:
            self.playstationGamesPage += 1
            RawgApi.getPlaystationGames(page: self.playstationGamesPage, completion: {
                response, error in
                self.handleGamesResponse(category: .playstation, gamesListResponse: response, error: error)
            })
            break
        case .XboxGames:
            self.xboxGamesPage += 1
            RawgApi.getXboxGames(page: self.xboxGamesPage, completion: {
                response, error in
                self.handleGamesResponse(category: .xbox, gamesListResponse: response, error: error)
            })
            break
        case .NintendoGames:
            self.nintendoGamesPage += 1
            RawgApi.getNintendoGames(page: nintendoGamesPage, completion: {response, error in
                self.handleGamesResponse(category: .nintendo, gamesListResponse: response, error: error)
            })
        default:
            break
        }
    }
    
    //MARK: Presenters
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
    @IBAction func handleRetryConnection(_ sender: Any) {
        self.fetchHomeGames()
    }
}

//MARK: UICollectionView Data Source and Delegate Extension
extension HomeViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    private enum HomeCollectionViews : Int {
        case TopRated = 0
        case RecentlyReleased = 1
        case PcGames = 2
        case PlaystationGames = 3
        case XboxGames = 4
        case NintendoGames = 5
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch HomeCollectionViews(rawValue: collectionView.tag){
        case .TopRated:
            return topRatedList.count
        case .RecentlyReleased:
            return recentlyReleasedList.count
        case .PcGames:
            return pcGamesList.count
        case .PlaystationGames:
            return playstationGamesList.count
        case .XboxGames:
            return xboxGamesList.count
        case .NintendoGames:
            return nintendoGamesList.count
        default:
            return 0
        }
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
        switch HomeCollectionViews(rawValue: collectionView.tag) {
        case .TopRated:
            let game = self.topRatedList[indexPath.item]
            cell.setGame(game: game, isFavorite: checkIsFavorite(id: game.id))
            setImage(game, cell)
            break
        case .RecentlyReleased:
            let game = self.recentlyReleasedList[indexPath.item]
            cell.setGame(game: game, isFavorite:  checkIsFavorite(id: game.id))
            setImage(game, cell)
            break
        case .PcGames:
            let game = self.pcGamesList[indexPath.item]
            cell.setGame(game: game, isFavorite:  checkIsFavorite(id: game.id))
            setImage(game, cell)
            break
        case .PlaystationGames:
            let game = self.playstationGamesList[indexPath.item]
            cell.setGame(game: game, isFavorite:  checkIsFavorite(id: game.id))
            setImage(game, cell)
        case .XboxGames:
            let game = self.xboxGamesList[indexPath.item]
            cell.setGame(game: game, isFavorite:  checkIsFavorite(id: game.id))
            setImage(game, cell)
        case .NintendoGames:
            let game = self.nintendoGamesList[indexPath.item]
            cell.setGame(game: game, isFavorite:  checkIsFavorite(id: game.id))
            setImage(game, cell)
        default:
            break
        }
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "footer", for: indexPath) as! GamesListFooter
        footer.btLoadMore.addTarget(self, action: #selector(fetchNextPage(sender:)), for: .touchUpInside)
        return footer
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? GameCell else {
            return
        }
        animatePress(cellView: cell.contentView)
        var game : Game
        switch HomeCollectionViews(rawValue: collectionView.tag){
        case .TopRated:
            game = self.topRatedList[indexPath.item]
            break
        case .RecentlyReleased:
            game = self.recentlyReleasedList[indexPath.item]
            break
        case .PcGames:
            game = self.pcGamesList[indexPath.item]
            break
        case .PlaystationGames:
            game = self.playstationGamesList[indexPath.item]
        case .XboxGames:
            game = self.xboxGamesList[indexPath.item]
        case .NintendoGames:
            game = self.nintendoGamesList[indexPath.item]
        default:
            game = self.topRatedList[indexPath.item]
        }
        cell.activityIndicator.startAnimating()
        RawgApi.getGameDetails(id: game.id, completion: {response, error in
            DispatchQueue.main.async {
                cell.activityIndicator.stopAnimating()
                guard let response = response else {
                    self.mainContentScrollView.isHidden = true
                    self.errorView.isHidden = false
                    return
                }
                let gameDetailsVc = self.storyboard?.instantiateViewController(withIdentifier: "details") as! GameDetailsViewController
                gameDetailsVc.dataController = self.dataController
                gameDetailsVc.game = response
                gameDetailsVc.isFavorite = self.checkIsFavorite(id: game.id)
                gameDetailsVc.image = cell.imageView.image
                self.navigationController?.pushViewController(gameDetailsVc, animated: true)
            }
        })
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

extension HomeViewController : FavoritesDelegate {
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

//MARK: NSFetchedResultsControllerDelegate Extension
extension HomeViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.topRatedCollectionView.reloadData()
        self.pcGamesCollectionView.reloadData()
        self.recentlyReleasedCollectionView.reloadData()
        self.playstationGamesCollectionView.reloadData()
        self.xboxGamesCollectionView.reloadData()
        self.nintendoGamesCollectionView.reloadData()
    }
}

extension HomeViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = tfSearch.text, text != "" {
            let searchVc = storyboard?.instantiateViewController(withIdentifier: "search") as! SearchViewController
            searchVc.searchQuery = text
            searchVc.dataController = self.dataController
            navigationController?.pushViewController(searchVc, animated: true)
            textField.text = ""
        }
        textField.resignFirstResponder()
        return true
    }
}
