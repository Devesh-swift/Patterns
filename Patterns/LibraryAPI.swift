//
//  LibraryAPI.swift
//  Patterns
//
//  Created by Ozal Suleyman on 4/13/17.
//  Copyright © 2017 Ozal Suleyman. All rights reserved.
//


import UIKit

class LibraryAPI: NSObject {
    
    private let persistencyManager: PersistencyManager
    private let httpClient: HTTPClient
    private let isOnline: Bool
    
    override init() {
        persistencyManager = PersistencyManager()
        httpClient = HTTPClient()
        isOnline = false
        
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(LibraryAPI.downloadImage(_:)), name: "BLDownloadImageNotification", object: nil)
    }
    
    // GETING ALBUM DATA
    func getAlbums() -> [Album] {
        return persistencyManager.getAlbums()
    }
    
    // ADD ALBUM DATA TO CURRENT DATA
    func addAlbum(album: Album, index: Int) {
        persistencyManager.addAlbum(album, index: index)
        if isOnline {
            httpClient.postRequest("/api/addAlbum", body: album.description)
        }
    }
    
    // DELETEING ALBUM
    func deleteAlbum(index: Int) {
        persistencyManager.deleteAlbumAtIndex(index)
        if isOnline {
            httpClient.postRequest("/api/deleteAlbum", body: "\(index)")
        }
    }
    
    //1 USE SINGLETON DESIGN PATTERN
    class var sharedInstance: LibraryAPI {
        //2
        struct Singleton {
            //3
            static let instance = LibraryAPI()
        }
        //4
        return Singleton.instance
    }
    
    
    // AUTORELEASING OBJECT WHEN DOESN'T USE
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // GETTING ASYNC IMAGE WHEN PASSING NOTIFICATION
    // MULTITHEREADING
    func downloadImage(notification: NSNotification) {
        //1
        let userInfo = notification.userInfo as! [String: AnyObject]
        let imageView = userInfo["imageView"] as! UIImageView?
        let coverUrl = userInfo["coverUrl"] as! String
        
        //2
        if let imageViewUnWrapped = imageView {
            imageViewUnWrapped.image = persistencyManager.getImage((coverUrl as NSString).lastPathComponent)
            if imageViewUnWrapped.image == nil {
                //3 BACKGROUND THREAD
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                    let downloadedImage = self.httpClient.downloadImage(coverUrl as String)
                    //4 MAIN THREAD
                    dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                        imageViewUnWrapped.image = downloadedImage
                        self.persistencyManager.saveImage(downloadedImage, filename: (coverUrl as NSString).lastPathComponent)
                    })
                })
            }
        }
    }
    
    func saveAlbums() {
        persistencyManager.saveAlbums()
    }
    
}
