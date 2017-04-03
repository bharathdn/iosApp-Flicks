//
//  MoviesViewController.swift
//  flicks
//
//  Created by Bharath D N on 3/31/17.
//  Copyright © 2017 Bharath D N. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    var movies: [NSDictionary]?
    var movieEndPoint: String!
    
    let refreshControl = UIRefreshControl()
    let searchBar = UISearchBar()
    var searchResultsShown = false
    var filteredMovies: [NSDictionary]?
    
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var networkErrorView: UIView!
    @IBOutlet weak var networkErrorLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myTableView.dataSource = self
        myTableView.delegate = self
        self.toggleNetWorkError(hideErrorValue: true)
        
        // searchbar
        
        searchBar.showsCancelButton = true
        searchBar.delegate = self
        self.navigationItem.titleView = searchBar
        
        refreshControl.addTarget(self, action: #selector(networkRequest), for: UIControlEvents.valueChanged)
        myTableView.insertSubview(refreshControl, at: 0)
        
        networkRequest()
    }
    
    func networkRequest() {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let movieUrl = URL(string: "https://api.themoviedb.org/3/movie/\(movieEndPoint!)?api_key=\(apiKey)")
        let request = URLRequest(url: movieUrl!)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        self.toggleNetWorkError(hideErrorValue: true)
        let task : URLSessionDataTask = session.dataTask(
            with: request as URLRequest,
            completionHandler: { (data, response, error) in
                MBProgressHUD.hide(for: self.view, animated: true)
                if let data = data {
                    if let responseDictionary = try! JSONSerialization.jsonObject(
                        with: data, options:[]) as? NSDictionary {
                        
                        self.movies = responseDictionary["results"] as? [NSDictionary]
                        self.myTableView.reloadData()
                        self.refreshControl.endRefreshing()
                    }
                }
                else {
                    print("Network Error")
                    self.toggleNetWorkError(hideErrorValue: false)
                }
        });
        task.resume()
    }
    
    func toggleNetWorkError(hideErrorValue: Bool) {
        if(hideErrorValue) {
            networkErrorView.frame.size.height = 0;
        }
        else {
            networkErrorView.frame.size.height = 44;
        }
        networkErrorView.isHidden = hideErrorValue
        networkErrorLabel.isHidden = hideErrorValue
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchResultsShown) {
            return filteredMovies?.count ?? 0
        }
        return movies?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = myTableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        
        let movie: NSDictionary?
        if(searchResultsShown) {
            movie = filteredMovies?[indexPath.row]
        } else {
            movie = movies?[indexPath.row]
        }

        let title = movie?["title"] as! String
        let overview = movie?["overview"] as! String
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        
        if let posterPath = movie?["poster_path"] as? String {
            let baseImageUrl = "https://image.tmdb.org/t/p/original"
        
            let imageUrl = NSURL(string: baseImageUrl + posterPath)
            cell.posterView.setImageWith(imageUrl! as URL)
        }
        return cell
    }
    
    // Search related functions
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        let searchText = searchBar.text?.lowercased()
        if(searchText == "") {
           searchBarCancelButtonClicked(searchBar)
           return
        }
        
        filteredMovies = movies?.filter({ (movie: NSDictionary) -> Bool in
            let title = movie["title"] as! String
            return (title.lowercased().contains(searchText!))
        })
        searchResultsShown = true
        self.myTableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchResultsShown = true
        searchBar.endEditing(true)
        self.myTableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchResultsShown = false
        self.myTableView.reloadData()
    }
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! UITableViewCell
        let indexPath = myTableView.indexPath(for: cell)
        let movie = movies![indexPath!.row]
        
        let detailViewController = segue.destination as! DetailViewController
        detailViewController.movie = movie
    }

}
