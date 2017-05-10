//
//  MovieListViewController.swift
//  MovieGallery
//
//  Created by aparna on 5/9/17.
//  Copyright © 2017 Aparna Revu. All rights reserved.
//

import UIKit

class MovieListViewController: UITableViewController {

    var galleryResults = [Movie]()
    var searchStr:String?

    var cache:NSCache<AnyObject, AnyObject>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.cache = NSCache()
        self.title = NSLocalizedString(kTitleKey, comment: "Title")
        self.tableView.separatorColor = UIColor.gray
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.refreshControl?.addTarget(self, action: #selector(MovieListViewController.handleRefresh(refreshControl:)), for: UIControlEvents.valueChanged)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    
    
    // MARK: - Utility Methods
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        // Do some reloading of data and update the table view's data source
        // Fetch more objects from a web service, for example...
        self.downloadDataFromMovieDB(searchBy: self.searchStr!) { (response) in
            self.galleryResults.removeAll()
            self.cache.removeAllObjects()
            self.galleryResults =  self.updateSearchResults(response: response)
        }
        self.tableView.reloadData()
        refreshControl.endRefreshing()
    }
    func formatDate(releaseDate:String) -> String {
        let dateComponentsStr = releaseDate.components(separatedBy: "-")
        let result = dateComponentsStr[2] + "/" + dateComponentsStr[1]  + "/" + dateComponentsStr[0];
        return result
    }

    
    
    // MARK: - TableView Datasource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.galleryResults.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kCellIdentifierKey, for: indexPath) as! MovieTableViewCell
        
        let movie = galleryResults[indexPath.row]
        cell.titleLabel.text = movie.title
        cell.releaseDateLabel.text = formatDate(releaseDate: movie.releaseDate!)
        cell.overViewLabel.text = movie.movieOverview
        cell.previewView.backgroundColor = UIColor.clear
        if (self.cache.object(forKey: movie.posterImageURL! as String as AnyObject) != nil){
            // Use cache
            cell.previewView.image = self.cache.object(forKey: movie.posterImageURL as AnyObject) as? UIImage
        }else{
            
            cell.previewView.downloadTheImageForURL(imageUrlStr: movie.posterImageURL!, completion: { (downloadedImage) in
                DispatchQueue.main.async{
                    cell.previewView.image = downloadedImage
                }
                self.cache.setObject(downloadedImage, forKey: movie.posterImageURL! as String as AnyObject)
            })
            
        }
        return cell
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    

}
