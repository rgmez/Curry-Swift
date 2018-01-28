//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

enum Genders: String {
    case rock = "Rock"
    case pop = "Pop"
}

enum Singers: String {
    case elvis_presley = "197443"
    case bruce_springsteen = "178834"
    case bob_dylan = "462006"
    case frank_sinatra = "171366"
    case beyonce = "1419227"
    case freddie_mercury = "3915743"
    case michael_jackson = "32940"
}

struct Artist {
    let id: Int
    let name: String
    let gender: String
    let albums: [Album]?
    
    static func create(gender: String) -> (String) -> (Int) -> ([Album]?) -> Artist {
        return { name in
            return { id in
                return { album in
                    Artist(id: id, name: name, gender: gender, albums: album)
                }
            }
        }
    }
    
    func printArtist() {
        print("Name:\(name), Gender:\(gender)")
        print("Albums:")
        albums?.forEach{ $0.printAlbum() }
    }
}

struct Album {
    let id: Int
    let name: String
    let copyright: String
    let gender: String
    let image: String
    
    static func create(gender: String) -> (Int) -> (String) -> (String) -> (String) -> Album {
        return { id in
            return { name in
                return { copyright in
                    return { image in
                        Album(id: id, name: name, copyright: copyright, gender: gender, image: image)
                    }
                }
            }
        }
    }
    
    func printAlbum() {
        print("   \(name), \(gender), \(copyright)")
    }
}

let createRockArtist = Artist.create(gender: Genders.rock.rawValue)
let createPopArtist = Artist.create(gender: Genders.pop.rawValue)
let createRockAlbum = Album.create(gender: Genders.rock.rawValue)
let createPopAlbum = Album.create(gender: Genders.pop.rawValue)

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
                    
                    let artist = gender == Genders.rock.rawValue ? createRockArtist(name)(id) : createPopArtist(name)(id)
                    let albums = getAlbums(albumsArray: results.filter{ $0["collectionType"] as? String == "Album" } as [[String : AnyObject]])
                    
                    completion(artist(albums))
                }
            } catch let error {
                print(error)
            }
        })
        task.resume()
    }
}

func getAlbums(albumsArray: [[String: AnyObject]]) -> [Album]? {
    return albumsArray.flatMap {
        
        guard let id = $0["collectionId"] as? Int,
            let name = $0["collectionName"] as? String,
            let copyright = $0["copyright"] as? String,
            let gender = $0["primaryGenreName"] as? String,
            let image = $0["artworkUrl100"] as? String else {
                return nil
        }
        
        return gender == Genders.rock.rawValue ? createRockAlbum(id)(name)(copyright)(image) : createPopAlbum(id)(name)(copyright)(image)
    }
}

fetchBestAlbumsOf(artist: Singers.bruce_springsteen.rawValue) { $0.printArtist() }
fetchBestAlbumsOf(artist: Singers.bob_dylan.rawValue) { $0.printArtist() }
fetchBestAlbumsOf(artist: Singers.beyonce.rawValue) { $0.printArtist() }
fetchBestAlbumsOf(artist: Singers.elvis_presley.rawValue) { $0.printArtist() }
fetchBestAlbumsOf(artist: Singers.frank_sinatra.rawValue) { $0.printArtist() }
fetchBestAlbumsOf(artist: Singers.freddie_mercury.rawValue) { $0.printArtist() }
fetchBestAlbumsOf(artist: Singers.michael_jackson.rawValue) { $0.printArtist() }
