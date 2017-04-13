//
//  ViewController.swift
//  Patterns
//
//  Created by Ozal Suleyman on 4/13/17.
//  Copyright © 2017 Ozal Suleyman. All rights reserved.
//


import UIKit

let FRAME = UIScreen.mainScreen().bounds
let CELL_IDENTIFIER = "Cell"

class AlbumViewController: UIViewController {
    
    // CLASS PRIVATE PROPERTYS
    private var allAlbums = [Album]()
    private var currentAlbumData : (titles:[String], values:[String])?
    private var currentAlbumIndex = 0
    
    // We will use this array as a stack to push and pop operation for the undo option
    var undoStack: [(Album, Int)] = []
    
    var scroller: HorizontalScroller!
    var tableView: UITableView!
    
    @IBOutlet weak var toolBar: UIToolbar!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.drawCustomDesign()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
}



// CUSTOMASING AND ACTIONABLE FUNCTIONS
extension AlbumViewController {
    
    
    // DRAW PAGE VIEWS ONLY PROGRAMATICALLY
    func drawCustomDesign () {
        
        //1
        self.navigationController?.navigationBar.translucent = false
        currentAlbumIndex = 0
        
        //2
        if Reachability.isConnectedToNetwork() {
            
            allAlbums = LibraryAPI.sharedInstance.getAlbums()
            
            // ADDING SCROLL PAGE VIEW TO THE CUSTOM VIEW
            self.scroller = HorizontalScroller(frame: CGRect(x: 0.0 , y: 0.0 , width: FRAME.width  , height: FRAME.height / 5.5))
            self.scroller.backgroundColor = UIColor.grayColor()
            self.view.addSubview(self.scroller)
            
            
            // ADDING TABLEVIEW TO THE CUSTOME VIEW
            self.tableView = UITableView(frame: CGRect(x: 0.0 , y: self.scroller.frame.maxY + 10.0  , width: FRAME.width , height: FRAME.height / 2.0 ) , style: UITableViewStyle.Plain)
            self.tableView.delegate = self
            self.tableView.dataSource = self
            self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: CELL_IDENTIFIER)
            self.tableView.backgroundColor = UIColor.whiteColor()
            self.tableView.showsVerticalScrollIndicator = false
            self.tableView.showsHorizontalScrollIndicator = false
            self.tableView.multipleTouchEnabled = false
            self.tableView.separatorStyle = .None
            self.tableView.bounces = false
            self.tableView.separatorColor = UIColor.clearColor()
            self.tableView.backgroundView = nil
            
            self.view.addSubview(self.tableView!)
            
            self.showDataForAlbum(currentAlbumIndex)
            
            self.loadPreviousState()
            
            scroller.delegate = self
            reloadScroller()
            
            let undoButton = UIBarButtonItem(barButtonSystemItem: .Undo, target: self, action:#selector(AlbumViewController.undoAction))
            undoButton.enabled = false;
            let space = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target:nil, action:nil)
            let trashButton = UIBarButtonItem(barButtonSystemItem: .Trash, target:self, action:#selector(AlbumViewController.deleteAlbum))
            let toolbarButtonItems = [undoButton, space, trashButton]
            self.toolBar.setItems(toolbarButtonItems, animated: true)
            
            NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(AlbumViewController.saveCurrentState), name: UIApplicationDidEnterBackgroundNotification, object: nil)
            
        }else {
    
            self.createAlertMessage("Internet", message: "Check your internet connection")
            
        }
        
    }
    
    func createAlertMessage (title : String , message : String) {
    
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    
    }
    
    
    
    
    func addAlbumAtIndex(album: Album,index: Int) {
        LibraryAPI.sharedInstance.addAlbum(album, index: index)
        currentAlbumIndex = index
        reloadScroller()
    }
    
    
    func deleteAlbum() {
        //1
        let deletedAlbum : Album = allAlbums[currentAlbumIndex]
        //2
        let undoAction = (deletedAlbum, currentAlbumIndex)
        undoStack.insert(undoAction, atIndex: 0)
        //3
        LibraryAPI.sharedInstance.deleteAlbum(currentAlbumIndex)
        reloadScroller()
        //4
        let barButtonItems = self.toolBar.items! as [UIBarButtonItem]
        let undoButton : UIBarButtonItem = barButtonItems[0]
        undoButton.enabled = true
        //5
        if (allAlbums.count == 0) {
            let trashButton : UIBarButtonItem = barButtonItems[2]
            trashButton.enabled = false
        }
    }
    
    
    func undoAction() {
        let barButtonItems = self.toolBar.items! as [UIBarButtonItem]
        //1
        if undoStack.count > 0 {
            let (deletedAlbum, index) = undoStack.removeAtIndex(0)
            addAlbumAtIndex(deletedAlbum, index: index)
        }
        //2
        if undoStack.count == 0 {
            let undoButton : UIBarButtonItem = barButtonItems[0]
            undoButton.enabled = false
        }
        //3
        let trashButton : UIBarButtonItem = barButtonItems[2]
        trashButton.enabled = true
    }
    
    func initialViewIndex(scroller: HorizontalScroller) -> Int {
        return currentAlbumIndex
    }
    
    func showDataForAlbum(albumIndex: Int) {
        // defensive code: make sure the requested index is lower than the amount of albums
        if (albumIndex < allAlbums.count && albumIndex > -1) {
            //fetch the album
            let album = allAlbums[albumIndex]
            // save the albums data to present it later in the tableview
            currentAlbumData = album.ae_tableRepresentation()
        } else {
            currentAlbumData = nil
        }
        // we have the data we need, let's refresh our tableview
        self.tableView.reloadData()
    }
    
    func reloadScroller() {
        allAlbums = LibraryAPI.sharedInstance.getAlbums()
        if currentAlbumIndex < 0 {
            currentAlbumIndex = 0
        } else if currentAlbumIndex >= allAlbums.count {
            currentAlbumIndex = allAlbums.count - 1
        }
        scroller.reload()
        showDataForAlbum(currentAlbumIndex)
    }
    
    //MARK: Memento Pattern
    func saveCurrentState() {
        // When the user leaves the app and then comes back again, he wants it to be in the exact same state
        // he left it. In order to do this we need to save the currently displayed album.
        // Since it's only one piece of information we can use NSUserDefaults.
        NSUserDefaults.standardUserDefaults().setInteger(currentAlbumIndex, forKey: "currentAlbumIndex")
        LibraryAPI.sharedInstance.saveAlbums()
    }
    
    func loadPreviousState() {
        currentAlbumIndex = NSUserDefaults.standardUserDefaults().integerForKey("currentAlbumIndex")
        showDataForAlbum(currentAlbumIndex)
    }
    
    
}



