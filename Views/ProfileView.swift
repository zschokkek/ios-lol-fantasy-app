import SwiftUI
import Combine

struct ProfileView: View {
    @EnvironmentObject private var authManager: AuthManager
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showingEditProfile = false
    @State private var showingConfirmLogout = false

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack(spacing: 25) {
                    profileHeader
                    statsSection
                    favoritePlayersSection
                    accountSettings
                }
                .padding()
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $showingConfirmLogout) {
            Alert(
                title: Text("Log Out"),
                message: Text("Are you sure you want to log out?"),
                primaryButton: .destructive(Text("Log Out")) {
                    authManager.logout()
                },
                secondaryButton: .cancel()
            )
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView(user: authManager.currentUser)
        }
        .onAppear {
            if let userId = authManager.currentUser?.id {
                viewModel.loadUserData(userId: userId)
            }
        }
    }
}

// MARK: - Profile Header
private extension ProfileView {
    var profileHeader: some View {
        VStack(spacing: 15) {
            profileImage
            profileInfo
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
    }

    var profileImage: some View {
        if let profileImageUrl = authManager.currentUser?.profileImageUrl,
           !profileImageUrl.isEmpty,
           let url = URL(string: profileImageUrl) {
            AsyncImage(url: url) { (image: Image) in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.yellow, lineWidth: 2))
            } placeholder: {
                defaultProfileImage
            }
        } else {
            defaultProfileImage
        }
    }

    var defaultProfileImage: some View {
        Image(systemName: "person.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .padding(20)
            .frame(width: 100, height: 100)
            .background(Color.gray.opacity(0.2))
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.yellow, lineWidth: 2))
            .foregroundColor(.gray)
    }

    var profileInfo: some View {
        VStack(spacing: 5) {
            Text(authManager.currentUser?.username ?? "Summoner")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)

            if let region = authManager.currentUser?.region {
                Text(region)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Button(action: { showingEditProfile = true }) {
                Text("Edit Profile")
                    .font(.caption)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 8)
                    .background(Color.yellow)
                    .foregroundColor(.black)
                    .cornerRadius(20)
            }
            .padding(.top, 5)
        }
    }
}

// MARK: - Stats Section
private extension ProfileView {
    var statsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Stats")
                .font(.headline)
                .foregroundColor(.white)

            HStack {
                StatCard(title: "Teams", value: "\(viewModel.teamsCount)", icon: "person.3.fill", color: .blue)
                StatCard(title: "Leagues", value: "\(viewModel.leaguesCount)", icon: "trophy.fill", color: .yellow)
                StatCard(title: "Win Rate", value: "\(viewModel.winRate)%", icon: "chart.bar.fill", color: .green)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
    }
}

// MARK: - Favorite Players Section
private extension ProfileView {
    var favoritePlayersSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Favorite Players")
                .font(.headline)
                .foregroundColor(.white)

            if viewModel.favoritePlayers.isEmpty {
                Text("You haven't added any favorite players yet.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(viewModel.favoritePlayers, id: \.id) { player in
                            FavoritePlayerCard(player: player)
                        }
                    }
                    .padding(.horizontal, 5)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
    }
}

// MARK: - Account Settings Section
private extension ProfileView {
    var accountSettings: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Account Settings")
                .font(.headline)
                .foregroundColor(.white)

            VStack(spacing: 0) {
                settingButton(icon: "bell.fill", title: "Push Notifications", color: .blue)
                settingDivider
                settingButton(icon: "lock.fill", title: "Change Password", color: .green)
                settingDivider
                settingButton(icon: "moon.fill", title: "Dark Mode", color: .purple, hasToggle: true, isToggled: true)
                settingDivider
                settingButton(icon: "arrow.right.square.fill", title: "Log Out", color: .red) {
                    showingConfirmLogout = true
                }
            }
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
    }

    var settingDivider: some View {
        Divider()
            .background(Color.gray.opacity(0.3))
            .padding(.horizontal)
    }

    func settingButton(icon: String, title: String, color: Color, hasToggle: Bool = false, isToggled: Bool = false, action: @escaping () -> Void = {}) -> some View {
        Button(action: action) {
            SettingRow(
                icon: icon,
                title: title,
                iconColor: color,
                hasToggle: hasToggle,
                isToggled: isToggled
            )
        }
    }
}

// MARK: - ProfileViewModel
class ProfileViewModel: ObservableObject {
    @Published var teamsCount = 0
    @Published var leaguesCount = 0
    @Published var winRate = 0.0
    @Published var favoritePlayers: [Player] = []

