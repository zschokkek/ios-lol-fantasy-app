import Foundation
import Combine
import SwiftUI


public struct PlayersView: View {
    @StateObject private var viewModel = PlayersViewModel()
    @State private var searchText = ""
    @State private var selectedPosition: Player.Position? = nil
    @State private var selectedRegion: Player.Region? = nil

    public var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)

            VStack(spacing: 0) {
                SearchAndFilterBar(
                    searchText: $searchText,
                    selectedPosition: $selectedPosition,
                    selectedRegion: $selectedRegion,
                    viewModel: viewModel
                )

                ContentDisplay(
                    isLoading: viewModel.isLoading,
                    filteredPlayers: filteredPlayers
                )
            }
        }
        .navigationTitle("Players")
        .onAppear { viewModel.loadPlayers() }
    }

    private var filteredPlayers: [Player] {
        viewModel.getFilteredAndSortedPlayers(
            searchText: searchText,
            position: selectedPosition,
            region: selectedRegion
        )
    }
}

// MARK: - Subviews

struct SearchAndFilterBar: View {
    @Binding var searchText: String
    @Binding var selectedPosition: Player.Position?
    @Binding var selectedRegion: Player.Region?
    let viewModel: PlayersViewModel

    var body: some View {
        VStack(spacing: 15) {
            SearchField(searchText: $searchText)
            FilterOptions(
                selectedPosition: $selectedPosition,
                selectedRegion: $selectedRegion,
                viewModel: viewModel
            )
        }
        .padding()
        .background(Color.gray.opacity(0.1))
    }
}

struct SearchField: View {
    @Binding var searchText: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass").foregroundColor(.gray)
            TextField("Search players", text: $searchText).foregroundColor(.white)
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill").foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
    }
}

struct FilterOptions: View {
    @Binding var selectedPosition: Player.Position?
    @Binding var selectedRegion: Player.Region?
    let viewModel: PlayersViewModel

    var body: some View {
        HStack {
            FilterMenu(label: "Position", selectedValue: selectedPosition?.rawValue, options: Player.Position.allCases.map { $0.rawValue }) {
                selectedPosition = nil
            } selectOption: { option in
                selectedPosition = Player.Position(rawValue: option)
            }

            FilterMenu(label: "Region", selectedValue: selectedRegion?.rawValue, options: Player.Region.allCases.map { $0.rawValue }) {
                selectedRegion = nil
            } selectOption: { option in
                selectedRegion = Player.Region(rawValue: option)
            }

            Spacer()

            FilterMenu(label: "Sort", selectedValue: "Sort", options: ["Name (A-Z)", "Name (Z-A)", "Points (High-Low)", "Points (Low-High)"]) {
                viewModel.sortBy = .nameAsc
            } selectOption: { option in
                switch option {
                case "Name (A-Z)": viewModel.sortBy = .nameAsc
                case "Name (Z-A)": viewModel.sortBy = .nameDesc
                case "Points (High-Low)": viewModel.sortBy = .pointsDesc
                case "Points (Low-High)": viewModel.sortBy = .pointsAsc
                default: break
                }
            }
        }
    }
}

struct FilterMenu: View {
    let label: String
    let selectedValue: String?
    let options: [String]
    let clearSelection: () -> Void
    let selectOption: (String) -> Void
    
    var body: some View {
        Menu {
            Button("All \(label)") {
                clearSelection()
            }
            
            Divider()
            
            ForEach(options, id: \.self) { option in
                Button(option) {
                    selectOption(option)
                }
            }
        } label: {
            HStack {
                Text(selectedValue ?? label)
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
    }
}


struct ContentDisplay: View {
    let isLoading: Bool
    let filteredPlayers: [Player]

    var body: some View {
        if isLoading {
            LoadingView()
        } else if filteredPlayers.isEmpty {
            EmptyStateView(
                title: "No Players Found",
                message: "Try adjusting your filters or search terms",
                buttonText: "Reset Filters",
                action: {}
            )
        } else {
            PlayersListView(players: filteredPlayers)
        }
    }
}

struct EmptyStateView: View {
    let title: String
    let message: String
    let buttonText: String
    let action: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.slash")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundColor(.gray)

            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text(message)
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button(action: action) {
                Text(buttonText)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.yellow)
                    .foregroundColor(.black)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

struct LoadingView: View {
    var body: some View {
        Spacer()
        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .yellow)).scaleEffect(1.5)
        Spacer()
    }
}

struct PlayersListView: View {
    let players: [Player]

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(players) { player in
                    NavigationLink(
                        destination: PlayerDetailView(
                            playerId: player.id,
                            viewModel: PlayerDetailViewModel()
                        )
                    ) {
                        PlayerRow(player: player)
                    }
                }
            }
            .padding()
        }
    }
}

struct PlayerRow: View {
    let player: Player

    var body: some View {
        HStack(spacing: 15) {

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
        case .TOP: return .red
        case .JUNGLE: return .green
        case .MID: return .purple
        case .ADC: return .orange
        case .SUPPORT: return .blue
        case .FLEX: return .gray
        }
    }
}
// MARK: - PlayersViewModel
class PlayersViewModel: ObservableObject {
    @Published private(set) var players: [Player] = []
    @Published var isLoading = false
    @Published var sortBy: SortOption = .pointsDesc

    enum SortOption {
        case nameAsc, nameDesc, pointsAsc, pointsDesc
    }

    private var originalPlayers: [Player] = []  // Store unfiltered data
    private var cancellables = Set<AnyCancellable>()

    func loadPlayers() {
        isLoading = true

        guard let url = URL(string: "https://egbfantasy.com/api/players/") else {
            print("❌ Invalid URL")
            isLoading = false
            return
        }

        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: [Player].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        print("❌ Error loading players: \(error.localizedDescription)")
                    }
                },
                receiveValue: { [weak self] players in
                    self?.originalPlayers = players
                    self?.applySorting()
                }
            )
            .store(in: &cancellables)
    }

    // Improved sorting logic
    private func applySorting() {
        switch sortBy {
        case .nameAsc:
            players = originalPlayers.sorted { $0.name < $1.name }
        case .nameDesc:
            players = originalPlayers.sorted { $0.name > $1.name }
        case .pointsAsc:
            players = originalPlayers.sorted { $0.fantasyPoints < $1.fantasyPoints }
        case .pointsDesc:
            players = originalPlayers.sorted { $0.fantasyPoints > $1.fantasyPoints }
        }
    }

    func getFilteredAndSortedPlayers(searchText: String, position: Player.Position?, region: Player.Region?) -> [Player] {
        return players.filter { player in
            (searchText.isEmpty || player.name.lowercased().contains(searchText.lowercased()) ||
             player.team.lowercased().contains(searchText.lowercased())) &&
            (position == nil || player.position == position) &&
            (region == nil || player.region == region)
        }
    }
}
