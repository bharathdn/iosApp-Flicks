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

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var movies: [NSDictionary]?
    var movieEndPoint: String!
    
    let refreshControl = UIRefreshControl()
    
    @IBOutlet weak var myTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myTableView.dataSource = self
        myTableView.delegate = self
        
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
        });
        task.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = myTableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        
        let movie = movies?[indexPath.row]
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
