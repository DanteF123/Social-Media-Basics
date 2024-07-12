//
//  NetworkManager.swift
//  Social Media Basics
//
//  Created by Dante Fusaro on 7/12/24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class NetworkManager: ObservableObject{
    
    @Published var toDo = [Post]()
    
    let currentUser = Auth.auth().currentUser
    
    func populatePosts(){
        if let userID = currentUser?.uid{
            getUserPosts(userId: userID) { posts, error in
                if let error = error {
                    print("Error fetching posts: \(error)")
                } else if let posts = posts {
                    print("Fetched \(posts.count) posts for user")
                    for post in posts {
                        print(post.body)

                    }
                }
            }
        }
    }
    
    func getUserPosts(userId: String, completion: @escaping ([Post]?, Error?) -> Void) {
        let db = Firestore.firestore()
        let postsRef = db.collection("users").document(userId).collection("posts")
        
        postsRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting posts: \(error)")
                completion(nil, error)
            } else {
                var posts: [Post] = []
                for document in querySnapshot!.documents {
                    let data = document.data()
                    let content = data["post"] as? String ?? "No Content"
                    
                    
                    let post = Post(body:content)
                    posts.append(post)
                    self.toDo.append(post)
                }
                completion(posts, nil)
            }
        }
    }
}
