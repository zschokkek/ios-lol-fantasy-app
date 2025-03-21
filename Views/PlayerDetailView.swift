import SwiftUI
import Combine

public struct PlayerDetailView: View {
    let playerId: String
    @ObservedObject var viewModel: PlayerDetailViewModel  // ✅ Correct way
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .yellow))
                        .scaleEffect(1.5)
                        .padding(.top, 100)
                } else if let player = viewModel.player {
                    // Player header
                    HStack(spacing: 15) {
                        // Player image
                        AsyncImage(url: URL(string: player.imageUrl ?? "")) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Image(systemName: "person.fill")
                                .resizable()
                                .padding()
                                .foregroundColor(.gray)
                        }
                        .frame(width: 100, height: 100)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.yellow, Color.orange]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 3
                                )
                        )
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text(player.name)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            HStack(spacing: 8) {
                                // Position badge
                                Text(player.position.rawValue)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        positionColor(player.position)
                                            .opacity(0.2)
                                    )
                                    .foregroundColor(positionColor(player.position))
                                    .cornerRadius(8)
                                
                                // Region badge
                                Text(player.region.rawValue)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.yellow.opacity(0.2))
                                    .foregroundColor(.yellow)
                                    .cornerRadius(8)
                            }
                            
                            Text(player.team)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(15)
                    
                    // Fantasy points
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
                        
                        Button(action: {
                            viewModel.updateStats()
                        }) {
                            Text("Update Stats")
                                .font(.headline)
                                .foregroundColor(.black)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.yellow, Color.orange]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(10)
                        }
                        .disabled(viewModel.isUpdating)
                        .overlay(
                            Group {
                                if viewModel.isUpdating {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                }
                            }
                        )
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(15)
                    
                    // Player stats
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Performance Stats")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        // Games played
                        StatRow(
                            label: "Games Played",
                            value: "\(player.stats.gamesPlayed)",
                            icon: "gamecontroller.fill"
                        )
                        
                        // KDA
                        StatRow(
                            label: "KDA",
                            value: String(format: "%.2f", player.stats.kda),
                            icon: "chart.bar.fill",
                            detail: "\(player.stats.kills) K / \(player.stats.deaths) D / \(player.stats.assists) A"
                        )
                        
                        // CS
                        StatRow(
                            label: "CS",
                            value: "\(player.stats.cs)",
                            icon: "dollarsign.circle.fill"
                        )
                        
                        // Vision Score
                        StatRow(
                            label: "Vision Score",
                            value: "\(player.stats.visionScore)",
                            icon: "eye.fill"
                        )
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(15)
                    
                    // Update player image section
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
                            
                            Button(action: {
                                viewModel.updateImage()
                            }) {
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
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                    }
                                }
                            )
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(15)
                } else {
                    // Error or player not found
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
                        
                        Text(viewModel.errorMessage.isEmpty ? "Could not load player data" : viewModel.errorMessage)
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
            .padding()
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .navigationTitle("Player Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadPlayer(id: playerId)
        }
    }
    
    private func positionColor(_ position: Player.Position) -> Color {
        switch position {
        case Player.Position.TOP:
            return .red
        case Player.Position.JUNGLE:
            return .green
        case Player.Position.MID:
            return .purple
        case Player.Position.ADC:
            return .orange
        case Player.Position.SUPPORT:
            return .blue
        case Player.Position.FLEX:
            return .gray
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
    
    public class PlayerDetailViewModel: ObservableObject {
        @Published var player: Player?
        @Published var isLoading = false
        @Published var isUpdating = false
        @Published var isUpdatingImage = false
        @Published var errorMessage = ""
        @Published var imageUrl = ""
        
        private var cancellables = Set<AnyCancellable>()
        
        func loadPlayer(id: String) {
            isLoading = true
            errorMessage = ""
            
            LoLFantasyAPIService.shared.getPlayerById(id)
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
        
        func updateStats() {
            guard let player = player else { return }
            
            isUpdating = true
            
            // This would be an API call to update player stats
            // For now, we'll simulate it with a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                self?.isUpdating = false
                self?.loadPlayer(id: player.id)
            }
        }
        
        func updateImage() {
            guard let player = player, !imageUrl.isEmpty else { return }
            
            isUpdatingImage = true
            
            // This would be an API call to update player image
            // For now, we'll simulate it with a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                self?.isUpdatingImage = false
                self?.imageUrl = ""
                self?.loadPlayer(id: player.id)
            }
        }
    }
}
