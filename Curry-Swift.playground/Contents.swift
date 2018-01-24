//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

struct Artist {
    let id: Int
    let name: String
    let gender: String
    let albums: [Album]?
    
    static func create(id: Int) -> (String) -> (String) -> ([Album]?) -> Artist {
        return { name in
            return { gender in
                return { album in
                    Artist(id: id, name: name, gender: gender, albums: album)
                }
            }
        }
    }
}

struct Album {
    let id: Int
    let name: String
    let copyright: String
    let gender: String
    let image: String
    
    static func create(id: Int) -> (String) -> (String) -> (String) -> (String) -> Album {
        return { name in
            return { copyright in
                return { gender in
                    return { image in
                        Album(id: id, name: name, copyright: copyright, gender: gender, image: image)
                    }
                }
            }
        }
    }
}


func fetchBestAlbumsOf(artist: String, completion: @escaping (_ artist: Artist) -> Void) {
   
    if let url = URL(string: "https://itunes.apple.com/lookup?id=" + artist + "&entity=album&limit=5") {
        
        let urlRequest = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: urlRequest, completionHandler: { data, response, error in
            do {
                
                if let error = error {
                    throw error
                }
                
                if let data = data,
                    let jsonDictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                    let results = jsonDictionary["results"] as? [[String: Any]] {
                    
                    let artistDict = results.filter { $0["artistType"] as? String == "Artist" }.first
                    
                    guard let artistDictionary = artistDict,
                          let itemType = artistDictionary["artistType"] as? String, itemType == "Artist",
                          let id = artistDictionary["artistId"] as? Int,
                          let name = artistDictionary["artistName"] as? String,
                          let gender = artistDictionary["primaryGenreName"] as? String else {
                            return
                    }
                    
                    let artist = Artist.create(id: id)(name)(gender)
                    
                    let albumsArray = results.filter { $0["collectionType"] as? String == "Album" }
                    
                    let albums: [Album] = albumsArray.flatMap {
                        
                        guard let id = $0["collectionId"] as? Int,
                              let name = $0["collectionName"] as? String,
                              let copyright = $0["copyright"] as? String,
                              let gender = $0["primaryGenreName"] as? String,
                              let image = $0["artworkUrl100"] as? String else {
                                return nil
                        }
                        
                        return Album.create(id: id)(name)(copyright)(gender)(image)
                    }
                    
                    completion(artist(albums))
                }
            } catch let error {
                print(error)
            }
        })
        task.resume()
    }
}

fetchBestAlbumsOf(artist: "178834") { print($0) }

fetchBestAlbumsOf(artist: "462006") { print($0) }


