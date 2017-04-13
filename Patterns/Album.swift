//
//  Album.swift
//  Patterns
//
//  Created by Ozal Suleyman on 4/13/17.
//  Copyright © 2017 Ozal Suleyman. All rights reserved.
//



import UIKit

// DATA ENCODING OBJECT

class Album: NSObject, NSCoding {
    
    var title : String!
    var artist : String!
    var genre : String!
    var coverUrl : String!
    var year : String!
    
    init(title: String, artist: String, genre: String, coverUrl: String, year: String) {
        super.init()
        self.title = title
        self.artist = artist
        self.genre = genre
        self.coverUrl = coverUrl
        self.year = year
    }
    
    override var description: String {
        return "title: \(title)" +
            "artist: \(artist)" +
            "genre: \(genre)" +
            "coverUrl: \(coverUrl)" +
            "year: \(year)"
    }
    
    // UNARCHIVE DATA
    required init(coder decoder: NSCoder) {
        super.init()
        self.title = decoder.decodeObjectForKey("title") as! String
        self.artist = decoder.decodeObjectForKey("artist") as! String
        self.genre = decoder.decodeObjectForKey("genre") as! String
        self.coverUrl = decoder.decodeObjectForKey("cover_url") as! String
        self.year = decoder.decodeObjectForKey("year") as! String
    }
    
    // ARCHIVE DATA
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(title, forKey: "title")
        aCoder.encodeObject(artist, forKey: "artist")
        aCoder.encodeObject(genre, forKey: "genre")
        aCoder.encodeObject(coverUrl, forKey: "cover_url")
        aCoder.encodeObject(year, forKey: "year")
    }
    
}
