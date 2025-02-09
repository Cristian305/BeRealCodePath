//
//  SignUpViewController.swift
//  BeRealCodePath
//
//  Created by Cristian Gonzalez on 2/4/25.
//

import UIKit
import ParseSwift

class SignUpViewController: UIViewController {

    private let usernameField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Username"
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let emailField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email"
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        textField.keyboardType = .emailAddress
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
    
    private let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(onSignUpTapped), for: .touchUpInside)
        return button
    }()
    
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
        titleLabel.text = "Sign Up"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(titleLabel)
        view.addSubview(usernameField)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(signUpButton)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            
            usernameField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            usernameField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            usernameField.widthAnchor.constraint(equalToConstant: 250),
            usernameField.heightAnchor.constraint(equalToConstant: 40),
            
            emailField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emailField.topAnchor.constraint(equalTo: usernameField.bottomAnchor, constant: 20),
            emailField.widthAnchor.constraint(equalTo: usernameField.widthAnchor),
            emailField.heightAnchor.constraint(equalTo: usernameField.heightAnchor),
            
            passwordField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 20),
            passwordField.widthAnchor.constraint(equalTo: usernameField.widthAnchor),
            passwordField.heightAnchor.constraint(equalTo: usernameField.heightAnchor),
            
            signUpButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signUpButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 30),
            signUpButton.widthAnchor.constraint(equalTo: usernameField.widthAnchor),
            signUpButton.heightAnchor.constraint(equalToConstant: 45)
        ])
    }
    
    private func setupNavigationBar() {
           let backButton = UIBarButtonItem(image: UIImage(systemName: "arrow.left"),
                                            style: .plain,
                                            target: self,
                                            action: #selector(onBackTapped))
        backButton.tintColor = .white
        navigationItem.leftBarButtonItem = backButton
       }
       
       @objc private func onBackTapped() {
           dismiss(animated: true, completion: nil)
       }

    @objc private func onSignUpTapped() {
        guard let username = usernameField.text,
              let email = emailField.text,
              let password = passwordField.text,
              !username.isEmpty,
              !email.isEmpty,
              !password.isEmpty else {
            showMissingFieldsAlert()
            return
        }

        if let currentUser = User.current {
            try? User.logout()
        }

        var newUser = User()
        newUser.username = username
        newUser.email = email
        newUser.password = password

        newUser.signup { [weak self] result in
            switch result {
            case .success(let user):
                print("✅ Successfully signed up user: \(user)")
                NotificationCenter.default.post(name: Notification.Name("loginSuccess"), object: nil)
                DispatchQueue.main.async {
                    self?.dismiss(animated: true, completion: nil)
                }
            case .failure(let error):
                let errorMessage = error.localizedDescription
                print("Sign-up failed: \(errorMessage)")
                DispatchQueue.main.async {
                    self?.showAlert(description: errorMessage)
                }
            }
        }
    }

    private func showAlert(description: String?) {
        let alertController = UIAlertController(title: "Unable to Sign Up", message: description ?? "Unknown error", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        present(alertController, animated: true)
    }

    private func showMissingFieldsAlert() {
        let alertController = UIAlertController(title: "Oops...", message: "We need all fields filled out in order to sign you up.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        present(alertController, animated: true)
    }
}
