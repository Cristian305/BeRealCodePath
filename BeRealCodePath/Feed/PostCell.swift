//
//  PostCell.swift
//  BeRealCodePath
//
//  Created by Cristian Gonzalez on 2/6/25.
//

import UIKit
import Alamofire
import AlamofireImage

class PostCell: UITableViewCell {
    
    // UI Elements (Manually created instead of @IBOutlet)
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .white
        return label
    }()
    
    private let postImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let captionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .lightGray
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .darkGray
        return label
    }()

    private var imageDataRequest: DataRequest?

    // ✅ Initialize UI elements in the cell
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .black // Match app theme
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // ✅ Setup UI layout
    private func setupUI() {
        addSubview(usernameLabel)
        addSubview(postImageView)
        addSubview(captionLabel)
        addSubview(dateLabel)
        
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        postImageView.translatesAutoresizingMaskIntoConstraints = false
        captionLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            usernameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            usernameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            postImageView.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 8),
            postImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            postImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            postImageView.heightAnchor.constraint(equalToConstant: 250), // Adjust image size
            
            captionLabel.topAnchor.constraint(equalTo: postImageView.bottomAnchor, constant: 8),
            captionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            captionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            dateLabel.topAnchor.constraint(equalTo: captionLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            dateLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }

    // ✅ Configure the cell
    func configure(with post: Post) {
        if let user = post.user {
                usernameLabel.text = user.username ?? "Unknown user" // ✅ Properly fetch username
            } else {
                print("⚠️ DEBUG: User not found for post ID: \(post.objectId ?? "N/A")")
                usernameLabel.text = "Unknown user"
            }
        //usernameLabel.text = post.user?.username ?? "Unknown User"
        captionLabel.text = post.caption ?? "No caption"
        dateLabel.text = post.createdAt.map { DateFormatter.postFormatter.string(from: $0) } ?? "Unknown date"

        // Fetch image using Alamofire
        if let imageFile = post.imageFile, let imageUrl = imageFile.url {
            imageDataRequest = AF.request(imageUrl).responseImage { [weak self] response in
                switch response.result {
                case .success(let image):
                    self?.postImageView.image = image
                case .failure(let error):
                    print("❌ Error fetching image: \(error.localizedDescription)")
                }
            }
        } else {
            postImageView.image = UIImage(named: "placeholder") // Use a default image
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        postImageView.image = nil
        imageDataRequest?.cancel()
    }
}

extension DateFormatter {
    static let postFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter
    }()
}
