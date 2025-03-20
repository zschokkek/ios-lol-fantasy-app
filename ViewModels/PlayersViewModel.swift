import Foundation
import Combine

class PlayersViewModel: ObservableObject {
    @Published var players: [Player] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var sortBy: SortOption = .nameAsc
    
    enum SortOption {
        case nameAsc
        case nameDesc
        case pointsAsc
        case pointsDesc
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    func loadPlayers() {
        isLoading = true
        errorMessage = nil
        
        APIService.shared.getPlayers()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] players in
                self?.players = players
            }
            .store(in: &cancellables)
    }
    
    func getFilteredAndSortedPlayers(searchText: String, position: Player.Position?, region: Player.Region?) -> [Player] {
        let filtered = players.filter { player in
            let matchesSearch = searchText.isEmpty || player.name.lowercased().contains(searchText.lowercased())
            let matchesPosition = position == nil || player.position == position
            let matchesRegion = region == nil || player.region == region
            
            return matchesSearch && matchesPosition && matchesRegion
        }
        
        return sort(players: filtered, by: sortBy)
    }
    
    private func sort(players: [Player], by option: SortOption) -> [Player] {
        switch option {
        case .nameAsc:
            return players.sorted { $0.name < $1.name }
        case .nameDesc:
            return players.sorted { $0.name > $1.name }
        case .pointsAsc:
            return players.sorted { $0.fantasyPoints < $1.fantasyPoints }
        case .pointsDesc:
            return players.sorted { $0.fantasyPoints > $1.fantasyPoints }
        }
    }
}
