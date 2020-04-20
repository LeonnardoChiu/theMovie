//
//  GenreViewController.swift
//  theMovie
//
//  Created by Leonnardo Benjamin Hutama on 17/04/20.
//  Copyright © 2020 Leonnardo Benjamin Hutama. All rights reserved.
//

import UIKit

protocol PassGenre {
    func passGenre(genres: [String])
}

class GenreViewController: UIViewController {
    

    @IBOutlet weak var tableView: UITableView!
    
    
    var listOfGenre: [Genre]?
    
    var selectedGenres: [String] = []
    
    var delegate: PassGenre!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        getGenres()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Clear Genres", style: .plain, target: self, action: #selector(clearButtonTapped))
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        delegate.passGenre(genres: selectedGenres)
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

    @objc func clearButtonTapped() {
        selectedGenres.removeAll()
        
        tableView.reloadData()
    }
    
}

extension GenreViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfGenre!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "genreCell", for: indexPath)
        
        cell.textLabel?.text = listOfGenre![indexPath.row].name
        cell.accessoryType = .none
        cell.selectionStyle = .none
        
        if selectedGenres.count != 0 {
            for genre in selectedGenres {
                if genre == "\(listOfGenre![indexPath.row].id)" {
                    cell.accessoryType = . checkmark
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
            for (i, genre) in selectedGenres.enumerated() {
                if genre == "\(listOfGenre![indexPath.row].id)" {
                    selectedGenres.remove(at: i)
                }
            }
            
        }
        else{
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            selectedGenres.append("\(listOfGenre![indexPath.row].id)")
        }
        print(selectedGenres)
    }
    
}
