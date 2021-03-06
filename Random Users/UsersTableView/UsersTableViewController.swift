//
//  UsersTableViewController.swift
//  Random Users
//
//  Created by Shawn Gee on 4/10/20.
//  Copyright © 2020 Erica Sadun. All rights reserved.
//

import UIKit

class UsersTableViewController: UITableViewController {

    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUsers()
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    
    // MARK: - Actions
    
    @objc private func refresh() {
        fetchUsers {
            self.refreshControl?.endRefreshing()
        }
    }
    
    // MARK: - Private
    
    private let randomUserClient = RandomUserClient()
    private var users: [User] = [] { didSet { tableView.reloadData() }}
    
    private var thumbnailCache = Cache<URL, Data>(size: 1_000_000)
    private var imageCache = Cache<URL, Data>(size: 1_000_000)
    
    private func fetchUsers(completion: @escaping () -> Void = {}) {
        randomUserClient.fetchUsers { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let users):
                    self.users = users
                case .failure(let error):
                    print(error)
                }
                completion()
            }
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as? UserTableViewCell else {
            fatalError("Could not cast cell as \(UserTableViewCell.self)")
        }
        cell.thumbnailCache = thumbnailCache
        cell.user = users[indexPath.row]

        return cell
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let userDetailVC = segue.destination as? UserDetailViewController,
            let indexPath = tableView.indexPathForSelectedRow {
            userDetailVC.imageCache = imageCache
            userDetailVC.user = users[indexPath.row]
        }
    }
}
