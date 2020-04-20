//
//  MovieDetailViewController.swift
//  theMovie
//
//  Created by Leonnardo Benjamin Hutama on 17/04/20.
//  Copyright © 2020 Leonnardo Benjamin Hutama. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var originalTitleLabel: UILabel!
    
    @IBOutlet weak var taglineLabel: UILabel!
    
    @IBOutlet weak var overviewLabel: UILabel!
    
    @IBOutlet weak var ratingLabel: UILabel!
    
    @IBOutlet weak var genresLabel: UILabel!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var runtimeLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    var movie_id = 0
    
    var movieDetail: MovieDetail?
    
    var page_number = 1
    
    var fetchMoreReview = false
    
    var reviewResults = [ReviewDetail] () {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        page_number = 1
        reviewResults.removeAll()
        
        print(movie_id)
        
        getMovieDetail()
        getReview()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
        
        tableView.tableFooterView = UIView()
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let movieRequest = MovieRequest()
        
        movieRequest.getVideo(movie_id: movie_id, completionHandler: { [weak self] result in
            switch result {
            case .failure(let error):
                print(error)
                
            case .success(let response):
                if response.results.count == 0 { return }
                let key = response.results[0].key
                
                guard let url = URL(string: "https://youtube.com/watch?v=\(key)") else { return }
                DispatchQueue.main.async {
                    UIApplication.shared.open(url)
                }
                
            }
        })
    }
    
    func getMovieDetail() {
        let movieRequest = MovieRequest()
        
        movieRequest.getMovieDetail(movie_id: movie_id, completionHandler: { [weak self] result in
            switch result {
            case .failure(let error):
                print(error)
                
            case .success(let movies):
                DispatchQueue.main.async {
                    
                    self?.imageView.image = self!.getMovieImage(imageURL: movies.backdrop_path ?? "")
                    
                    self?.originalTitleLabel.text = movies.original_title
                    
                    self?.taglineLabel.text = movies.tagline
                    
                    self?.overviewLabel.text = movies.overview
                    
                    self?.ratingLabel.text = "Rating: \(movies.vote_average)/10"
                    
                    if movies.genres?.count == 0 {
                        self?.genresLabel.text = "Genres: -"
                    }
                    else{
                        var genres:[String] = []
                        for genre in movies.genres! {
                            genres.append(genre.name)
                        }
                        
                        self?.genresLabel.text = "Genres: \(genres.joined(separator: ", "))"
                    }
                    
                    if movies.status == "Released" {
                        self?.statusLabel.text = "Status: \(movies.status!) at \(movies.release_date)"
                    }
                    else {
                        self?.statusLabel.text = "Status: \(movies.status!)"
                    }
                    
                    if movies.runtime != nil {
                        self?.runtimeLabel.text = "Runtime: \(movies.runtime!) min"
                    }
                    else{
                        self?.runtimeLabel.text = "Runtime: -"
                    }
                    
                }
                
            }
        })
    }
    
    func getMovieImage(imageURL: String) -> UIImage {
        let urlKey = "https://image.tmdb.org/t/p/w500\(imageURL)"
        let noImage = UIImage(systemName: "film")
        var movieImage:UIImage?
        
        if let url = URL(string: urlKey) {
            do{
                let data = try Data(contentsOf: url)
                movieImage = UIImage(data: data)
                
            }catch let error {
                print(error.localizedDescription)
            }
            return movieImage ?? noImage!
        }
        
        return noImage!
    }
    
    func getReview() {
        let movieRequest = MovieRequest()
        
        movieRequest.getMovieReview(movie_id: movie_id, page: page_number, completionHandler: { [weak self] result in
            switch result {
            case .failure(let error):
                print(error)
                
            case .success(let reviews):
                self?.reviewResults.append(contentsOf: reviews.results!)
            }
        })
    }
    
    func fetchNextPage(){
        page_number += 1
        self.fetchMoreReview = true
        
        tableView.reloadSections(IndexSet(integer: 1), with: .none)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
            self.getReview()
            self.fetchMoreReview = false
        })
        
    }

}

extension MovieDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Reviews"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if reviewResults.count == 0 {
            return 1
        }
        else {
            return reviewResults.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath)
        
        if reviewResults.count == 0 {
            cell.detailTextLabel?.alpha = 0
            cell.textLabel?.text = "No Review"
        }
        else {
            cell.detailTextLabel?.alpha = 1
            cell.textLabel?.text = reviewResults[indexPath.row].author
            cell.detailTextLabel?.text = "\(reviewResults[indexPath.row].content) \n\n"
        }
        
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offSetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offSetY > contentHeight - scrollView.frame.height + 4 {
            if !fetchMoreReview {
                fetchNextPage()
            }
        }
    }
    
    
}
