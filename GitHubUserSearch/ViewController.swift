//
//  ViewController.swift
//  GitHubUserSearch
//
//  Created by Babu Lal on 12/06/18.
//  Copyright © 2018 Babu Lal. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    
    var searchedUsers = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.placeholder = "Search GitHub Users"
    }
    
    // MARK: - Table View
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath)
        let user: User = searchedUsers[indexPath.row]
        
        cell.textLabel!.text = user.username
        return cell
    }
    
    // MARK: - Search
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchedUsers.removeAll()
        self.tableView.reloadData()
        self.searchUserWithQueryString(path: searchText, onCompletion: []);
    }
    
    // MARK: - API Calls
    
    func searchUserWithQueryString(path: String, onCompletion: [[String: Any]]){
        let url = URL(string: "https://api.github.com/search/users?sort=followers&q="+path)
        URLSession.shared.dataTask(with:url!, completionHandler: {(data, response, error) in
            guard let data = data, error == nil else { return }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any]
                let usersJson = json["items"] as? [[String: Any]] ?? []
                
                for userData in usersJson {
                    let username = userData["login"] as? String ?? ""
                    self.searchedUsers.append(User(username: username))
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch let error as NSError {
                print(error)
            }
        }).resume()
    }
}

