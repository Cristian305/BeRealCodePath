//
//  LoginViewController.swift
//  BeRealCodePath
//
//  Created by Cristian Gonzalez on 2/4/25.
//

import UIKit
import ParseSwift

class LoginViewController: UIViewController {
    
    private let usernameField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Username"
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let passwordField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(onLoginTapped), for: .touchUpInside)
        return button
    }()
    ///
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("<=", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold) // 🔹 Increased font size
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10) // 🔹 Larger tap area
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(onBackTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        view.addSubview(backButton)
        NSLayoutConstraint.activate([
                    backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                    backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10)
                ])
        
        let titleLabel = UILabel()
        titleLabel.text = "Login"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(titleLabel)
        view.addSubview(usernameField)
        view.addSubview(passwordField)
        view.addSubview(loginButton)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            
            usernameField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            usernameField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            usernameField.widthAnchor.constraint(equalToConstant: 250),
            usernameField.heightAnchor.constraint(equalToConstant: 40),
            
            passwordField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordField.topAnchor.constraint(equalTo: usernameField.bottomAnchor, constant: 20),
            passwordField.widthAnchor.constraint(equalTo: usernameField.widthAnchor),
            passwordField.heightAnchor.constraint(equalTo: usernameField.heightAnchor),
            
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 30),
            loginButton.widthAnchor.constraint(equalTo: usernameField.widthAnchor),
            loginButton.heightAnchor.constraint(equalToConstant: 45)
        ])
    }
    /*
    private func setupNavigationBar() {
           let backButton = UIBarButtonItem(image: UIImage(systemName: "arrow.left"),
                                            style: .plain,
                                            target: self,
                                            action: #selector(onBackTapped))
            backButton.tintColor = .white
            navigationItem.leftBarButtonItem = backButton
       }
     */
       
    @objc private func onBackTapped() {
        dismiss(animated: true, completion: nil)
        }
    
    
    @objc private func onLoginTapped() {
        guard let username = usernameField.text,
              let password = passwordField.text,
              !username.isEmpty,
              !password.isEmpty else {
            showMissingFieldsAlert()
            return
        }

        User.login(username: username, password: password) { [weak self] result in
            switch result {
            case .success(let user):
                print("✅ Successfully logged in as user: \(user)")
                
                NotificationCenter.default.post(name: Notification.Name("loginSuccess"), object: nil)
                
                DispatchQueue.main.async {
                    let feedVC = FeedViewController()
                    
                    if let navigationController = self?.navigationController {
                        // ✅ Use setViewControllers to ensure navigation stack resets properly
                        navigationController.setViewControllers([feedVC], animated: true)
                    } else {
                        print("❌ ERROR: navigationController is nil, presenting Feed manually")
                        feedVC.modalPresentationStyle = .fullScreen
                        self?.present(feedVC, animated: true, completion: nil)
                    }
                }
                
            case .failure(let error):
                self?.showAlert(description: error.localizedDescription)
            }
        }
    }

    private func showAlert(description: String?) {
        let alertController = UIAlertController(title: "Unable to Log in", message: description ?? "Unknown error", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        present(alertController, animated: true)
    }

    private func showMissingFieldsAlert() {
        let alertController = UIAlertController(title: "Oops...", message: "We need all fields filled out in order to log you in.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        present(alertController, animated: true)
    }
}
