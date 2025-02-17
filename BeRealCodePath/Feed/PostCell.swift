import UIKit
import Alamofire
import AlamofireImage

class PostCell: UITableViewCell {

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
        label.numberOfLines = 0
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .darkGray
        return label
    }()

    private let locationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .systemGray2
        label.text = "📍 Location: Unknown"
        label.numberOfLines = 1
        return label
    }()

    // ✅ Comment Button
    private let commentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("💬 Comments", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        button.backgroundColor = UIColor(white: 0.15, alpha: 1)
        button.layer.cornerRadius = 6
        return button
    }()

    // ✅ Callback Closure for Comment Action
    var onCommentTappedCallback: (() -> Void)?

    private var imageDataRequest: DataRequest?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .black
        setupUI()
        commentButton.addTarget(self, action: #selector(onCommentTapped), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(usernameLabel)
        addSubview(postImageView)
        addSubview(captionLabel)
        addSubview(locationLabel)
        addSubview(dateLabel)
        addSubview(commentButton)

        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        postImageView.translatesAutoresizingMaskIntoConstraints = false
        captionLabel.translatesAutoresizingMaskIntoConstraints = false
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        commentButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // Username Label
            usernameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            usernameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            usernameLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16),

            // Post Image
            postImageView.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 8),
            postImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            postImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            postImageView.heightAnchor.constraint(equalToConstant: 250),

            // Caption Label
            captionLabel.topAnchor.constraint(equalTo: postImageView.bottomAnchor, constant: 8),
            captionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            captionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            // Location Label
            locationLabel.topAnchor.constraint(equalTo: captionLabel.bottomAnchor, constant: 4),
            locationLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            locationLabel.trailingAnchor.constraint(equalTo: captionLabel.trailingAnchor),

            // Date Label
            dateLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            dateLabel.trailingAnchor.constraint(equalTo: captionLabel.trailingAnchor),

            // Comment Button
            commentButton.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 8),
            commentButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            commentButton.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16),
            commentButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            commentButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    // MARK: - Configure Cell
    func configure(with post: Post) {
        usernameLabel.text = post.user?.username ?? "Unknown User"
        captionLabel.text = post.caption ?? "No caption"
        dateLabel.text = post.createdAt.map { DateFormatter.postFormatter.string(from: $0) } ?? "Unknown date"

        // Fetch location using Foundation-based IP Geolocation
        fetchLocation { [weak self] location in
            self?.locationLabel.text = "📍 \(location)"
        }

        if let imageFile = post.imageFile, let imageUrl = imageFile.url {
            imageDataRequest = AF.request(imageUrl).responseImage { [weak self] response in
                switch response.result {
                case .success(let image):
                    self?.postImageView.image = image
                case .failure(let error):
                    print("❌ Error fetching image: \(error.localizedDescription)")
                    self?.postImageView.image = UIImage(named: "placeholder")
                }
            }
        } else {
            postImageView.image = UIImage(named: "placeholder")
        }
    }

    // MARK: - Foundation-Based Location Lookup
    private func fetchLocation(completion: @escaping (String) -> Void) {
        guard let url = URL(string: "https://ipapi.co/json/") else {
            completion("Unknown Location")
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                print("❌ Location fetch failed:", error?.localizedDescription ?? "Unknown error")
                completion("Unknown Location")
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    let city = json["city"] as? String ?? "Unknown City"
                    let country = json["country_name"] as? String ?? "Unknown Country"
                    let location = "\(city), \(country)"
                    DispatchQueue.main.async {
                        completion(location)
                    }
                }
            } catch {
                print("❌ JSON Parsing Error:", error.localizedDescription)
                completion("Unknown Location")
            }
        }.resume()
    }

    // ✅ Handle Comment Button Tap
    @objc private func onCommentTapped() {
        print("💬 Comment button tapped!")
        onCommentTappedCallback?()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        postImageView.image = nil
        imageDataRequest?.cancel()
        locationLabel.text = "📍 Location: Unknown"
    }
}

extension DateFormatter {
    static let postFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter
    }()
}
