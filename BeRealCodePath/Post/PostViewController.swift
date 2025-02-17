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
        label.textAlignment = //
//  PostView.swift
//  BeRealCodePath
//
//  Created by Cristian Gonzalez on 2/4/25.
//
import SwiftUI
import ParseSwift
import CoreLocation
import PhotosUI
import Foundation

struct PostViewController: View {
    @State private var caption: String = ""
    @State private var selectedImage: UIImage?
    @State private var isShowingImagePicker = false
    @State private var isShowingPhotoLibrary = false
    @State private var currentLocation: CLLocation?
    @State private var showAlert = false
    @State private var alertMessage = ""
    @Environment(\.dismiss) var dismiss
    
    private let locationManager = CLLocationManager()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    // Title
                    Text("Create Post")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)

                    // Caption Field
                    TextField("Write a caption...", text: $caption)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .foregroundColor(.black)

                    // Image Preview
                    if let selectedImage = selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 250)
                            .cornerRadius(10)
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 250)
                            .cornerRadius(10)
                            .overlay(Text("No Image Selected").foregroundColor(.white))
                    }

                    // Capture Image Button
                    HStack {
                        Button(action: {
                            isShowingImagePicker = true
                        }) {
                            Text("📷 Take Photo")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .foregroundColor(.black)
                                .cornerRadius(10)
                        }

                        Button(action: {
                            isShowingPhotoLibrary = true
                        }) {
                            Text("🖼️ Upload Photo")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .foregroundColor(.black)
                                .cornerRadius(10)
                        }
                    }

                    // Share Button
                    Button(action: sharePost) {
                        Text("📤 Share Post")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    Spacer()
                }
                .padding()
            }
            .onAppear(perform: requestLocation)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .fullScreenCover(isPresented: $isShowingImagePicker) {
                ImagePicker(image: $selectedImage, sourceType: .camera)
            }
            .fullScreenCover(isPresented: $isShowingPhotoLibrary) {
                ImagePicker(image: $selectedImage, sourceType: .photoLibrary)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "arrow.left")
                            Text("Back")
                        }
                        .foregroundColor(.white)
                    }
                }
            }
        }
    }

    // Share Post
    private func sharePost() {
        guard let selectedImage = selectedImage else {
            alertMessage = "Please select an image."
            showAlert = true
            return
        }

        guard let imageData = selectedImage.jpegData(compressionQuality: 0.8) else {
            alertMessage = "Failed to process image."
            showAlert = true
            return
        }

        let imageFile = ParseFile(name: "image.jpg", data: imageData)

        var post = Post()
        post.imageFile = imageFile
        post.caption = caption

        if let location = currentLocation {
            post.location = ["latitude": location.coordinate.latitude, "longitude": location.coordinate.longitude]
        }

        // Save the post
        post.save { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("✅ Post shared successfully!")

                    // Update the user's lastPostedDate
                    if var currentUser = User.current {
                        let now = Date()
                        currentUser.lastPostedDate = now

                        currentUser.save { saveResult in
                            switch saveResult {
                            case .success:
                                print("✅ lastPostedDate updated to \(now)")

                                // Force refresh of User.current to sync with server
                                User.current?.fetch { fetchResult in
                                    switch fetchResult {
                                    case .success:
                                        print("🔄 User refreshed successfully!")
                                        NotificationCenter.default.post(name: .didPostNewContent, object: nil)
                                        self.dismiss()
                                    case .failure(let error):
                                        print("❌ Failed to refresh user: \(error.localizedDescription)")
                                        self.dismiss()
                                    }
                                }

                            case .failure(let error):
                                print("❌ Failed to update lastPostedDate: \(error.localizedDescription)")
                                self.alertMessage = "Failed to update lastPostedDate."
                                self.showAlert = true
                            }
                        }
                    } else {
                        print("⚠️ No current user found.")
                        self.dismiss()
                    }

                case .failure(let error):
                    alertMessage = error.localizedDescription
                    showAlert = true
                }
            }
        }
    }

    // Request Location Permissions
    private func requestLocation() {
        locationManager.delegate = LocationDelegate(location: $currentLocation)
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
}

// Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    var sourceType: UIImagePickerController.SourceType

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.editedImage] as? UIImage {
                parent.image = image
            } else if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            picker.dismiss(animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        picker.allowsEditing = true
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

// Location Delegate to update location
class LocationDelegate: NSObject, CLLocationManagerDelegate {
    var location: Binding<CLLocation?>

    init(location: Binding<CLLocation?>) {
        self.location = location
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location.wrappedValue = locations.last
    }
}

#Preview {
    PostViewController()
}
.center
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

