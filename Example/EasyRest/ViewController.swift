//
//  ViewController.swift
//  EasyRest
//
//  Created by ingdanni on 02/19/2018.
//  Copyright (c) 2018 ingdanni. All rights reserved.
//

import UIKit
import EasyRest

class API {
    
    static let shared = API()
    
    private init() {}
    
    let posts = Entity(name: "posts")
    
}

struct Post: Codable {
    var title: String
    var body: String
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        API.shared.posts.get(as: [Post].self) {
            data, error in
            
            if let data = data {
                print(data)
            }
            
            if let error = error {
                print(error)
            }
        }
    }

}

