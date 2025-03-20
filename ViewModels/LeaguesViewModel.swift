import Foundation
import Combine

class LeaguesViewModel: ObservableObject {
    @Published var leagues: [League] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    func loadLeagues() {
        isLoading = true
        errorMessage = nil
        
        APIService.shared.getLeagues()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] leagues in
                self?.leagues = leagues
            }
            .store(in: &cancellables)
    }
    
    func getFilteredLeagues(searchText: String) -> [League] {
        if searchText.isEmpty {
            return leagues
        }
        
        return leagues.filter { league in
            league.name.lowercased().contains(searchText.lowercased())
        }
    }
    
    func createLeague(name: String, maxTeams: Int, regions: [Player.Region], isPublic: Bool = true) -> AnyPublisher<League, Error> {
        // In a real app, you would call an API to create a league
        // For now, we'll return a dummy publisher with a simulated delay
        return Future<League, Error> { promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                // Create a dummy league
                let league = League(
                    id: UUID().uuidString,
                    name: name,
                    teams: [],
                    currentWeek: 1,
                    totalWeeks: 10,
                    schedule: [],
                    playerPool: [],
                    regions: regions,
                    creatorId: "user123", // Current user ID
                    members: [],
                    draftCompleted: false,
                    draftInProgress: false,
                    draftOrder: []
                )
                
                promise(.success(league))
            }
        }
        .eraseToAnyPublisher()
    }
}
