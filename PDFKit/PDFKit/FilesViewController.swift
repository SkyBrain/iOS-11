//
//  FilesViewController.swift
//  PDFKit
//
//  Created by Sampath on 7/2/18.
//  Copyright © 2018 sky. All rights reserved.
//

import UIKit

class FilesViewController: UITableViewController {
    
    let books = ["Beyond Code",
                 "Hacking with macOS",
                 "Hacking with Swift",
                 "Hacking with tvOS",
                 "Objective-C for Swift Developers",
                 "Practical iOS 10",
                 "Practical iOS 11",
                 "Pro Swift",
                 "Server-Side Swift",
                 "Swift Coding Challenges"]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Books"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = books[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let navController = splitViewController?.viewControllers[1] as? UINavigationController else{
            return
        }
        
        guard let viewController = navController.viewControllers[0] as? ViewController else{
            return
        }
        viewController.load(books[indexPath.row])
    }

}
