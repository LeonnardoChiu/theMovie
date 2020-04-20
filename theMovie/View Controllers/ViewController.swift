//
//  ViewController.swift
//  theMovie
//
//  Created by Leonnardo Benjamin Hutama on 16/04/20.
//  Copyright © 2020 Leonnardo Benjamin Hutama. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    let searchBar = UISearchBar()
    
    var listOfGenre: [Genre]?
    
    var selectedMovieId = 0
    
    var fetchMoreMovie = false
    
    var page_number = 1
    
    var selectedGenre:[String] = []
    
    var listOfMovie = [MovieDetail] () {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        getGenres()
        getMovie()
        
        initSearchBar()
        
        // set table view header to search bar
        tableView.tableHeaderView = searchBar
        tableView.tableFooterView = UIView()
        let loadingNib = UINib(nibName: "LoadingCell", bundle: nil)
        tableView.register(loadingNib, forCellReuseIdentifier: "loadingCell")
    }
    
    func printThisString(string: String) {
        print(string)
    }
    
    func getSelectedGenre(genres: [Genre]) {
        print(genres)
    }
    
    func initSearchBar() {
        // set the search bar view
            searchBar.delegate = self
            searchBar.searchBarStyle = UISearchBar.Style.default
            searchBar.showsCancelButton = false
            searchBar.placeholder = "Search by Movie"
            searchBar.sizeToFit()
        }
    
    func getMovie() {
        let movieRequest = MovieRequest()
        var selectedGenreConverted = ""
        
        if selectedGenre.count != 0 {
            selectedGenreConverted = selectedGenre.joined(separator: ",")
        }
        
        movieRequest.getMovie(page: page_number, genre: selectedGenreConverted) { [weak self] result in
            switch result {
            case .failure(let error):
                print(error)
                
            case .success(let movies):
                self?.listOfMovie.append(contentsOf: movies)
                print(self!.listOfMovie)
            }
        }
    }
    
    func searchMovie(keyword: String) {
        let replacedKey = keyword.replacingOccurrences(of: " ", with: "%20")

        let movieRequest = MovieRequest()

        movieRequest.searchMovie(keyword: replacedKey, page: self.page_number, completionHandler: { [weak self] result in
            switch result {
            case .failure(let error):
                print(error)

            case .success(let movies):
                if self!.page_number > movies.total_pages! {
                    self!.fetchMoreMovie = true
                }
                else {
                    self?.listOfMovie.append(contentsOf: movies.results)
                }
            }
        })
    }
    
    func getGenres() {
        let genreRequest = RequestGenres()
        
        genreRequest.getGenres { [weak self] result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let genres):
                self?.listOfGenre = genres
            }
        }
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
    
    
    func fetchNextPage(){
        page_number += 1
        self.fetchMoreMovie = true
        
        tableView.reloadSections(IndexSet(integer: 1), with: .none)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
            if self.searchBar.text == "" {

                self.getMovie()
            }
            else {
                
                self.searchMovie(keyword: self.searchBar.text!)
            }
            self.fetchMoreMovie = false
            print(self.page_number)
        })
        
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToMovieDetail" {
            let nextVC = segue.destination as! MovieDetailViewController
            nextVC.movie_id = selectedMovieId
        }
        else if segue.identifier == "segueToSelectGenre" {
            let nextVC = segue.destination as! GenreViewController
            nextVC.delegate = self
            nextVC.selectedGenres = selectedGenre
        }
    }

}


extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return listOfMovie.count
        }
        else if section == 1 && fetchMoreMovie {
            return 1
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 145
        }
        else {
            return 65
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell", for: indexPath) as! MovieTableViewCell
            
            cell.imageView?.image = getMovieImage(imageURL: listOfMovie[indexPath.row].poster_path ?? "")
            cell.titleLabel.text = listOfMovie[indexPath.row].title
            cell.releasedDateLabel.text = "Released at \(listOfMovie[indexPath.row].release_date)"
            cell.ratingLabel.text = "\(listOfMovie[indexPath.row].vote_average)/10"
            
            var genres = ""
            for genre in listOfMovie[indexPath.row].genre_ids! {
                for genreList in listOfGenre! {
                    if genre == genreList.id {
                        genres = genres + " | " + genreList.name
                        
                    }
                }
            }
            genres = genres + " | "
            cell.genresLabel.text = genres
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "loadingCell", for: indexPath) as! LoadingCellTableViewCell
            
            cell.activityIndicator.hidesWhenStopped = true
            cell.activityIndicator.startAnimating()
            cell.noMoreResultLabel.alpha = 0
            
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedMovieId = listOfMovie[indexPath.row].id
        performSegue(withIdentifier: "segueToMovieDetail", sender: self)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
        let offSetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offSetY > contentHeight - scrollView.frame.height + 4 {
            if !fetchMoreMovie {
                fetchNextPage()
            }
        }
    }
        
}

extension ViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(ViewController.reload), object: nil)
        self.perform(#selector(ViewController.reload), with:
        nil, afterDelay: 0.5)
    }
    
    @objc func reload() {
        guard let searchBarText = searchBar.text else { return }

        page_number = 1
        listOfMovie.removeAll()
        if searchBarText == "" {
            
            getMovie()
            return
        }

        searchMovie(keyword: searchBarText)
        
    }
    
}

extension ViewController: PassGenre {
    func passGenre(genres: [String]) {
        selectedGenre = genres
        listOfMovie.removeAll()
        getMovie()
    }
    
}
