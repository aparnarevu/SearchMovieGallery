//
//  SearchViewController.swift
//  MovieGallery
//
//  Created by Aparna Revu on 5/8/17.
//  Copyright © 2017 Aparna Revu. All rights reserved.
//

import UIKit

class SearchViewController: UITableViewController,UIGestureRecognizerDelegate {

    @IBOutlet weak var searchBar:UISearchBar?

    var movieSearchResults = [Movie]()
    var searchTextList = [String]()

    lazy var tapRecognizer: UITapGestureRecognizer = {
        var recognizer = UITapGestureRecognizer(target:self, action: #selector(SearchViewController.dismissKeyboard))
        return recognizer
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = NSLocalizedString(kTitleKey, comment: "Title")
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.searchTextList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCellIdentifier", for: indexPath)
        cell.textLabel?.text = self.searchTextList[indexPath.row]
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.searchBar?.text = self.searchTextList[indexPath.row]
        self.searchBarSearchButtonClicked(self.searchBar!)
    }


    
    // MARK: - Utility Methods
    func dismissKeyboard() {
        searchBar?.resignFirstResponder()
    }
}

// MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        dismissKeyboard()
        
        if !searchBar.text!.isEmpty {
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            
            let expectedCharSet = CharacterSet.urlQueryAllowed
            let searchTerm = searchBar.text!.addingPercentEncoding(withAllowedCharacters: expectedCharSet)!
            let urlString:String = kMovieGalleryAPI + kAPIKey + "&query=\(searchTerm)"
            downloadDataFromMovieDB(searchBy: urlString, completion: { (response) in
                if !self.searchTextList.contains((self.searchBar?.text)!) {
                    self.searchTextList.append((self.searchBar?.text)!)
                }
                self.movieSearchResults.removeAll()
                self.movieSearchResults =  self.updateSearchResults(response: response)
                
                DispatchQueue.main.async {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let detailsViewController = storyboard.instantiateViewController(withIdentifier: "MovieListViewController") as? MovieListViewController
                    detailsViewController?.galleryResults = self.movieSearchResults
                    detailsViewController?.searchStr = self.searchBar?.text
                    self.navigationController?.pushViewController(detailsViewController!, animated: true)
                }

            })
        }
    }
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        view.addGestureRecognizer(tapRecognizer)
        self.tableView.reloadData()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        view.removeGestureRecognizer(tapRecognizer)

    }
}

extension UIViewController
{
    func downloadDataFromMovieDB(searchBy:String, completion: @escaping ((_ response: [String: AnyObject]) -> Void))  {
        let defaultSession = Foundation.URLSession(configuration: URLSessionConfiguration.default)
        var dataTask: URLSessionDataTask?
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        // 4
        let url = URL(string: searchBy)
        // 5
        dataTask = defaultSession.dataTask(with: url!, completionHandler: {
            data, response, error in
            // 6
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            // 7
            if let error = error {
                
                print(error.localizedDescription)
                
                let alert = UIAlertController(title: "Alert", message: error.localizedDescription, preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                alert.addAction(alertAction)
                self.present(alert, animated: true, completion: nil)
                
            } else if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    do {
                        if let data = data, let response = try JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions(rawValue:0)) as? [String: AnyObject] {
                            
                            completion(response)

                        } else {
                            print("JSON Error")
                        }
                    } catch let error as NSError {
                        print("Error parsing results: \(error.localizedDescription)")
                    }
                }
            }
        })
        // 8
        dataTask?.resume()
        
    }
    
    
    func updateSearchResults(response: [String: AnyObject])->[Movie] {
        
        var result = [Movie]()
        // Get the results array
        if let array: AnyObject = response[kResultsKey] {
            // print("Result:: ",array)
            for trackDictonary in array as! [AnyObject] {
                if let trackDictonary = trackDictonary as? [String: AnyObject], let previewUrl = trackDictonary[kPosterPathKey] as? String {
                    // Parse the search result
                    let title = trackDictonary[kMovieTitleKey] as? String
                    let movieId = trackDictonary[kMovieIdKey] as? Int
                    let releaseDate = trackDictonary[kReleaseDateKey] as? String
                    let language = trackDictonary[kLanguageKey] as? String
                    let overview = trackDictonary[kMovieOverViewKey] as? String
                    //print("Overview:: ",overview)
                    let posterImageURL = kImageConfigurationAPI + previewUrl
                    result.append(Movie(movieId: movieId!, title: title!, overview: overview!, language: language!, releaseDate: releaseDate!, posterPath: posterImageURL))
                    
                } else {
                    print("Not a dictionary")
                }
            }
        } else {
            print("Results key not found in dictionary")
        }
        
        return result
        
    }

    
}


