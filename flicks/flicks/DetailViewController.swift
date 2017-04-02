//
//  DetailViewController.swift
//  flicks
//
//  Created by Bharath D N on 3/31/17.
//  Copyright © 2017 Bharath D N. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var infoView: UIView!
    
    var movie: NSDictionary!
    
    func slideUpInfoView(_ sender: UIPanGestureRecognizer) {
        
        UIView.animate(withDuration: 0.3) {
            self.infoView.frame.origin.y = self.posterImageView.frame.size.height - self.infoView.frame.size.height
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let posterPath = movie?["poster_path"] as? String {
            let baseImageUrl = "https://image.tmdb.org/t/p/w500"
            
            let imageUrl = NSURL(string: baseImageUrl + posterPath)
            posterImageView.setImageWith(imageUrl! as URL)
        
        // add gesture to slide up infoview when the infoview is tapped
            let gesture = UITapGestureRecognizer(target: self, action: #selector(slideUpInfoView(_:)))
            
            infoView.addGestureRecognizer(gesture)
        }
        
        let title = movie["title"] as! String
        titleLabel.text = title
        
        let overview = movie["overview"] as! String
        overviewLabel.text = overview
        overviewLabel.sizeToFit()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
