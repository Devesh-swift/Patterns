//
//  HTTPClient.swift
//  Patterns
//
//  Created by Ozal Suleyman on 4/13/17.
//  Copyright © 2017 Ozal Suleyman. All rights reserved.
//


import UIKit

class HTTPClient {
    
    // FOR A GET REQUESTS
    func getRequest(url: String) -> (AnyObject) {
        return NSData()
    }
    
    // FOR A POST REQUESTS
    func postRequest(url: String, body: String) -> (AnyObject){
        return NSData()
    }
    
    // DOWNLOAD IMAGES FROM API
    func downloadImage(url: String) -> (UIImage) {
        let aUrl = NSURL(string: url)
        let data = NSData(contentsOfURL: aUrl!)
        let image = UIImage(data: data!)
        return image!
    }
    
}




