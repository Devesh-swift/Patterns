//
//  PersistencyManager.swift
//  Patterns
//
//  Created by Ozal Suleyman on 4/13/17.
//  Copyright © 2017 Ozal Suleyman. All rights reserved.
//


import UIKit

class PersistencyManager: NSObject {
    private var albums = [Album]()
    
    override init() {
        super.init()
        if let data = NSData(contentsOfFile: NSHomeDirectory().stringByAppendingString("/Documents/albums.bin")) {
            let unarchiveAlbums = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! [Album]?
            if let unwrappedAlbum = unarchiveAlbums {
                albums = unwrappedAlbum
            }
        } else {
            createPlaceholderAlbum()
        }
    }
    
    
    func createPlaceholderAlbum() {
        // Dummy list of albums
        let album1 = Album(title: "Best of Bowie",
                           artist: "David Bowie",
                           genre: "Pop",
                           coverUrl: "http://ecx.images-amazon.com/images/I/71mN40uEXqL._SL1300_.jpg",
                           year: "1992")
        
        let album2 = Album(title: "It's My Life",
                           artist: "No Doubt",
                           genre: "Pop",
                           coverUrl: "http://ecx.images-amazon.com/images/I/41N61BE5Z0L.jpg",
                           year: "2003")
        
        let album3 = Album(title: "Nothing Like The Sun",
                           artist: "Sting",
                           genre: "Pop",
                           coverUrl: "http://images.rapgenius.com/703e0f544b15eacf31ae05badc8d1ff7.953x953x1.jpg",
                           year: "1999")
        
        let album4 = Album(title: "Staring at the Sun",
                           artist: "U2",
                           genre: "Pop",
                           coverUrl: "http://media.u2.com/non_secure/images/20090218/discography/staring_at_the_sun2/600.jpg",
                           year: "2000")
        
        let album5 = Album(title: "American Pie",
                           artist: "Madonna",
                           genre: "Pop",
                           coverUrl: "https://upload.wikimedia.org/wikipedia/en/c/c0/Don_McLean_-_American_Pie_(album)_Coverart.png",
                           year: "2000")
        
        albums = [album1, album2, album3, album4, album5]
        saveAlbums()
    }
    
    func getAlbums() -> [Album] {
        return albums
    }
    
    func addAlbum(album: Album, index: Int) {
        if (albums.count >= index) {
            albums.insert(album, atIndex: index)
        } else {
            albums.append(album)
        }
    }
    
    func deleteAlbumAtIndex(index: Int) {
        albums.removeAtIndex(index)
    }
    
    // SAVING IMAGE TO DACUMENT DIRECTORY
    func saveImage(image: UIImage, filename: String) {
        let path = NSHomeDirectory().stringByAppendingString("/Documents/\(filename)")
        let data = UIImagePNGRepresentation(image)
        data!.writeToFile(path, atomically: true)
    }
    
    // GET IMAGE FROM DOCUMENT DIRECTORY WITH NAME
    func getImage(filename: String) -> UIImage? {
        var error: NSError?
        let path = NSHomeDirectory().stringByAppendingString("/Documents/\(filename)")
        let data: NSData?
        do{
            data = try NSData(contentsOfFile: path, options: .UncachedRead)
        }
        catch let error1 as NSError {
            error = error1
            data = nil
        }
        if let unwrappedError = error {
            print(unwrappedError)
            return nil
        } else {
            return UIImage(data: data!)
        }
    }
    
    // SAVE DATA TO THE DOCUMENT DIRECTORY
    func saveAlbums() {
        let filename = NSHomeDirectory().stringByAppendingString("/Documents/albums.bin")
        let data = NSKeyedArchiver.archivedDataWithRootObject(albums)
        data.writeToFile(filename, atomically: true)
    }
}
