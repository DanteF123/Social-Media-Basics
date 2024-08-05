//
//  HelloViewController.swift
//  Social Media Basics
//
//  Created by Dante Fusaro on 6/22/24.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseFirestore

class HelloViewController: UIViewController {

    

    @IBOutlet weak var helloLabel: UILabel!
    
    @IBOutlet weak var addItemText: UITextField!
    
    @IBOutlet weak var toDoList: UITableView!
    
    @IBAction func addButtonClicked(_ sender: UIButton) {
        postButtonClicked()

    }
    
    @IBOutlet weak var sideMenuButton: UIBarButtonItem!
    
    
    let db = Firestore.firestore()
    let currentUser = Auth.auth().currentUser
    
    var toDo : [Post] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        greetUser()
        
        toDoList.dataSource = self
        
        toDoList.register(UITableViewCell.self, forCellReuseIdentifier: "ReusableCell")
        populatePosts()
        addLongPressGesture()
        
        sideMenuButton.target = revealViewController()
        sideMenuButton.action = #selector(revealViewController()?.revealSideMenu)
        
    }
}


extension HelloViewController{
    func greetUser() {
            print("greetUser called")  // Debug statement
            helloLabel.text = "" // Initially set to an empty string to avoid placeholder text

            constructUser { user in
                DispatchQueue.main.async {
                    if let user = user {
                        print("User found: \(user.name)")  // Debug statement
                        self.helloLabel.text = user.name
                    } else {
                        print("No user found")  // Debug statement
                        self.helloLabel.text = "User not found!"
                    }
                }
            }
        }
        
        func constructUser(completion: @escaping (User?) -> Void) {
            print("constructUser called")  // Debug statement
            if let currentUser = Auth.auth().currentUser {
                let userId = currentUser.uid
                let userEmail = currentUser.email!
                print("Current user email: \(userEmail)")  // Debug statement
                
                db.collection("users").document(userId).getDocument { (document, error) in
                    if let document = document, document.exists {
                        let data = document.data()
                        if let name = data?["name"] as? String {
                            let user = User(name: name, email: userEmail)
                            print("User constructed: \(user.name)")  // Debug statement
                            completion(user)
                        } else {
                            print("Name field does not exist in the document")
                            completion(nil)
                        }
                    } else {
                        print("Document does not exist: \(error?.localizedDescription ?? "No error information")")
                        completion(nil)
                    }
                }
            } else {
                print("No authenticated user")
                completion(nil)
            }
        }

}

extension HelloViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let listItem = toDo[indexPath.row].body
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath)
        cell.textLabel?.text=listItem
        
        return cell
    }
    
    func populatePosts(){
        if let userID = currentUser?.uid{
            getUserPosts(userId: userID) { posts, error in
                if let error = error {
                    print("Error fetching posts: \(error)")
                } else if let posts = posts {
                    print("Fetched \(posts.count) posts for user")
                    for post in posts {
                        self.toDoList.reloadData()
                    }
                }
            }
        }
    }
    
    func getUserPosts(userId: String, completion: @escaping ([Post]?, Error?) -> Void) {
        let db = Firestore.firestore()
        let postsRef = db.collection("users").document(userId).collection("posts").order(by: "date", descending: true)
        
        postsRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting posts: \(error)")
                completion(nil, error)
            } else {
                var posts: [Post] = []
                for document in querySnapshot!.documents {
                    let data = document.data()
                    let key = document.documentID
                    let content = data["post"] as? String ?? "No Content"
                    let date = data["date"] as? Double ?? 0.00
                    let post = Post(key: key, body:content, date: date)
                    
                    print(post.key)
                    posts.append(post)
                    self.toDo.append(post)
                }
                completion(posts, nil)
            }
        }
    }
    
    
}

extension HelloViewController {
    func postButtonClicked(){
        
        if let text = addItemText.text{
            let date = Date().timeIntervalSince1970

            let post = Post(key: "", body: text, date: date)
            toDo.insert(post, at: 0)
            toDoList.reloadData()
            print("new post")
            print(post.date)
            let postRef = db.collection("users").document(currentUser!.uid).collection("posts").document()
            postRef.setData(["post":text, "date":date]){ error in
                if let error = error {
                    print("Error adding post: \(error)")
                } else {
                    print("Post added successfully")
                }
            }
            
        }
    }
}

extension HelloViewController{
    func addLongPressGesture(){
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        toDoList.addGestureRecognizer(longPressGesture)
    }
}

extension HelloViewController {
    @objc func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let touchPoint = gestureRecognizer.location(in: self.toDoList)
            if let indexPath = toDoList.indexPathForRow(at: touchPoint) {
                presentDeleteActionSheet(forRowAt: indexPath)
            }
        }
    }

    func presentDeleteActionSheet(forRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: nil, message: "Are you sure you want to delete this item?", preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.deleteItem(at: indexPath)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
}


extension HelloViewController {
    func deleteItem(at indexPath: IndexPath) {
        let postToDelete = toDo[indexPath.row]

        print(postToDelete.body)
        print(postToDelete.body)
        
        let postRef = db.collection("users").document(currentUser!.uid).collection("posts").document(postToDelete.key!)
        
        postRef.delete { error in
            if let error = error {
                print("Error deleting post: \(error)")
            } else {
                print("Post successfully deleted")
            }
        }
        
        toDo.remove(at: indexPath.row)
        toDoList.deleteRows(at: [indexPath], with: .automatic)
    }
}
