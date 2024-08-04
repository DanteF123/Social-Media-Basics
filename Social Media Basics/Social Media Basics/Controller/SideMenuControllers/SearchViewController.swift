//
//  SearchViewController.swift
//  Social Media Basics
//
//  Created by Dante Fusaro on 7/16/24.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseFirestore

class SearchViewController: UIViewController, UISearchBarDelegate{
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var searchResults: UITableView!
    
    var users: [User] = []
    var filteredUsers: [User] = [] // Add filtered users array
    let db = Firestore.firestore()
    let currentUser = Auth.auth().currentUser

    override func viewDidLoad() {
        super.viewDidLoad()
        searchResults.dataSource = self
        searchResults.register(UITableViewCell.self, forCellReuseIdentifier: "SearchCell")
        searchBar.delegate = self // Set the search bar delegate
        getAllUsers()
    }
    
    func filterUsers(for searchText: String) {
        filteredUsers = users.filter { user in
            return user.name.lowercased().contains(searchText.lowercased()) ||
                   user.email.lowercased().contains(searchText.lowercased())
        }
        searchResults.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let lowercaseSearchText = searchText.lowercased()
        searchBar.text = lowercaseSearchText  // Display the search text in lowercase
        if lowercaseSearchText.isEmpty {
            filteredUsers = users
        } else {
            filterUsers(for: lowercaseSearchText)
        }
        searchResults.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        filteredUsers = users
        searchResults.reloadData()
        searchBar.resignFirstResponder()
    }
}



extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let listItem = filteredUsers[indexPath.row].email
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath)
        cell.textLabel?.text = listItem
        return cell
    }
}

extension SearchViewController {
    func getAllUsers() {
        let db = Firestore.firestore()
        let userRef = db.collection("users")
        
        userRef.getDocuments { querySnapshot, error in
            if let error = error {
                print("Error getting users \(error)")
            } else {
                for i in querySnapshot!.documents {
                    if i.documentID != self.currentUser!.uid {
                        let data = i.data()
                        let user_email = data["email"]
                        let user_name = data["name"]
                        
                        let user = User(name: user_name as! String, email: user_email as! String)
                        self.users.append(user)
                    }
                }
                DispatchQueue.main.async {
                    self.filteredUsers = self.users // Initialize filtered users
                    self.searchResults.reloadData()
                }
            }
        }
    }
}