    private var cancellables = Set<AnyCancellable>()

    func loadUserData(userId: String) {
        LoLFantasyAPIService.shared.getUserProfile(userId: userId)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Failed to load profile: \(error)")
                }
            }, receiveValue: { [weak self] profile in
                self?.teamsCount = profile.teamsCount
                self?.leaguesCount = profile.leaguesCount
                self?.winRate = profile.winRate
                self?.favoritePlayers = profile.favoritePlayers
            })
            .store(in: &cancellables)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
    }
}

struct FavoritePlayerCard: View {
    let player: Player
    
    var body: some View {
        NavigationLink(destination: PlayerDetailView(playerId: player.id)) {
            VStack(spacing: 10) {
                if let imageUrl = player.imageUrl, !imageUrl.isEmpty {
                    AsyncImage(url: URL(string: imageUrl)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        Image(systemName: "person.fill")
                            .foregroundColor(.gray)
                    }
                    .frame(width: 80, height: 80)
                    .background(Color.gray.opacity(0.2))
                    .clipShape(Circle())
                } else {
                    Image(systemName: "person.fill")
                        .frame(width: 80, height: 80)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(Circle())
                        .foregroundColor(.gray)
                }
                
                VStack(spacing: 5) {
                    Text(player.name)
                        .font(.headline)
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    HStack(spacing: 4) {
                        Text(player.position.rawValue)
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Text("•")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Text(player.team)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Text(String(format: "%.1f pts", player.fantasyPoints))
                        .font(.caption)
                        .foregroundColor(.yellow)
                }
            }
            .frame(width: 100)
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(15)
        }
    }
}

struct SettingRow: View {
    let icon: String
    let title: String
    let iconColor: Color
    var hasToggle: Bool = false
    var isToggled: Bool = false
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .frame(width: 24, height: 24)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.white)
            
            Spacer()
            
            if hasToggle {
                Toggle("", isOn: .constant(isToggled))
                    .labelsHidden()
            } else {
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
        }
        .padding()
    }
}

class ProfileViewModel: ObservableObject {
    @Published var favoritePlayers: [Player] = []
    @Published var teamsCount: Int = 0
    @Published var leaguesCount: Int = 0
    @Published var winRate: Int = 0
    @Published var pushNotificationsEnabled: Bool = true
    
    private var cancellables = Set<AnyCancellable>()
    
    func loadUserData() {
        // In a real app, this would load data from the API
        
        // For now, simulate loading with sample data
        LoLFantasyAPIService.shared.getUserProfile()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Error loading profile: \(error)")
                    }
                },
                receiveValue: { [weak self] profile in
                    self?.favoritePlayers = profile.favoritePlayers
                    self?.teamsCount = profile.teamsCount
                    self?.leaguesCount = profile.leaguesCount
                    self?.winRate = profile.winRate
                    self?.pushNotificationsEnabled = profile.pushNotificationsEnabled
                }
            )
            .store(in: &cancellables)
    }
}

struct EditProfileView: View {
    let user: User?
    @Environment(\.presentationMode) var presentationMode
    @State private var username: String = ""
    @State private var region: String = ""
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 20) {
                        VStack {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100, height: 100)
                                .foregroundColor(.yellow)
                                .padding()
                            
                            Button("Change Photo") {
                                // Photo selection logic
                            }
                            .font(.subheadline)
                            .foregroundColor(.yellow)
                        }
                        
                        VStack(spacing: 15) {
                            VStack(alignment: .leading) {
                                Text("Username")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                
                                TextField("Username", text: $username)
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                                    .foregroundColor(.white)
                            }
                            
                            VStack(alignment: .leading) {
                                Text("Region")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                
                                TextField("Region", text: $region)
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding()
                        
                        Button(action: {
                            saveProfile()
                        }) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                } else {
                                    Text("Save Changes")
                                        .font(.headline)
                                        .foregroundColor(.black)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.yellow)
                            .cornerRadius(10)
                        }
                        .disabled(isLoading)
                        .padding(.horizontal)
                    }
                    .padding()
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.yellow)
                }
            }
            .onAppear {
                username = user?.username ?? ""
                region = user?.region ?? ""
            }
        }
    }
    
    private func saveProfile() {
        isLoading = true
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isLoading = false
            presentationMode.wrappedValue.dismiss()
        }
    }
}
