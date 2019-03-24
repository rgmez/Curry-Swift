import Foundation

public struct ResultModel: Codable {
    public let resultCount: Int
    public let results: [ArtistData]
    
    enum CodingKeys: String, CodingKey {
        case resultCount = "resultCount"
        case results = "results"
    }
}

public struct ArtistData: Codable {
    public let wrapperType: String?
    public let artistType: String?
    public let artistName: String?
    public let artistLinkURL: String?
    public let artistID: Int?
    public let amgArtistID: Int?
    public let primaryGenreName: String?
    public let primaryGenreID: Int?
    public let collectionType: String?
    public let collectionID: Int?
    public let collectionName: String?
    public let collectionCensoredName: String?
    public let artistViewURL: String?
    public let collectionViewURL: String?
    public let artworkUrl60: String?
    public let artworkUrl100: String?
    public let collectionPrice: Double?
    public let collectionExplicitness: String?
    public let trackCount: Int?
    public let copyright: String?
    public let country: String?
    public let currency: String?
    public let releaseDate: String?
    public let contentAdvisoryRating: String?
    
    enum CodingKeys: String, CodingKey {
        case wrapperType = "wrapperType"
        case artistType = "artistType"
        case artistName = "artistName"
        case artistLinkURL = "artistLinkUrl"
        case artistID = "artistId"
        case amgArtistID = "amgArtistId"
        case primaryGenreName = "primaryGenreName"
        case primaryGenreID = "primaryGenreId"
        case collectionType = "collectionType"
        case collectionID = "collectionId"
        case collectionName = "collectionName"
        case collectionCensoredName = "collectionCensoredName"
        case artistViewURL = "artistViewUrl"
        case collectionViewURL = "collectionViewUrl"
        case artworkUrl60 = "artworkUrl60"
        case artworkUrl100 = "artworkUrl100"
        case collectionPrice = "collectionPrice"
        case collectionExplicitness = "collectionExplicitness"
        case trackCount = "trackCount"
        case copyright = "copyright"
        case country = "country"
        case currency = "currency"
        case releaseDate = "releaseDate"
        case contentAdvisoryRating = "contentAdvisoryRating"
    }
}
