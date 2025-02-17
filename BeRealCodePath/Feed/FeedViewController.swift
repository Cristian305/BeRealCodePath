import SwiftUI
import ParseSwift

struct FeedViewController: View {
    @State private var posts: [Post] = []
    @State private var isLoading = true
    @State private var isShowingPostView = false
    @State private var selectedPost: Post?
    @State private var isShowingComments = false
    
    @State private var locationCache: [String: String] = [:]
    @State private var currentPage = 1
    @State private var isRefreshing = false
    @State private var lastPostedDate: Date?
    
    var body: some View {
        VStack {
            // Custom Navigation Bar
            HStack {
                Button(action: signOut) {
                    Text("Sign Out")
                        .foregroundColor(.red)
                        .padding()
                }

                Spacer()

                Text("BeReal.")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)

                Spacer()

                Button(action: { isShowingPostView = true }) {
                    Text("Post")
                        .foregroundColor(.blue)
                        .padding()
                }
            }
            .background(Color.black)

            // Refresh Animation
            if isRefreshing {
                HStack {
                    Spacer()
                    ProgressView("Refreshing...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .padding()
                    Spacer()
                }
                .background(Color.black)
                .transition(.move(edge: .top))
            }

            // Post List with Pull-to-Refresh
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(posts.indices, id: \.self) { index in
                        let post = posts[index]
                        let isBlurred = shouldBlur(postDate: post.createdAt)

                        VStack(alignment: .leading, spacing: 10) {
                            // User Info & Timestamp
                            HStack {
                                Text("👤 \(post.user?.username ?? "Unknown")")
                                    .font(.headline)
                                    .foregroundColor(.white)

                                Spacer()

                                // 🕒 Timestamp Display
                                if let createdAt = post.createdAt {
                                    Text(formattedDate(createdAt))
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .padding(.trailing, 5)
                                } else {
                                    Text("Unknown Date")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }

                            // Location Info
                            if let location = post.location,
                               let latitude = location["latitude"],
                               let longitude = location["longitude"] {
                                let cacheKey = "\(latitude),\(longitude)"
                                if let cachedLocation = locationCache[cacheKey] {
                                    Text("📍 \(cachedLocation)")
                                        .font(.subheadline)
                                        .foregroundColor(.green)
                                } else {
                                    Text("📍 Loading location...")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .onAppear {
                                            fetchLocationName(latitude: Double(latitude) ?? 0, longitude: Double(longitude) ?? 0, cacheKey: cacheKey)
                                        }
                                }
                            } else {
                                Text("📍 Location: Unknown")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }

                            // Caption
                            Text("📝 \(post.caption ?? "No caption")")
                                .font(.subheadline)
                                .foregroundColor(.gray)

                            if let imageUrl = post.imageFile?.url?.absoluteString {
                                AsyncImage(url: URL(string: imageUrl)) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 200)
                                            .cornerRadius(10)
                                            .blur(radius: isBlurred ? 10 : 0)  // Blur based on the calculation
                                    case .failure:
                                        Text("Failed to load image")
                                            .foregroundColor(.red)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                            }

                            // ✅ View Comments Button
                            Button(action: {
                                selectedPost = post
                                isShowingComments = true
                            }) {
                                Text("💬 View Comments")
                                    .foregroundColor(.blue)
                                    .padding(5)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(5)
                            }
                        }
                        .padding()
                        .background(Color(.darkGray))
                        .cornerRadius(10)
                        .onAppear {
                            if index == posts.count - 1 {
                                loadMorePosts()
                            }
                        }
                    }

                    if isRefreshing {
                        ProgressView("Loading more posts...")
                            .padding()
                            .foregroundColor(.white)
                    }
                }
                .padding()
            }
            .background(Color.black)
            .refreshable {
                refreshFeed()
            }
        }
        .background(Color.black)
        .fullScreenCover(isPresented: $isShowingPostView) {
            PostViewController()
        }
        .fullScreenCover(item: $selectedPost) { post in
            CommentViewController(post: post)
        }
        .onAppear {
            fetchLastPostedDate()
        }
    }

    // MARK: - Fetch User Last Posted Date
    private func fetchLastPostedDate() {
            if let currentUser = User.current {
                lastPostedDate = currentUser.lastPostedDate
                print("ℹ️ lastPostedDate: \(lastPostedDate ?? Date.distantPast)")
                refreshFeed()
            } else {
                print("⚠️ No current user found.")
                refreshFeed()
            }
        }

    // MARK: - Fetch Posts
    private func queryPosts() {
        isLoading = true
        withAnimation {
            isRefreshing = true
        }

        let query = Post.query()
            .include("username")
            .include("imageFile")
            .include("location")
            .order([.descending("createdAt")])
            .limit(10)

        query.find { result in
            DispatchQueue.main.async {
                self.isLoading = false
                withAnimation {
                    self.isRefreshing = false
                }
                switch result {
                case .success(let fetchedPosts):
                    self.posts = fetchedPosts
                    print("✅ Fetched \(fetchedPosts.count) posts.")
                case .failure(let error):
                    print("❌ Error fetching posts: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Refresh Posts
    // MARK: - Refresh Posts
    private func refreshFeed() {
        isRefreshing = true
        let query = Post.query()
            .include("user")
            .include("imageFile")
            .include("location")
            .order([.descending("createdAt")])
            .limit(20)

        query.find { result in
            DispatchQueue.main.async {
                self.isRefreshing = false
                switch result {
                case .success(let fetchedPosts):
                    self.posts = fetchedPosts
                    print("✅ Posts fetched successfully!")

                case .failure(let error):
                    print("❌ Error fetching posts: \(error.localizedDescription)")
                }
            }
        }
    }    // MARK: - Load More Posts
    private func loadMorePosts() {
        guard !isRefreshing else { return }
        isRefreshing = true
        currentPage += 1

        let query = Post.query()
            .include("user")
            .include("imageFile")
            .include("location")
            .order([.descending("createdAt")])
            .skip(posts.count)
            .limit(10)

        query.find { result in
            DispatchQueue.main.async {
                self.isRefreshing = false
                switch result {
                case .success(let morePosts):
                    self.posts.append(contentsOf: morePosts)
                case .failure(let error):
                    print("❌ Failed to load more posts: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Location Lookup
    private func fetchLocationName(latitude: Double, longitude: Double, cacheKey: String) {
        let urlString = "https://ipapi.co/json/"
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    locationCache[cacheKey] = "Unknown Location"
                }
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    let city = json["city"] as? String ?? "Unknown City"
                    let country = json["country_name"] as? String ?? "Unknown Country"
                    let location = "\(city), \(country)"
                    DispatchQueue.main.async {
                        locationCache[cacheKey] = location
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    locationCache[cacheKey] = "Unknown Location"
                }
            }
        }.resume()
    }

    // MARK: - Check Blur Condition
    private func shouldBlur(postDate: Date?) -> Bool {
        guard let postDate = postDate, let lastPostedDate = User.current?.lastPostedDate else {
            print("⚠️ Missing date info, defaulting to blur.")
            return true
        }

        let calendar = Calendar.current
        guard let thresholdDate = calendar.date(byAdding: .day, value: -1, to: lastPostedDate) else {
            print("⚠️ Failed to calculate threshold date")
            return true
        }

        let isBlurred = postDate < thresholdDate
        print("🌀 Post Date: \(postDate) | Threshold: \(thresholdDate) | Blur: \(isBlurred)")
        return isBlurred
    }
    // MARK: - Format Date
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy, h:mm a"
        return formatter.string(from: date)
    }
    // MARK: - Sign Out
    private func signOut() {
        Task {
            do {
                try await User.logout()
                print("✅ Successfully logged out")
            } catch {
                print("❌ Error logging out: \(error.localizedDescription)")
            }
        }
    }
}
