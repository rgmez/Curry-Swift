
import UIKit
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

// FIRST EXAMPLE - We want to set image in UIImageView from URL:

var imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 300, height: 200))

func getImageFrom(_ url: URL) {
    guard let data = try? Data(contentsOf: url) else {
        return
    }
    imageView.image = UIImage(data: data)
}

func getCurryingImageFrom(_ url: URL) -> () -> () {
    return {
        guard let data = try? Data(contentsOf: url) else {
            return
        }
        imageView.image = UIImage(data: data)
    }
}

func downloadImageFrom(urlString: String) {
    
    guard let url = URL(string: urlString) else { return }
    
    let op = Operation()
    
    op.completionBlock = getCurryingImageFrom(url)
    
    op.start()
}

downloadImageFrom(urlString: "http://gomotors.net/pics/Suzuki/suzuki-swift-xg-01.jpg")

//SECOND EXAMPLE: We want to retrieve top 5 albums of some singers.

enum Genders: String {
    case rock = "Rock"
    case pop = "Pop"
}

enum Singers: Int {
    case elvis_presley = 197443
    case bruce_springsteen = 178834
    case bob_dylan = 462006
    case frank_sinatra = 171366
    case beyonce = 1419227
    case freddie_mercury = 3915743
    case michael_jackson = 32940
    
    func singerName() -> String {
        switch self {
        case .elvis_presley:
            return "Elvis Presley"
        case .bruce_springsteen:
            return "Bruce Springsteen"
        case .bob_dylan:
            return "Bob Dylan"
        case .frank_sinatra:
            return "Frank Sinatra"
        case .beyonce:
            return "Beyonce"
        case .freddie_mercury:
            return "Freddie Mercury"
        case .michael_jackson:
            return "Michael Jackson"
        }
    }
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
        print("\(String(describing: name)), Gender:\(String(describing: gender))")
        print("Best Albums:")
        albums?.forEach{ $0.printAlbum() }
        print("\n")
    }
}

struct Album {
    let id: Int
    let name: String
    let copyright: String
    let gender: String
    let image: String?
    
    static func create(gender: String) -> (Int) -> (String) -> (String) -> (String?) -> Album {
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
        print("   - \(String(describing: name)), \(String(describing: gender)), \(String(describing: copyright))")
    }
}

// We can save Artist's and Album's gender data to create generic rock/pop artists and albums
let createRockArtist = Artist.create(gender: Genders.rock.rawValue)
let createPopArtist = Artist.create(gender: Genders.pop.rawValue)
let createRockAlbum = Album.create(gender: Genders.rock.rawValue)
let createPopAlbum = Album.create(gender: Genders.pop.rawValue)

func fetchBestAlbumsOf(artist: Int, completion: @escaping (_ artist: Artist) -> Void) {
   
    if let url = URL(string: "https://itunes.apple.com/lookup?id=" + String(artist) + "&entity=album&limit=5") {
    
        URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, error in
        
            guard let data = data,
                let resultModel = try? JSONDecoder().decode(ResultModel.self, from: data),
                let first = resultModel.results.first,
                let itemType = first.artistType,
                itemType == "Artist",
                let id = first.artistID,
                let name = first.artistName,
                let gender = first.primaryGenreName else {
                    if let error = error {
                        print(error)
                    }
                    return
            }
            
            let artist =
                gender == Genders.rock.rawValue ?
                    createRockArtist(name)(id) : createPopArtist(name)(id)
            let albums =
                getAlbums(albumsArray:
                    resultModel.results.filter { $0.collectionType == "Album" })
            
            completion(artist(albums))
        }.resume()
    }
}

func getAlbums(albumsArray: [ArtistData]) -> [Album]? {
    return albumsArray.compactMap {
        
        guard let id = $0.collectionID,
            let name = $0.collectionName,
            let copyright = $0.copyright,
            let gender = $0.primaryGenreName,
            let image = $0.artworkUrl100 else {
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

// We can save the Springsteen's data we already know (name, id) and use createRockArtist because Bruce Springsteen is a Rock Singer
let createSpringsteen = createRockArtist(Singers.bruce_springsteen.singerName())
let createSpringsteenArtist = createSpringsteen(Singers.bruce_springsteen.rawValue)

func fetchBruceSpringsteenAllAlbums(completion: @escaping (_ artist: Artist) -> Void) {
    
    if let url = URL(string: "https://itunes.apple.com/lookup?id=" + String(Singers.bruce_springsteen.rawValue) + "&entity=album") {

        URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, error in
            
            guard let data = data,
                let resultModel = try? JSONDecoder().decode(ResultModel.self, from: data) else {
                    
                    if let error = error {
                        print(error)
                    }
                    return
            }
            
            let albums = getAlbums(albumsArray: resultModel.results.filter{ $0.collectionType == "Album" })
            
            // Add Albums to Springsteen's data.
            completion(createSpringsteenArtist(albums))
            
        }.resume()
    }
}

fetchBruceSpringsteenAllAlbums { artist in
    print(artist)
}
