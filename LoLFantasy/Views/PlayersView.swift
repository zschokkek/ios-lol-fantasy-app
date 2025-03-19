import SwiftUI

struct PlayersView: View {
    @StateObject private var viewModel = PlayersViewModel()
    @State private var searchText = ""
    @State private var selectedPosition: Player.Position? = nil
    @State private var selectedRegion: Player.Region? = nil
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Search and filter bar
                    VStack(spacing: 15) {
                        // Search field
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            
                            TextField("Search players", text: $searchText)
                                .foregroundColor(.white)
                            
                            if !searchText.isEmpty {
                                Button(action: {
                                    searchText = ""
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        
                        // Filter options
                        HStack {
                            // Position filter
                            Menu {
                                Button("All Positions") {
                                    selectedPosition = nil
                                }
                                
                                Divider()
                                
                                ForEach(Player.Position.allCases, id: \.self) { position in
                                    Button(position.rawValue) {
                                        selectedPosition = position
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(selectedPosition?.rawValue ?? "Position")
                                        .foregroundColor(.white)
                                    
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.yellow)
                                        .font(.caption)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                            }
                            
                            // Region filter
                            Menu {
                                Button("All Regions") {
                                    selectedRegion = nil
                                }
                                
                                Divider()
                                
                                ForEach(Player.Region.allCases, id: \.self) { region in
                                    Button(region.rawValue) {
                                        selectedRegion = region
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(selectedRegion?.rawValue ?? "Region")
                                        .foregroundColor(.white)
                                    
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.yellow)
                                        .font(.caption)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                            }
                            
                            Spacer()
                            
                            // Sort button
                            Menu {
                                Button("Name (A-Z)") {
                                    viewModel.sortBy = .nameAsc
                                }
                                
                                Button("Name (Z-A)") {
                                    viewModel.sortBy = .nameDesc
                                }
                                
                                Button("Points (High-Low)") {
                                    viewModel.sortBy = .pointsDesc
                                }
                                
                                Button("Points (Low-High)") {
                                    viewModel.sortBy = .pointsAsc
                                }
                            } label: {
                                HStack {
                                    Text("Sort")
                                        .foregroundColor(.white)
                                    
                                    Image(systemName: "arrow.up.arrow.down")
                                        .foregroundColor(.yellow)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    
                    // Players list
                    if viewModel.isLoading {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .yellow))
                            .scaleEffect(1.5)
                        Spacer()
                    } else if filteredPlayers.isEmpty {
                        Spacer()
                        VStack(spacing: 20) {
                            Image(systemName: "person.slash")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.gray)
                            
                            Text("No Players Found")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Try adjusting your filters or search terms")
                                .font(.body)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredPlayers) { player in
                                    NavigationLink(destination: PlayerDetailView(playerId: player.id)) {
                                        PlayerRow(player: player)
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("Players")
            .onAppear {
                viewModel.loadPlayers()
            }
        }
    }
    
    private var filteredPlayers: [Player] {
        viewModel.getFilteredAndSortedPlayers(
            searchText: searchText,
            position: selectedPosition,
            region: selectedRegion
        )
    }
}

struct PlayerRow: View {
    let player: Player
    
    var body: some View {
        HStack(spacing: 15) {
            // Player image
            AsyncImage(url: URL(string: player.imageUrl ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Image(systemName: "person.fill")
                    .foregroundColor(.gray)
            }
            .frame(width: 50, height: 50)
            .background(Color.gray.opacity(0.2))
            .clipShape(Circle())
            
            // Player info
            VStack(alignment: .leading, spacing: 4) {
                Text(player.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                HStack {
                    Text(player.team)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text("•")
                        .foregroundColor(.gray)
                    
                    Text(player.region.rawValue)
                        .font(.caption)
                        .foregroundColor(.yellow)
                }
            }
            
            Spacer()
            
            // Position badge
            Text(player.position.rawValue)
                .font(.caption)
                .fontWeight(.semibold)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(positionColor(player.position).opacity(0.2))
                .foregroundColor(positionColor(player.position))
                .cornerRadius(8)
            
            // Points
            VStack(alignment: .trailing, spacing: 2) {
                Text(String(format: "%.1f", player.fantasyPoints))
                    .font(.headline)
                    .foregroundColor(.yellow)
                
                Text("PTS")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            .frame(width: 50)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
    
    private func positionColor(_ position: Player.Position) -> Color {
        switch position {
        case .TOP:
            return .red
        case .JUNGLE:
            return .green
        case .MID:
            return .purple
        case .ADC:
            return .orange
        case .SUPPORT:
            return .blue
        case .FLEX:
            return .gray
        }
    }
}

class PlayersViewModel: ObservableObject {
    @Published var players: [Player] = []
    @Published var isLoading = false
    @Published var sortBy: SortOption = .pointsDesc
    
    enum SortOption {
        case nameAsc
        case nameDesc
        case pointsAsc
        case pointsDesc
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    func loadPlayers() {
        isLoading = true
        
        APIService.shared.getPlayers()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    
                    if case .failure(let error) = completion {
                        print("Error loading players: \(error)")
                    }
                },
                receiveValue: { [weak self] players in
                    self?.players = players
                }
            )
            .store(in: &cancellables)
    }
    
    func getFilteredAndSortedPlayers(searchText: String, position: Player.Position?, region: Player.Region?) -> [Player] {
        var filteredPlayers = players
        
        // Apply search filter
        if !searchText.isEmpty {
            filteredPlayers = filteredPlayers.filter { player in
                player.name.lowercased().contains(searchText.lowercased()) ||
                player.team.lowercased().contains(searchText.lowercased())
            }
        }
        
        // Apply position filter
        if let position = position {
            filteredPlayers = filteredPlayers.filter { $0.position == position }
        }
        
        // Apply region filter
        if let region = region {
            filteredPlayers = filteredPlayers.filter { $0.region == region }
        }
        
        // Apply sorting
        switch sortBy {
        case .nameAsc:
            filteredPlayers.sort { $0.name < $1.name }
        case .nameDesc:
            filteredPlayers.sort { $0.name > $1.name }
        case .pointsAsc:
            filteredPlayers.sort { $0.fantasyPoints < $1.fantasyPoints }
        case .pointsDesc:
            filteredPlayers.sort { $0.fantasyPoints > $1.fantasyPoints }
        }
        
        return filteredPlayers
    }
}
