import Foundation
import Combine

class TeamsViewModel: ObservableObject {
    @Published var teams: [FantasyTeam] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    func loadTeams() {
        isLoading = true
        errorMessage = nil
        
        // In a real app, you would call an API to get teams
        // For now, we'll simulate with a delay and dummy data
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            // Sample teams
            self?.teams = [
                FantasyTeam(
                    id: "team1",
                    name: "Dream Team",
                    ownerId: "user123",
                    leagueId: "league1",
                    roster: [
                        FantasyTeam.RosterSlot(id: "slot1", position: .TOP),
                        FantasyTeam.RosterSlot(id: "slot2", position: .JUNGLE),
                        FantasyTeam.RosterSlot(id: "slot3", position: .MID),
                        FantasyTeam.RosterSlot(id: "slot4", position: .ADC),
                        FantasyTeam.RosterSlot(id: "slot5", position: .SUPPORT)
                    ],
                    points: 450.5
                ),
                FantasyTeam(
                    id: "team2",
                    name: "Challengers",
                    ownerId: "user123",
                    leagueId: "league2",
                    roster: [
                        FantasyTeam.RosterSlot(id: "slot6", position: .TOP),
                        FantasyTeam.RosterSlot(id: "slot7", position: .JUNGLE),
                        FantasyTeam.RosterSlot(id: "slot8", position: .MID),
                        FantasyTeam.RosterSlot(id: "slot9", position: .ADC),
                        FantasyTeam.RosterSlot(id: "slot10", position: .SUPPORT)
                    ],
                    points: 380.0
                )
            ]
            
            self?.isLoading = false
        }
    }
    
    func getFilteredTeams(searchText: String) -> [FantasyTeam] {
        if searchText.isEmpty {
            return teams
        }
        
        return teams.filter { team in
            team.name.lowercased().contains(searchText.lowercased())
        }
    }
    
    func createTeam(name: String, leagueId: String) -> AnyPublisher<FantasyTeam, Error> {
        // In a real app, you would call an API to create a team
        // For now, we'll return a dummy publisher with a simulated delay
        return Future<FantasyTeam, Error> { promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                // Create a dummy team
                let team = FantasyTeam.createEmptyTeam(
                    id: UUID().uuidString,
                    name: name,
                    ownerId: "user123", // Current user ID
                    leagueId: leagueId
                )
                
                promise(.success(team))
            }
        }
        .eraseToAnyPublisher()
    }
}
