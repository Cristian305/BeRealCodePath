//
//  FeedViewController.swift
//  BeRealCodePath
//
//  Created by Cristian Gonzalez on 2/5/25.
//

import UIKit
import ParseSwift
import SwiftUI

class FeedViewController: UIViewController {

    private let tableView = UITableView()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "BeReal."
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 24)
        return label
    }()

    private let postButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Post", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        button.addTarget(self, action: #selector(onPostButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let signOutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Out", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        button.addTarget(self, action: #selector(onSignOutTapped), for: .touchUpInside)
        return button
    }()
    
    private var posts = [Post]() {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        if let user = User.current {
                print("✅ Logged in as: \(user.username ?? "Unknown")")
            } else {
                print("❌ No user session found! Redirecting to login.")
                navigateToLogin()
            }
        setupNavigationBar()
        setupTableView()
        queryPosts()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        queryPosts()
    }

    // ✅ Added Sign Out button to navigation bar
    private func setupNavigationBar() {
        let navBar = UIView()
        navBar.backgroundColor = .black
        navBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(navBar)

        // ✅ Ensure navBar can receive touch events
        navBar.isUserInteractionEnabled = true

        // ✅ Add title label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        navBar.addSubview(titleLabel)

        // ✅ Ensure Post button is tappable
        postButton.translatesAutoresizingMaskIntoConstraints = false
        postButton.isUserInteractionEnabled = true
        navBar.addSubview(postButton)
        postButton.translatesAutoresizingMaskIntoConstraints = false

        // ✅ Ensure Sign Out button is tappable
        signOutButton.translatesAutoresizingMaskIntoConstraints = false
        signOutButton.isUserInteractionEnabled = true
        navBar.addSubview(signOutButton)

        NSLayoutConstraint.activate([
            // NavBar constraints
            navBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navBar.heightAnchor.constraint(equalToConstant: 60),

            // Title constraints
            titleLabel.centerXAnchor.constraint(equalTo: navBar.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: navBar.centerYAnchor),

            // Post button constraints (Right side)
            postButton.trailingAnchor.constraint(equalTo: navBar.trailingAnchor, constant: -16),
            postButton.centerYAnchor.constraint(equalTo: navBar.centerYAnchor),
            postButton.widthAnchor.constraint(equalToConstant: 60),
            postButton.heightAnchor.constraint(equalToConstant: 40),

            // Sign Out button constraints (Left side)
            signOutButton.leadingAnchor.constraint(equalTo: navBar.leadingAnchor, constant: 16),
            signOutButton.centerYAnchor.constraint(equalTo: navBar.centerYAnchor),
            signOutButton.widthAnchor.constraint(equalToConstant: 80),
            signOutButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    private func setupTableView() {
        tableView.backgroundColor = .black
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = true
        
        // ✅ Ensure the cell is registered
        tableView.register(PostCell.self, forCellReuseIdentifier: "PostCell")

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    private var isLoadingMorePosts = false
    private let postsPerPage = 1000

    private func queryPosts(skip: Int = 0) {
        guard !isLoadingMorePosts else { return }
        isLoadingMorePosts = true  // ✅ Prevent duplicate fetches

        print("🔍 DEBUG: Fetching posts (skip: \(skip))")

        let query = Post.query()
            .include("user")
            .order([.descending("createdAt")])
            .limit(postsPerPage)
            .skip(skip)

        query.find { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoadingMorePosts = false
                switch result {
                case .success(let newPosts):
                    print("✅ Successfully fetched \(newPosts.count) more posts")
                    if skip == 0 {
                        self?.posts = newPosts  // Refresh on initial load
                    } else {
                        self?.posts.append(contentsOf: newPosts)  // Append new data
                    }
                    self?.tableView.reloadData()
                case .failure(let error):
                    print("❌ Error fetching posts: \(error.localizedDescription)")
                }
            }
        }
    }

    // ✅ Post button action
    @objc private func onPostButtonTapped() {
        let postVC = PostViewController()
        postVC.modalPresentationStyle = .fullScreen
        present(postVC, animated: true)
        print("✅ Post button tapped!") // Add this log for debugging
    }
    
    @objc private func onSignOutTapped() {
        showConfirmLogoutAlert()
    }

    private func showConfirmLogoutAlert() {
        let alertController = UIAlertController(title: "Log out of your account?", message: nil, preferredStyle: .alert)
        
        let logOutAction = UIAlertAction(title: "Log out", style: .destructive) { _ in
            self.logOutUser()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(logOutAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }

    private func logOutUser() {
        Task {
            do {
                try await User.logout()
                DispatchQueue.main.async {
                    self.navigateToLogin()
                }
            } catch {
                print("❌ Error logging out: \(error.localizedDescription)")
            }
        }
    }

    private func navigateToLogin() {
        let contentView = ContentView()
        let hostingController = UIHostingController(rootView: contentView)

        // Set the hosting controller as the root
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let delegate = UIApplication.shared.delegate as? AppDelegate {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = hostingController
            delegate.window = window
            window.makeKeyAndVisible()
            print("✅ Successfully navigated to ContentView.")
        } else {
            print("❌ Failed to navigate to ContentView.")
        }
    }

    private func showAlert(description: String? = nil) {
        let alertController = UIAlertController(title: "Oops...", message: "\(description ?? "Please try again...")", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        present(alertController, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension FeedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(posts.count, 1) // Ensure there's at least 1 row
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if posts.isEmpty {
            let cell = UITableViewCell()
            cell.textLabel?.text = "No posts available."
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = .white
            cell.backgroundColor = .black
            return cell
        }

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as? PostCell else {
            print("❌ Failed to dequeue PostCell")
            return UITableViewCell()
        }

        cell.configure(with: posts[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate
extension FeedViewController: UITableViewDelegate { }
