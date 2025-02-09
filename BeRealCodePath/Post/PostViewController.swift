import UIKit
import ParseSwift
import PhotosUI

class PostViewController: UIViewController {

    // MARK: - UI Elements
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Create Post"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("← Back", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        button.addTarget(self, action: #selector(onBackButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let captionTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Write a caption..."
        textField.textColor = .white
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.borderStyle = .roundedRect
        textField.backgroundColor = UIColor(white: 0.2, alpha: 1)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let previewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = UIColor(white: 0.2, alpha: 1)
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let pickImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Pick Image", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 8
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(onPickedImageTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Share Post", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 8
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(onShareTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private var pickedImage: UIImage?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        navigationItem.title = "Create Post"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(onBackButtonTapped))
        
        setupUI()
    }

    // MARK: - UI Setup
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(backButton)
        view.addSubview(captionTextField)
        view.addSubview(previewImageView)
        view.addSubview(pickImageButton)
        view.addSubview(shareButton)

        NSLayoutConstraint.activate([
            // Title
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            // Back Button
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),

            // Caption TextField
            captionTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            captionTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            captionTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            captionTextField.heightAnchor.constraint(equalToConstant: 44),

            // Preview ImageView
            previewImageView.topAnchor.constraint(equalTo: captionTextField.bottomAnchor, constant: 20),
            previewImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            previewImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            previewImageView.heightAnchor.constraint(equalToConstant: 250),

            // Pick Image Button
            pickImageButton.topAnchor.constraint(equalTo: previewImageView.bottomAnchor, constant: 20),
            pickImageButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            pickImageButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            pickImageButton.heightAnchor.constraint(equalToConstant: 50),

            // Share Button
            shareButton.topAnchor.constraint(equalTo: pickImageButton.bottomAnchor, constant: 20),
            shareButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            shareButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            shareButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    // MARK: - Actions
    @objc private func onBackButtonTapped() {
        navigationController?.popViewController(animated: true) // ✅ Go back to FeedViewController
    }

    @objc private func onPickedImageTapped() {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    @objc private func onShareTapped() {
        view.endEditing(true)

        guard let pickedImage = pickedImage else {
            showAlert(description: "Please select an image to share.")
            return
        }

        let caption = captionTextField.text

        guard let imageData = pickedImage.jpegData(compressionQuality: 0.8) else {
            showAlert(description: "Could not process image.")
            return
        }

        let imageFile = ParseFile(name: "image.jpg", data: imageData)

        var post = Post()
        post.imageFile = imageFile
        post.caption = caption
        //post.user = username // ✅ Assign the user

        post.save { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("✅ Post shared successfully!")

                    self?.pickedImage = nil
                    self?.previewImageView.image = nil
                    self?.captionTextField.text = nil

                    // ✅ Ensure proper dismissal
                    if let presentingVC = self?.presentingViewController {
                        print("✅ Dismissing PostViewController")
                        presentingVC.dismiss(animated: true) {
                            print("✅ PostViewController dismissed, should return to FeedViewController")
                        }
                    } else {
                        print("❌ Error: No presenting view controller found!")
                    }

                case .failure(let error):
                    self?.showAlert(description: error.localizedDescription)
                }
            }
        }
    }

    private func showAlert(description: String? = nil) {
        let alertController = UIAlertController(title: "Oops...", message: "\(description ?? "Please try again...")", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        present(alertController, animated: true)
    }
}

// MARK: - PHPickerViewControllerDelegate
extension PostViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        guard let provider = results.first?.itemProvider,
              provider.canLoadObject(ofClass: UIImage.self) else {
            return
        }

        provider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
            if let error = error {
                self?.showAlert(description: error.localizedDescription)
                return
            }

            guard let image = object as? UIImage else {
                self?.showAlert(description: "Could not load image.")
                return
            }

            DispatchQueue.main.async {
                self?.previewImageView.image = image
                self?.pickedImage = image
            }
        }
    }
}

