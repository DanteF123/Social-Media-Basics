//
//  Post.swift
//  Social Media Basics
//
//  Created by Dante Fusaro on 7/4/24.
//

import Foundation

struct Post{
    let body : String
    let date : Date
    var key : String?
    
    init(key:String?, body: String, date: Double) {
        self.body = body
        self.date = Date(timeIntervalSince1970: date)
        self.key = key
    }
    
}
