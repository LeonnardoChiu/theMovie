//
//  Model.swift
//  theMovie
//
//  Created by Leonnardo Benjamin Hutama on 16/04/20.
//  Copyright © 2020 Leonnardo Benjamin Hutama. All rights reserved.
//

import Foundation

struct GenreResponse: Decodable {
    var response: Genres
}

struct Genres: Decodable {
    var genres: [Genre]
}

struct Genre: Decodable {
    var id: Int
    var name: String
}

struct MovieResponse: Decodable {
    var total_pages: Int?
    var results: [MovieDetail]
}

struct MovieDetail: Decodable {
    var vote_count: Int
    var video: Bool
    var poster_path: String?
    var id: Int
    var adult: Bool
    var original_language: String
    var original_title: String
    var genre_ids: [Int]?
    var title: String 
    var vote_average: Double
    var overview: String
    var release_date: String
    var runtime: Int?
    var tagline: String?
    var status: String?
    var genres: [Genre]?
    var production_companies: [ProductionCompany]?
    var backdrop_path: String?
}

struct ProductionCompany: Decodable {
    var id: Int
    var logo_path: String?
    var name: String
    var origin_country: String
}

struct ReviewResponse: Decodable {
    var total_pages: Int
    var total_results: Int
    var results: [ReviewDetail]?
}

struct ReviewDetail: Decodable {
    var author: String
    var content: String
    var id: String
    var url: String
}

struct VideoResponse: Decodable {
    var id: Int
    var results: [VideoDetail]
}

struct VideoDetail: Decodable {
    var key: String
}
