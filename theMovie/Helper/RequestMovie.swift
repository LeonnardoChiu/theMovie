//
//  RequestMovie.swift
//  theMovie
//
//  Created by Leonnardo Benjamin Hutama on 16/04/20.
//  Copyright © 2020 Leonnardo Benjamin Hutama. All rights reserved.
//

import Foundation

enum MovieError: Error {
    case noDataAvailable
    case canNotProcessData
    case noMorePage
}

struct MovieRequest {
    let API_KEY = "ddfd20f181dca69879720623fa40e992"
    
    func getMovie(page: Int, genre: String, completionHandler: @escaping(Result<[MovieDetail], MovieError>) -> Void) {
        let resourceString = "https://api.themoviedb.org/3/discover/movie?api_key=\(API_KEY)&language=en-US&include_adult=false&page=\(page)&with_genres=\(genre)"
        
        guard let resourceURL = URL(string: resourceString) else { fatalError() }
        
        let dataTask = URLSession.shared.dataTask(with: resourceURL) { data, _, error in
            guard let jsonData = data else {
                completionHandler(.failure(.noDataAvailable))
                return
            }
            
            do{
                let decoder = JSONDecoder()
                let movieResponse = try
                    decoder.decode(MovieResponse.self, from: jsonData)
                if movieResponse.total_pages! < page {
                    print("no more page")
                    return
                }
                else {
                    let movieDetail = movieResponse.results
                    completionHandler(.success(movieDetail))
                }
            }
            catch {
                print(error)
                completionHandler(.failure(.canNotProcessData))
            }
            
        }
        dataTask.resume()
    }
    
    func searchMovie(keyword: String, page: Int, completionHandler: @escaping(Result<MovieResponse, MovieError>) -> Void) {
        let resourceString = "https://api.themoviedb.org/3/search/movie?api_key=\(API_KEY)&query=\(keyword)&page=\(page)"
        
        guard let resourceURL = URL(string: resourceString) else { fatalError() }
        
        let dataTask = URLSession.shared.dataTask(with: resourceURL) { data, _, error in
            guard let jsonData = data else {
                completionHandler(.failure(.noDataAvailable))
                return
            }
            
            do{
                let decoder = JSONDecoder()
                let movieResponse = try
                    decoder.decode(MovieResponse.self, from: jsonData)
                completionHandler(.success(movieResponse))
            }
            catch {
                print(error)
                completionHandler(.failure(.canNotProcessData))
            }
            
        }
        dataTask.resume()
    }
    
    func getMovieDetail(movie_id: Int, completionHandler: @escaping(Result<MovieDetail, MovieError>) -> Void) {
        let resourceString = "https://api.themoviedb.org/3/movie/\(movie_id)?api_key=\(API_KEY)"
        
        guard let resourceURL = URL(string: resourceString) else { fatalError() }
        
        let dataTask = URLSession.shared.dataTask(with: resourceURL) { data, _, error in
            guard let jsonData = data else {
                completionHandler(.failure(.noDataAvailable))
                return
            }
            
            do{
                let decoder = JSONDecoder()
                let movieDetail = try
                    decoder.decode(MovieDetail.self, from: jsonData)
                completionHandler(.success(movieDetail))
            }
            catch {
                print(error)
                completionHandler(.failure(.canNotProcessData))
            }
            
        }
        dataTask.resume()
    }
    
    func getMovieReview(movie_id: Int, page: Int, completionHandler: @escaping(Result<ReviewResponse, MovieError>) -> Void) {
        let resourceString = "https://api.themoviedb.org/3/movie/\(movie_id)/reviews?api_key=\(API_KEY)&language=en-US&page=\(page)"
        
        guard let resourceURL = URL(string: resourceString) else { fatalError() }
        
        let dataTask = URLSession.shared.dataTask(with: resourceURL) { data, _, error in
            guard let jsonData = data else {
                completionHandler(.failure(.noDataAvailable))
                return
            }
            
            do{
                let decoder = JSONDecoder()
                let reviewResponse = try
                    decoder.decode(ReviewResponse.self, from: jsonData)
                completionHandler(.success(reviewResponse))
            }
            catch {
                print(error)
                completionHandler(.failure(.canNotProcessData))
            }
            
        }
        dataTask.resume()
    }
    
    func getVideo(movie_id: Int, completionHandler: @escaping(Result<VideoResponse, MovieError>) -> Void) {
        let resourceString = "https://api.themoviedb.org/3/movie/\(movie_id)/videos?api_key=\(API_KEY)&language=en-US"
        
        guard let resourceURL = URL(string: resourceString) else { fatalError() }
        
        let dataTask = URLSession.shared.dataTask(with: resourceURL) { data, _, error in
            guard let jsonData = data else {
                completionHandler(.failure(.noDataAvailable))
                return
            }
            
            do{
                let decoder = JSONDecoder()
                let videoResponse = try
                    decoder.decode(VideoResponse.self, from: jsonData)
                completionHandler(.success(videoResponse))
            }
            catch {
                print(error)
                completionHandler(.failure(.canNotProcessData))
            }
            
        }
        dataTask.resume()
    }

}

struct RequestGenres {
    let API_KEY = "ddfd20f181dca69879720623fa40e992"
    let resourceURL: URL
    
    init() {
        let resourceString = "https://api.themoviedb.org/3/genre/movie/list?api_key=\(API_KEY)"
           
        guard let resourceURL = URL(string: resourceString) else { fatalError() }
           
        self.resourceURL = resourceURL
    }
    
    func getGenres(completionHandler: @escaping(Result<[Genre], MovieError>) -> Void) {
        let dataTask = URLSession.shared.dataTask(with: resourceURL) { data, _, _ in
            guard let jsonData = data else {
                completionHandler(.failure(.noDataAvailable))
                return
            }
            
            do{
                let decoder = JSONDecoder()
                let genreResponse = try
                    decoder.decode(Genres.self, from: jsonData)
                let genreDetail = genreResponse.genres
                completionHandler(.success(genreDetail))
            }
            catch {
                completionHandler(.failure(.canNotProcessData))
            }
            
        }
        dataTask.resume()
    }
}
