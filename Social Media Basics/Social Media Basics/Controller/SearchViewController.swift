//
//  SearchViewController.swift
//  Social Media Basics
//
//  Created by Dante Fusaro on 7/16/24.
//

import Foundation
import UIKit

class SearchViewController: UIViewController{
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var searchResults: UITableView!
    
    var users : [User] = [User(name: "bob", email: "email")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchResults.dataSource = self
        searchResults.register(UITableViewCell.self, forCellReuseIdentifier: "SearchCell")

    }
}


extension SearchViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let listItem = users[indexPath.row].email
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath)
        cell.textLabel?.text=listItem
        return cell
    }
    
    
}

extension SearchViewController {
    
    func getAllUsers(){
        
    }
}
