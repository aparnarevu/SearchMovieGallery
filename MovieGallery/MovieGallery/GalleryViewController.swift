//
//  GalleryViewController.swift
//  MovieGallery
//
//  Created by Aparna Revu on 5/2/17.
//  Copyright © 2017 Aparna Revu. All rights reserved.
//

import UIKit

class GalleryViewController: UITableViewController {

    var galleryResults = [Movie]()
    
    var cache:NSCache<AnyObject, AnyObject>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.cache = NSCache()
        self.title = NSLocalizedString(kTitleKey, comment: "Title")
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.refreshControl?.addTarget(self, action: #selector(GalleryViewController.handleRefresh(refreshControl:)), for: UIControlEvents.valueChanged)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    
    
    // MARK: - Utility Methods
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        // Do some reloading of data and update the table view's data source
        // Fetch more objects from a web service, for example...
        
        self.tableView.reloadData()
        refreshControl.endRefreshing()
    }

//    func updateResponse(_ data: Data?, isMovieData:Bool)  {
//        do {
//            if let data = data, let response = try JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions(rawValue:0)) as? [String: AnyObject] {
//                if isMovieData {
//                    updateSearchResults(data, response: response )
//                }else {
//                    updateImageConfigurationDetails(data: data, response: response)
//                }
//            } else {
//                print("JSON Error")
//            }
//        } catch let error as NSError {
//            print("Error parsing results: \(error.localizedDescription)")
//        }
//    }
//
//    
//    
//    func updateSearchResults(_ data: Data?, response: [String: AnyObject]) {
//        
//        self.galleryResults.removeAll()
//        // Get the results array
//        if let array: AnyObject = response[kResultsKey] {
//           // print("Result:: ",array)
//            for trackDictonary in array as! [AnyObject] {
//                if let trackDictonary = trackDictonary as? [String: AnyObject], let previewUrl = trackDictonary[kPosterPathKey] as? String {
//                    // Parse the search result
//                    let title = trackDictonary[kMovieTitleKey] as? String
//                    let movieId = trackDictonary[kMovieIdKey] as? Int
//                    let releaseDate = trackDictonary[kReleaseDateKey] as? String
//                    let language = trackDictonary[kLanguageKey] as? String
//                    let overview = trackDictonary[kMovieOverViewKey] as? String
//                    //print("Overview:: ",overview)
//                    let logoImageURL = self.imageBaseURL + self.imageLogoSize  + previewUrl
//                    let posterImageURL = self.imageBaseURL + self.imagePosterSize + previewUrl
//
//                    galleryResults.append(Movie(movieId: movieId!, title: title!, overview: overview!, language: language!, releaseDate: releaseDate!, posterPath: posterImageURL, logoImageURL: logoImageURL))
//
//                } else {
//                    print("Not a dictionary")
//                }
//            }
//        } else {
//            print("Results key not found in dictionary")
//        }
//        
//        DispatchQueue.main.async {
//            self.tableView.reloadData()
//            self.tableView.setContentOffset(CGPoint.zero, animated: false)
//        }
//    }
    
    // MARK: - TableView Datasource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.galleryResults.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kCellIdentifierKey, for: indexPath) as! MovieTableViewCell
        
        let movie = galleryResults[indexPath.row]
        cell.titleLabel.text = movie.title
        cell.releaseDateLabel.text = movie.releaseDate!
        cell.overViewLabel.text = movie.movieOverview
        
//        cell.previewView.layer.cornerRadius = 5.0
//        cell.previewView.layer.borderColor = UIColor.gray.cgColor
//        cell.previewView.layer.borderWidth = 1.0
//        cell.previewView.layer.masksToBounds = true
        cell.previewView.backgroundColor = UIColor.clear
        if (self.cache.object(forKey: movie.logoImageURL! as String as AnyObject) != nil){
            // Use cache
            cell.previewView.image = self.cache.object(forKey: movie.logoImageURL as AnyObject) as? UIImage
        }else{
            
            cell.previewView.downloadTheImageForURL(imageUrlStr: movie.logoImageURL!, completion: { (downloadedImage) in
                DispatchQueue.main.async{
                    cell.previewView.image = downloadedImage
                }
                self.cache.setObject(downloadedImage, forKey: movie.logoImageURL! as String as AnyObject)
            })
            
        }
        return cell
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
}



