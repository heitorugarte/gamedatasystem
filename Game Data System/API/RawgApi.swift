//
//  RawgApi.swift
//  Game Data System
//
//  Created by Heitor Silveira on 04/10/21.
//

import Foundation

class RawgApi {
    struct Defaults {
        static var pageSize = 15
    }
    
    struct Auth {
        static var apiKey = "d1627592d05d483b863e8e875ac20da9"
    }
    
    enum Endpoints {
        static let base = "https://api.rawg.io/api"
        static let keyParameter = "key=\(Auth.apiKey)"
        
        case getGamesList
        case getTopMetacriticGames(page: Int, pageSize: Int)
        case getRecentReleasedGames(page: Int, pageSize: Int)
        case getPcGames(page: Int, pageSize: Int)
        case getPlaystationGames(page: Int, pageSize: Int)
        case getXboxGames(page: Int, pageSize: Int)
        case getNintendoGames(page: Int, pageSize: Int)
        case searchGame(page: Int, pageSize: Int, searchQuery: String)
        case getGameDetails(id: Int32)
        
        var stringValue : String {
            switch self {
            case .getGamesList: return "\(Endpoints.base)/games"
            case .getTopMetacriticGames(let page, let pageSize): return "\(Endpoints.getGamesList.stringValue)?ordering=-metacritic&page=\(page)&page_size=\(pageSize)&\(Endpoints.keyParameter)"
            case .getRecentReleasedGames(let page, let pageSize): return "\(Endpoints.getGamesList.stringValue)?ordering=-released&page=\(page)&page_size=\(pageSize)&\(Endpoints.keyParameter)"
            case .getPcGames(let page, let pageSize): return "\(Endpoints.getGamesList.stringValue)?platforms=4&page=\(page)&page_size=\(pageSize)&\(Endpoints.keyParameter)"
            case .getPlaystationGames(let page, let pageSize): return "\(Endpoints.getGamesList.stringValue)?platforms=187,18&page=\(page)&page_size=\(pageSize)&\(Endpoints.keyParameter)"
            case .getXboxGames(let page, let pageSize): return "\(Endpoints.getGamesList.stringValue)?platforms=1,186,14&page=\(page)&page_size=\(pageSize)&\(Endpoints.keyParameter)"
            case .getNintendoGames(let page, let pageSize): return "\(Endpoints.getGamesList.stringValue)?platforms=7,8,9,13&page=\(page)&page_size=\(pageSize)&\(Endpoints.keyParameter)"
            case .searchGame(let page, let pageSize, let searchQuery): return "\(Endpoints.getGamesList.stringValue)?search=\(searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&page=\(page)&page_size=\(pageSize)&\(Endpoints.keyParameter)"
            case .getGameDetails(let id): return "\(Endpoints.getGamesList.stringValue)/\(id)?\(Endpoints.keyParameter)"
            }
        }
        
        
        var url : URL {
            return URL(string: self.stringValue)!
        }
    }
    
    class func taskForGetRequest<ResponseType : Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) {
        print(url)
        let task = URLSession.shared.dataTask(with: url) {
            data, response, error in
            guard let data = data else {
                completion(nil, error)
                return
            }
            let decoder = JSONDecoder()
            do {
                let response = try decoder.decode(responseType, from: data)
                completion(response, nil)
            } catch {
                completion(nil, error)
            }
        }
        task.resume()
    }
    
    class func getTopMetacriticGames(page: Int, pageSize: Int = Defaults.pageSize, completion: @escaping (GetGamesListResponse?, Error?) -> Void) {
        taskForGetRequest(url: Endpoints.getTopMetacriticGames(page: page, pageSize: pageSize).url, responseType: GetGamesListResponse.self, completion: {data, error in
            DispatchQueue.main.async {
                guard let data = data else {
                    completion(nil, error)
                    return
                }
                completion(data, nil)
            }
        })
    }
    
    class func getRecentReleasedGames(page: Int, pageSize: Int = Defaults.pageSize, completion: @escaping (GetGamesListResponse?, Error?) -> Void) {
        taskForGetRequest(url: Endpoints.getRecentReleasedGames(page: page, pageSize: pageSize).url, responseType: GetGamesListResponse.self, completion: {data, error in
            DispatchQueue.main.async {
                guard let data = data else {
                    completion(nil, error)
                    return
                }
                completion(data, nil)
            }
        })
    }
    
    class func getPcGames(page: Int, pageSize: Int = Defaults.pageSize, completion: @escaping (GetGamesListResponse?, Error?) -> Void) {
        taskForGetRequest(url: Endpoints.getPcGames(page: page, pageSize: pageSize).url, responseType: GetGamesListResponse.self, completion: {data, error in
            DispatchQueue.main.async {
                guard let data = data else {
                    completion(nil, error)
                    return
                }
                completion(data, nil)
            }
        })
    }
    
    class func getPlaystationGames(page: Int, pageSize: Int = Defaults.pageSize, completion: @escaping (GetGamesListResponse?, Error?) -> Void) {
        taskForGetRequest(url: Endpoints.getPlaystationGames(page: page, pageSize: pageSize).url, responseType: GetGamesListResponse.self, completion: {data, error in
            DispatchQueue.main.async {
                guard let data = data else {
                    completion(nil, error)
                    return
                }
                completion(data, nil)
            }
        })
    }
    
    class func getXboxGames(page: Int, pageSize: Int = Defaults.pageSize, completion: @escaping (GetGamesListResponse?, Error?) -> Void) {
        taskForGetRequest(url: Endpoints.getXboxGames(page: page, pageSize: pageSize).url, responseType: GetGamesListResponse.self, completion: {data, error in
            DispatchQueue.main.async {
                guard let data = data else {
                    completion(nil, error)
                    return
                }
                completion(data, nil)
            }
        })
    }
    
    class func getNintendoGames(page: Int, pageSize: Int = Defaults.pageSize, completion: @escaping (GetGamesListResponse?, Error?) -> Void){
        taskForGetRequest(url: Endpoints.getNintendoGames(page: page, pageSize: pageSize).url, responseType: GetGamesListResponse.self, completion: {data, error in
            DispatchQueue.main.async {
                guard let data = data else {
                    completion(nil, error)
                    return
                }
                completion(data, nil)
            }
        })
    }
    
    class func searchGame(page: Int, pageSize: Int = Defaults.pageSize, searchQuery: String, completion: @escaping (GetGamesListResponse?, Error?) -> Void){
        taskForGetRequest(url: Endpoints.searchGame(page: page, pageSize: pageSize, searchQuery: searchQuery).url, responseType: GetGamesListResponse.self, completion: {data, error in
            DispatchQueue.main.async {
                guard let data = data else {
                    completion(nil, error)
                    return
                }
                completion(data, nil)
            }
        })
    }
    
    class func getGameDetails(id: Int32, completion: @escaping (GameDetailsResponse?, Error?) -> Void){
        taskForGetRequest(url: Endpoints.getGameDetails(id: id).url, responseType: GameDetailsResponse.self, completion: {data, error in
            DispatchQueue.main.async {
                guard let data = data else {
                    completion(nil, error)
                    return
                }
                completion(data, nil)
            }
        })
    }
    
    class func downloadImage(urlString: String, completion: @escaping (Data?, Error?) -> Void){
        let downloadQueue = DispatchQueue(label: "download")
        downloadQueue.async {
            let url = URL(string: urlString)!
            URLSession.shared.dataTask(with: url) {
                data, response, error in
                guard let data = data else {
                    completion(nil, error)
                    return
                }
                completion(data, error)
            }.resume()
        }
    }
}