// ADDING DELEGATE FUNTIONS MY OWN CONTROLLER
extension AlbumViewController : UITableViewDataSource , UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let albumData = currentAlbumData {
            return albumData.titles.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: CELL_IDENTIFIER)
        
        if let albumData = currentAlbumData {
            cell.textLabel!.text = albumData.titles[indexPath.row]
            cell.detailTextLabel!.text = albumData.values[indexPath.row]
        }
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return self.tableView.frame.height / 6.0
    }
    
    
}


extension AlbumViewController : HorizontalScrollerDelegate {
    func horizontalScrollerClickedViewAtIndex(scroller: HorizontalScroller, index: Int) {
        //1
        let previousAlbumView = scroller.viewAtIndex(currentAlbumIndex) as! AlbumView
        previousAlbumView.highlightAlbum(false)
        //2
        currentAlbumIndex = index
        //3
        let albumView = scroller.viewAtIndex(index) as! AlbumView
        albumView.highlightAlbum(true)
        //4
        showDataForAlbum(index)
    }
    
    func numberOfViewsForHorizontalScroller(scroller: HorizontalScroller) -> (Int) {
        return allAlbums.count
    }
    
    func horizontalScrollerViewAtIndex(scroller: HorizontalScroller, index: Int) -> (UIView) {
        let album = allAlbums[index]
        let albumView = AlbumView(frame: CGRect(x: 0, y: 0, width: 100, height: 100), albumCover: album.coverUrl)
        if currentAlbumIndex == index {
            albumView.highlightAlbum(true)
        } else {
            albumView.highlightAlbum(false)
        }
        return albumView
    }
    
}


























