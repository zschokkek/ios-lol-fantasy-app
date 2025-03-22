import SwiftUI
import Combine

public struct PlayerDetailView: View {
    let playerId: String
    @StateObject var viewModel = PlayerDetailViewModel()

    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                content
            }
            .padding()
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .navigationTitle("Player Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { loadPlayerData() }
    }

    // MARK: - Content Rendering
    private var content: some View {
        Group {
            if viewModel.isLoading {
                LoadingView()
            } else if let player = viewModel.player {
                PlayerHeaderView(player: player)
                FantasyPointsView(player: player, viewModel: viewModel)
                PlayerStatsView(player: player)
                UpdateImageView(viewModel: viewModel)
            } else {
                ErrorView(message: viewModel.errorMessage)
            }
        }
    }

    // MARK: - Methods
    private func loadPlayerData() {
        viewModel.loadPlayer(id: playerId)
    }
}

// MARK: - Subviews

struct PlayerHeaderView: View {
    let player: Player

    var body: some View {
        HStack(spacing: 15) {
            PlayerInfoView(player: player)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
    }
}

struct PlayerImageView: View {
    let imageUrl: String?

    var body: some View {
        AsyncImage(url: URL(string: imageUrl ?? "")) { image in
            image.resizable().aspectRatio(contentMode: .fill)
        } placeholder: {
            Image(systemName: "person.fill")
                .resizable()
                .padding()
                .foregroundColor(.gray)
        }
        .frame(width: 100, height: 100)
        .clipShape(Circle())
        .overlay(
            Circle().stroke(
                LinearGradient(
                    gradient: Gradient(colors: [Color.yellow, Color.orange]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 3
            )
        )
    }
}

struct PlayerInfoView: View {
    let player: Player

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(player.name)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)

            HStack(spacing: 8) {
                Badge(text: player.position.rawValue, color: positionColor(player.position))
                Badge(text: player.region.rawValue, color: .yellow)
            }

            Text(player.team)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }

    private func positionColor(_ position: Player.Position) -> Color {
        switch position {
        case .TOP: return .red
        case .JUNGLE: return .green
        case .MID: return .purple
        case .ADC: return .orange
        case .SUPPORT: return .blue
        case .FLEX: return .gray
        }
    }
}

struct FantasyPointsView: View {
    let player: Player
    @ObservedObject var viewModel: PlayerDetailViewModel

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text("Fantasy Points")
                    .font(.headline)
                    .foregroundColor(.gray)

                Text(String(format: "%.1f", player.fantasyPoints))
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.yellow)
            }

            Spacer()

            Button(action: { viewModel.updateStats() }) {
                Text("Update Stats")
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.yellow)
                    .cornerRadius(10)
            }
            .disabled(viewModel.isUpdating)
            .overlay(
                Group {
                    if viewModel.isUpdating {
                        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .black))
                    }
                }
            )
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
    }
}

struct PlayerStatsView: View {
    let player: Player

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Performance Stats")
                .font(.headline)
                .foregroundColor(.white)

            StatRow(label: "Games Played", value: "\(player.stats.gamesPlayed)", icon: "gamecontroller.fill")
            StatRow(label: "CS", value: "\(player.stats.cs)", icon: "dollarsign.circle.fill")
            StatRow(label: "Vision Score", value: "\(player.stats.visionScore)", icon: "eye.fill")
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
    }
}

struct UpdateImageView: View {
    @ObservedObject var viewModel: PlayerDetailViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Update Player Image")
                .font(.headline)
                .foregroundColor(.white)

            HStack {
                TextField("Enter image URL", text: $viewModel.imageUrl)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .foregroundColor(.white)

                Button(action: { viewModel.updateImage() }) {
                    Text("Update")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.yellow)
                        .cornerRadius(10)
                }
                .disabled(viewModel.isUpdatingImage)
                .overlay(
                    Group {
                        if viewModel.isUpdatingImage {
                            ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .black))
                        }
                    }
                )
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
    }
}

struct ErrorView: View {
    let message: String

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundColor(.yellow)

            Text("Player Not Found")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text(message.isEmpty ? "Could not load player data" : message)
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
        .padding(.top, 50)
    }
}

struct Badge: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .cornerRadius(8)
    }
}

struct StatRow: View {
    let label: String
    let value: String
    let icon: String
    var detail: String? = nil

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.yellow)
                .frame(width: 24)

            Text(label)
                .foregroundColor(.gray)

            Spacer()

            VStack(alignment: .trailing) {
                Text(value)
                    .font(.headline)
                    .foregroundColor(.white)

                if let detail = detail {
                    Text(detail)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.vertical, 5)
    }
}


class PlayerDetailViewModel: ObservableObject {
    @Published var player: Player?
    @Published var isLoading = false
    @Published var isUpdating = false
    @Published var isUpdatingImage = false
    @Published var errorMessage = ""
    @Published var imageUrl = ""

    private var cancellables = Set<AnyCancellable>()

    // Load Player
    func loadPlayer(id: String) {
        isLoading = true
        errorMessage = ""

        guard let url = URL(string: "https://egbfantasy.com/api/players/\(id)") else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }

        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: Player.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = "Error: \(error.localizedDescription)"
                    }
                },
                receiveValue: { [weak self] player in
                    self?.player = player
                }
            )
            .store(in: &cancellables)
    }

    // Update Player Stats
    func updateStats() {
        guard let player = player else { return }
        isUpdating = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.isUpdating = false
            self?.loadPlayer(id: player.id)
        }
    }

    // Update Player Image
    func updateImage() {
        guard let player = player, !imageUrl.isEmpty else { return }
        isUpdatingImage = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.isUpdatingImage = false
            self?.imageUrl = ""
            self?.loadPlayer(id: player.id)
        }
    }
}
